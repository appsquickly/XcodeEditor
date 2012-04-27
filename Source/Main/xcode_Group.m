////////////////////////////////////////////////////////////////////////////////
//
//  EXPANZ
//  Copyright 2008-2011 EXPANZ
//  All Rights Reserved.
//
//  NOTICE: Expanz permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "xcode_FrameworkDefinition.h"
#import "xcode_Target.h"
#import "xcode_FileOperationQueue.h"
#import "xcode_XibDefinition.h"
#import "xcode_SourceFile.h"
#import "xcode_Group.h"
#import "xcode_Project.h"
#import "xcode_ClassDefinition.h"
#import "xcode_utils_KeyBuilder.h"
#import "xcode_SourceFileDefinition.h"

#import "Logging.h"
/* ================================================================================================================== */
@interface xcode_Group ()

- (void) makeGroupMemberWithName:(NSString*)name contents:(id)contents type:(XcodeSourceFileType)type
        fileOperationStyle:(XcodeFileOperationStyle)fileOperationStyle;

- (void) addMemberWithKey:(NSString*)key;

- (void) flagMembersAsDirty;

- (NSDictionary*) makeFileReferenceWithPath:(NSString*)path name:(NSString*)name type:(XcodeSourceFileType)type;

- (NSDictionary*) asDictionary;

- (XcodeMemberType) typeForKey:(NSString*)key;

- (void) addSourceFile:(SourceFile*)sourceFile toTargets:(NSArray*)targets;

@end
/* ================================================================================================================== */

@implementation xcode_Group

@synthesize pathRelativeToParent = _pathRelativeToParent;
@synthesize key = _key;
@synthesize children = _children;
@synthesize alias = _alias;



/* ================================================= Class Methods ================================================== */
+ (Group*) groupWithProject:(xcode_Project*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path
        children:(NSArray*)children {

    return [[Group alloc] initWithProject:project key:key alias:alias path:path children:children];
}

/* ================================================== Initializers ================================================== */
- (id) initWithProject:(xcode_Project*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path
        children:(NSArray*)children {
    self = [super init];
    if (self) {
        _project = project;
        _fileOperationQueue = [_project fileOperationQueue];
        _key = [key copy];
        _alias = [alias copy];
        _pathRelativeToParent = [path copy];

        _children = [[NSMutableArray alloc] init];
        [_children addObjectsFromArray:children];
    }
    return self;
}

/* ================================================ Interface Methods =============================================== */
#pragma mark Parent group

- (void) removeFromParentGroup {
    [self removeFromParentGroup:NO];
}


- (void) removeFromParentGroup:(BOOL)deleteChildren {
    LogDebug(@"Removing group %@", [self pathRelativeToProjectRoot]);
    if (deleteChildren) {
        LogDebug(@"Deleting children");
        for (id<XcodeGroupMember> groupMember in [self members]) {
            if ([groupMember groupMemberType] == PBXGroup) {
                Group* group = (Group*) groupMember;
                [group removeFromParentGroup:YES];
                LogDebug(@"My full path is : %@", [group pathRelativeToProjectRoot]);

            }
            else {
                [_fileOperationQueue queueDeletion:[groupMember pathRelativeToProjectRoot]];
            }
        }
    }
    [[_project objects] removeObjectForKey:_key];
    for (Target* target in [_project targets]) {
        [target removeMembersWithKeys:[self recursiveMembers]];
    }
}

- (xcode_Group*) parentGroup {
    return [_project groupForGroupMemberWithKey:_key];
}

- (BOOL) isRootGroup {
    return [self pathRelativeToParent] == nil && [self displayName] == nil;
}


/* ================================================================================================================== */
#pragma mark Adding children


- (void) addClass:(ClassDefinition*)classDefinition {


    [self makeGroupMemberWithName:[classDefinition headerFileName] contents:[classDefinition header]
            type:SourceCodeHeader fileOperationStyle:[classDefinition fileOperationStyle]];

    if ([classDefinition isObjectiveC]) {
        [self makeGroupMemberWithName:[classDefinition sourceFileName] contents:[classDefinition source]
                type:SourceCodeObjC fileOperationStyle:[classDefinition fileOperationStyle]];
    }
    else if ([classDefinition isObjectiveCPlusPlus]) {
        [self makeGroupMemberWithName:[classDefinition sourceFileName] contents:[classDefinition source]
                type:SourceCodeObjCPlusPlus fileOperationStyle:[classDefinition fileOperationStyle]];
    }

    [[_project objects] setObject:[self asDictionary] forKey:_key];
}


- (void) addClass:(ClassDefinition*)classDefinition toTargets:(NSArray*)targets {
    [self addClass:classDefinition];
    SourceFile* sourceFile = [_project fileWithName:[classDefinition sourceFileName]];
    [self addSourceFile:sourceFile toTargets:targets];
}

- (void) addFramework:(FrameworkDefinition*)frameworkDefinition {
    if (([self memberWithDisplayName:[frameworkDefinition name]]) == nil) {
        LogDebug(@"Here we go!!!!");
        NSDictionary* fileReference;
        if ([frameworkDefinition copyToDestination]) {
            LogDebug(@"Making file reference");
            fileReference = [self makeFileReferenceWithPath:[frameworkDefinition name] name:nil type:Framework];
            BOOL copyFramework = NO;
            if ([frameworkDefinition fileOperationStyle] == FileOperationStyleOverwrite) {
                copyFramework = YES;
            }
            else if ([frameworkDefinition fileOperationStyle] == FileOperationStyleAcceptExisting) {
                NSString* frameworkName = [[frameworkDefinition filePath] lastPathComponent];
                if (![_fileOperationQueue
                        fileWithName:frameworkName existsInProjectDirectory:[self pathRelativeToProjectRoot]]) {
                    copyFramework = YES;
                }

            }
            if (copyFramework) {
                [_fileOperationQueue queueFrameworkWithFilePath:[frameworkDefinition filePath]
                        inDirectory:[self pathRelativeToProjectRoot]];
            }
        }
        else {
            NSString* path = [frameworkDefinition filePath];
            NSString* name = [frameworkDefinition name];
            fileReference = [self makeFileReferenceWithPath:path name:name type:Framework];
        }
        LogDebug(@"Make framework key");
        NSString* frameworkKey = [[KeyBuilder forItemNamed:[frameworkDefinition name]] build];
        [[_project objects] setObject:fileReference forKey:frameworkKey];
        [self addMemberWithKey:frameworkKey];
    }
    [[_project objects] setObject:[self asDictionary] forKey:_key];
}


- (void) addFramework:(FrameworkDefinition*)frameworkDefinition toTargets:(NSArray*)targets {
    [self addFramework:frameworkDefinition];
    SourceFile* frameworkSourceRef = (SourceFile*) [self memberWithDisplayName:[frameworkDefinition name]];
    [self addSourceFile:frameworkSourceRef toTargets:targets];
}

- (xcode_Group*) addGroupWithPath:(NSString*)path {
    NSString* groupKey = [[KeyBuilder forItemNamed:path] build];

    NSArray* members = [self members];
    for (id<XcodeGroupMember> groupMember in members) {
        if ([groupMember groupMemberType] == PBXGroup) {

            if ([[[groupMember pathRelativeToProjectRoot] lastPathComponent] isEqualToString:path] ||
                    [[groupMember displayName] isEqualToString:path] || [[groupMember key] isEqualToString:groupKey]) {
                return nil;
            }
        }
    }

    Group* group = [[Group alloc] initWithProject:_project key:groupKey alias:nil path:path children:nil];
    NSDictionary* groupDict = [group asDictionary];

    [[_project objects] setObject:groupDict forKey:groupKey];
    [_fileOperationQueue queueDirectory:path inDirectory:[self pathRelativeToProjectRoot]];
    [self addMemberWithKey:groupKey];

    NSDictionary* dict = [self asDictionary];
    [[_project objects] setObject:dict forKey:_key];

    return group;
}

- (void) addSourceFile:(SourceFileDefinition*)sourceFileDefinition {
    [self makeGroupMemberWithName:[sourceFileDefinition sourceFileName] contents:[sourceFileDefinition data]
            type:[sourceFileDefinition type] fileOperationStyle:[sourceFileDefinition fileOperationStyle]];
    [[_project objects] setObject:[self asDictionary] forKey:_key];
}

- (void) addXib:(XibDefinition*)xibDefinition {
    [self makeGroupMemberWithName:[xibDefinition xibFileName] contents:[xibDefinition content] type:XibFile
            fileOperationStyle:[xibDefinition fileOperationStyle]];
    [[_project objects] setObject:[self asDictionary] forKey:_key];
}

- (void) addXib:(XibDefinition*)xibDefinition toTargets:(NSArray*)targets {
    [self addXib:xibDefinition];
    SourceFile* sourceFile = [_project fileWithName:[xibDefinition xibFileName]];
    [self addSourceFile:sourceFile toTargets:targets];
}

/* ================================================================================================================== */
#pragma mark Members

- (NSArray*) members {
    if (_members == nil) {
        _members = [[NSMutableArray alloc] init];
        for (NSString* childKey in _children) {
            XcodeMemberType type = [self typeForKey:childKey];
            if (type == PBXGroup) {
                [_members addObject:[_project groupWithKey:childKey]];
            }
            else if (type == PBXFileReference) {
                [_members addObject:[_project fileWithKey:childKey]];
            }
        }
    }
    NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    return [_members sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}

- (NSArray*) recursiveMembers {
    NSMutableArray* recursiveMembers = [NSMutableArray array];
    for (NSString* childKey in _children) {
        XcodeMemberType type = [self typeForKey:childKey];
        if (type == PBXGroup) {
            Group* group = [_project groupWithKey:childKey];
            NSArray* groupChildren = [group recursiveMembers];
            [recursiveMembers addObjectsFromArray:groupChildren];
        }
        else if (type == PBXFileReference) {
            [recursiveMembers addObject:childKey];
        }
    }
    return [recursiveMembers arrayByAddingObjectsFromArray:recursiveMembers];
}

- (NSArray*) buildFileKeys {

    NSMutableArray* arrayOfBuildFileKeys = [NSMutableArray array];
    for (id<XcodeGroupMember> groupMember in [self members]) {

        if ([groupMember groupMemberType] == PBXGroup) {
            Group* group = (Group*) groupMember;
            [arrayOfBuildFileKeys addObjectsFromArray:[group buildFileKeys]];
        }
        else if ([groupMember groupMemberType] == PBXFileReference) {
            [arrayOfBuildFileKeys addObject:[groupMember key]];
        }
    }
    return arrayOfBuildFileKeys;
}

- (id<XcodeGroupMember>) memberWithKey:(NSString*)key {
    id<XcodeGroupMember> groupMember = nil;

    if ([_children containsObject:key]) {
        XcodeMemberType type = [self typeForKey:key];
        if (type == PBXGroup) {
            groupMember = [_project groupWithKey:key];
        }
        else if (type == PBXFileReference) {
            groupMember = [_project fileWithKey:key];
        }
    }
    return groupMember;
}

- (id<XcodeGroupMember>) memberWithDisplayName:(NSString*)name {
    for (id<XcodeGroupMember> member in [self members]) {
        if ([[member displayName] isEqualToString:name]) {
            return member;
        }
    }
    return nil;
}

/* ================================================= Protocol Methods =============================================== */
- (XcodeMemberType) groupMemberType {
    return PBXGroup;
}

- (NSString*) displayName {
    if (_pathRelativeToParent == nil) {
        return _alias;
    }
    else {
        return [_pathRelativeToParent lastPathComponent];
    }
}

- (NSString*) pathRelativeToProjectRoot {
    if (_pathRelativeToProjectRoot == nil) {
        NSMutableArray* pathComponents = [[NSMutableArray alloc] init];
        Group* group;
        NSString* key = _key;

        while ((group = [_project groupForGroupMemberWithKey:key]) != nil && !([group pathRelativeToParent] == nil)) {
            [pathComponents addObject:[group pathRelativeToParent]];
            key = [group key];
        }

        NSMutableString* fullPath = [[NSMutableString alloc] init];
        for (int i = [pathComponents count] - 1; i >= 0; i--) {
            [fullPath appendFormat:@"%@/", [pathComponents objectAtIndex:i]];
        }
        _pathRelativeToProjectRoot = [fullPath stringByAppendingPathComponent:_pathRelativeToParent];
    }
    return _pathRelativeToProjectRoot;
}

/* ================================================== Utility Methods =============================================== */
- (NSString*) description {
    return [NSString stringWithFormat:@"Group: displayName = %@, key=%@", [self displayName], _key];
}

/* ================================================== Private Methods =============================================== */
#pragma mark Private
- (void) addMemberWithKey:(NSString*)key {

    for (NSString* childKey in _children) {
        if ([childKey isEqualToString:key]) {
            [self flagMembersAsDirty];
            return;
        }
    }
    [_children addObject:key];
    [self flagMembersAsDirty];
}

- (void) flagMembersAsDirty {
    _members = nil;
}

/* ================================================================================================================== */

- (void) makeGroupMemberWithName:(NSString*)name contents:(id)contents type:(XcodeSourceFileType)type
        fileOperationStyle:(XcodeFileOperationStyle)fileOperationStyle {

    NSString* filePath;
    SourceFile* currentSourceFile = (SourceFile*) [self memberWithDisplayName:name];
    if ((currentSourceFile) == nil) {
        NSDictionary* reference = [self makeFileReferenceWithPath:name name:nil type:type];
        NSString* fileKey = [[KeyBuilder forItemNamed:name] build];
        [[_project objects] setObject:reference forKey:fileKey];
        [self addMemberWithKey:fileKey];
        filePath = [self pathRelativeToProjectRoot];
    }
    else {
        filePath = [[currentSourceFile pathRelativeToProjectRoot] stringByDeletingLastPathComponent];
    }

    BOOL writeFile = NO;
    if (fileOperationStyle == FileOperationStyleOverwrite) {
        writeFile = YES;
        if ([_fileOperationQueue fileWithName:name existsInProjectDirectory:filePath]) {
            LogInfo(@"*** WARNING *** Group %@ already contains member with name %@. Contents will be updated", [self
                    displayName], name);
        }
    }
    else if (fileOperationStyle == FileOperationStyleAcceptExisting &&
            ![_fileOperationQueue fileWithName:name existsInProjectDirectory:filePath]) {
        writeFile = YES;
    }
    if (writeFile) {
        if ([contents isKindOfClass:[NSString class]]) {
            [_fileOperationQueue queueTextFile:name inDirectory:filePath withContents:contents];
        }
        else {
            [_fileOperationQueue queueDataFile:name inDirectory:filePath withContents:contents];
        }
    }
}

/* ================================================================================================================== */
#pragma mark Dictionary Representations

- (NSDictionary*) makeFileReferenceWithPath:(NSString*)path name:(NSString*)name type:(XcodeSourceFileType)type {
    NSMutableDictionary* reference = [NSMutableDictionary dictionary];
    [reference setObject:[NSString stringFromMemberType:PBXFileReference] forKey:@"isa"];
    [reference setObject:@"4" forKey:@"FileEncoding"];
    [reference setObject:[NSString stringFromSourceFileType:type] forKey:@"lastKnownFileType"];
    if (name != nil) {
        [reference setObject:[name lastPathComponent] forKey:@"name"];
    }
    if (path != nil) {
        [reference setObject:path forKey:@"path"];
    }
    [reference setObject:@"<group>" forKey:@"sourceTree"];
    return reference;
}


- (NSDictionary*) asDictionary {
    NSMutableDictionary* groupData = [[NSMutableDictionary alloc] init];
    [groupData setObject:[NSString stringFromMemberType:PBXGroup] forKey:@"isa"];
    [groupData setObject:@"<group>" forKey:@"sourceTree"];

    if (_alias != nil) {
        [groupData setObject:_alias forKey:@"name"];
    }

    if (_pathRelativeToParent) {
        [groupData setObject:_pathRelativeToParent forKey:@"path"];
    }

    [groupData setObject:_children forKey:@"children"];
    return groupData;
}

- (XcodeMemberType) typeForKey:(NSString*)key {
    NSDictionary* obj = [[_project objects] valueForKey:key];
    return [[obj valueForKey:@"isa"] asMemberType];
}

- (void) addSourceFile:(SourceFile*)sourceFile toTargets:(NSArray*)targets {
    LogDebug(@"Adding source file %@ to targets %@", sourceFile, targets);
    for (Target* target in targets) {
        [target addMember:sourceFile];
    }
}

@end