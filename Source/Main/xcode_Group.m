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
#import "xcode_KeyBuilder.h"

#import "Logging.h"
/* ================================================================================================================== */
@interface xcode_Group ()

- (void) addMemberWithKey:(NSString*)key;

- (void) flagMembersAsDirty;

- (NSDictionary*) makeFileReferenceWithPath:(NSString*)path name:(NSString*)name type:(XcodeSourceFileType)type;

- (void) referenceAndQueue:(NSString*)name contents:(NSString*)contents type:(XcodeSourceFileType)type;

- (NSDictionary*) asDictionary;

- (XcodeMemberType) typeForKey:(NSString*)key;

- (void) addSourceFile:(SourceFile*)sourceFile toTargets:(NSArray*)targets;

- (void) warnPendingOverwrite:(NSString*)resourceName;


@end
/* ================================================================================================================== */

@implementation xcode_Group

@synthesize project = _project;
@synthesize pathRelativeToParent = _pathRelativeToParent;
@synthesize key = _key;
@synthesize children = _children;
@synthesize alias = _alias;


/* ================================================= Class Methods ================================================== */
+ (Group*) groupWithProject:(xcode_Project*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path
        tree:(NSString*)tree children:(NSArray*)children {

    return [[[Group alloc] initWithProject:project key:key alias:alias path:path children:children] autorelease];
}

/* ================================================== Initializers ================================================== */
- (id) initWithProject:(xcode_Project*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path
        children:(NSMutableArray*)children {
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
#pragma mark Super (parent) group

- (void) removeFromSuperGroup {
    [self removeFromSuperGroup:NO];
}


- (void) removeFromSuperGroup:(BOOL)deleteChildren {
    LogDebug(@"Removing group %@", [self pathRelativeToProjectRoot]);
    if (deleteChildren) {
        LogDebug(@"Deleting children");
        for (id<XcodeGroupMember> groupMember in [self members]) {
            if ([groupMember groupMemberType] == PBXGroup) {
                Group* group = (Group*) groupMember;
                [group removeFromSuperGroup:YES];
                LogDebug(@"My full path is : %@", [group pathRelativeToProjectRoot]);

            }
            else {
                [_fileOperationQueue queueDeletion:[groupMember pathRelativeToProjectRoot]];
            }
        }
    }
//    [self removeMemberWithKey:_key];
    [[_project objects] removeObjectForKey:_key];
}

- (xcode_Group*) superGroup {
    return [_project groupForGroupMemberWithKey:_key];
}

- (BOOL) isRootGroup {
    return [self pathRelativeToParent] == nil && [self displayName] == nil;
}


/* ================================================================================================================== */
#pragma mark Adding children

- (void) addClass:(ClassDefinition*)classDefinition {
    [self referenceAndQueue:[classDefinition headerFileName] contents:[classDefinition header] type:SourceCodeHeader];

    if ([classDefinition isObjectiveC]) {
        [self referenceAndQueue:[classDefinition sourceFileName] contents:[classDefinition source] type:SourceCodeObjC];
    }
    else if ([classDefinition isObjectiveCPlusPlus]) {
        [self referenceAndQueue:[classDefinition sourceFileName] contents:[classDefinition source]
                type:SourceCodeObjCPlusPlus];
    }
    [[_project objects] setObject:[self asDictionary] forKey:_key];
}


- (void) addClass:(ClassDefinition*)classDefinition toTargets:(NSArray*)targets {
    [self addClass:classDefinition];
    SourceFile* sourceFile = [_project fileWithName:[classDefinition sourceFileName]];
    [self addSourceFile:sourceFile toTargets:targets];
}

- (void) addXib:(XibDefinition*)xibDefinition {
    [self referenceAndQueue:[xibDefinition xibFileName] contents:[xibDefinition content] type:XibFile];
    [[_project objects] setObject:[self asDictionary] forKey:_key];
}

- (void) addXib:(XibDefinition*)xibDefinition toTargets:(NSArray*)targets {
    [self addXib:xibDefinition];
    SourceFile* sourceFile = [_project fileWithName:[xibDefinition xibFileName]];
    [self addSourceFile:sourceFile toTargets:targets];
}


- (void) addFramework:(FrameworkDefinition*)frameworkDefinition {
    if (([self memberWithDisplayName:[frameworkDefinition name]]) == nil) {
        NSDictionary* fileReference;
        if ([frameworkDefinition copyToDestination]) {
            fileReference = [self makeFileReferenceWithPath:[frameworkDefinition name] name:nil type:Framework];
            [_fileOperationQueue queueFrameworkWithFilePath:[frameworkDefinition filePath]
                    inDirectory:[self pathRelativeToProjectRoot]];
        }
        else {
            NSString* path = [frameworkDefinition filePath];
            NSString* name = [frameworkDefinition name];
            fileReference = [self makeFileReferenceWithPath:path name:name type:Framework];
        }
        NSString* frameworkKey = [[KeyBuilder forItemNamed:[frameworkDefinition name]] build];
        [[_project objects] setObject:fileReference forKey:frameworkKey];
        [self addMemberWithKey:frameworkKey];
    }
    else {
        [self warnPendingOverwrite:[frameworkDefinition filePath]];
    }
    [[_project objects] setObject:[self asDictionary] forKey:_key];
}

- (void) addFramework:(FrameworkDefinition*)frameworkDefinition toTargets:(NSArray*)targets {
    [self addFramework:frameworkDefinition];
    [self addSourceFile:[self memberWithDisplayName:[frameworkDefinition name]] toTargets:targets];
}

- (xcode_Group*) addGroupWithPath:(NSString*)path {
    NSString* groupKey = [[KeyBuilder forItemNamed:path] build];


//    NSArray* groups = [[self project] groups];
//    for(xcode_Group* gr in groups){
//        if([[gr pathRelativeToParent] isEqualToString:path]){
//            return nil;
//        }
//    }

    NSArray* members = [self members];
    for (id<XcodeGroupMember> groupMember in members) {
        if ([groupMember groupMemberType] == PBXGroup) {
            //NSLog(@"PATH IN SUBGROUPS %@ %@", [groupMember pathRelativeToProjectRoot], [groupMember displayName]);

            if ([[[groupMember pathRelativeToProjectRoot] lastPathComponent] isEqualToString:path] ||
                    [[groupMember displayName] isEqualToString:path] || [[groupMember key] isEqualToString:groupKey]) {
                return nil;
            }
        }
    }

    Group* group = [[[Group alloc] initWithProject:_project key:groupKey alias:nil path:path children:nil] autorelease];

    NSDictionary* groupDict = [group asDictionary];

    //  LogDebug(@"Here's the group: %@", groupDict);

    [[_project objects] setObject:groupDict forKey:groupKey];
    [_fileOperationQueue queueDirectory:path inDirectory:[self pathRelativeToProjectRoot]];
    [self addMemberWithKey:groupKey];

    NSDictionary* dict = [self asDictionary];
    [[_project objects] setObject:dict forKey:_key];

    return group;
}

/* ================================================================================================================== */
#pragma mark Locating children
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


- (NSArray*) buildFileKeys {

    NSMutableArray* arrayOfBuildFileKeys = [NSMutableArray array];
    for (id<XcodeGroupMember> groupMember in [self members]) {
//        <key>bb33e8926797197e8ed55d7a</key>
//		<dict>
//        <key>fileRef</key>
//        <string>053e5d40521df6331e6cbd57</string>
//        <key>isa</key>
//        <string>PBXBuildFile</string>
//		</dict>

        if ([[groupMember key] isEqualToString:@"053e5d40521df6331e6cbd57"]) {
            NSLog(@"WE FOUND FILEREF KEY");
        }

        if ([[groupMember key] isEqualToString:@"bb33e8926797197e8ed55d7a"]) {
            NSLog(@"WE FOUND PBXBUILDFILE KEY");
        }


        if ([groupMember groupMemberType] == PBXGroup) {
            Group* group = (Group*) groupMember;
            [arrayOfBuildFileKeys addObjectsFromArray:[group buildFileKeys]];
        }
//        else if([groupMember groupMemberType] == PBXBuildFile)
//        {
//            //NSLog(@"WE HAVE BUILD FILE %@", [groupMember key]);
//            [arrayOfBuildFileKeys addObject:[groupMember key]];
//        }
        else if ([groupMember groupMemberType] == PBXFileReference) {
            //  NSLog(@"WE HAVE REFERENCE %@", [groupMember key]);
            [arrayOfBuildFileKeys addObject:[groupMember key]];
        }
        else {
            //NSLog(@"WE HAVE ANOTHER FILE TYPE %d", [groupMember groupMemberType]);
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

- (void) dealloc {

    [_pathRelativeToParent release];
    [_key release];
    [_alias release];
    [super dealloc];
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

//- (void) removeMemberWithKey:(NSString*)key{
//    NSMutableArray* array = [NSMutableArray array];
//    for(NSString* child in _children){
//        if([child isEqualToString:key]){
//            [array addObject:child];
//        }
//    }
//    [_children removeObjectsInArray:array];
//    [array removeAllObjects];
//    [self flagMembersAsDirty];
//}


- (void) flagMembersAsDirty {
    _members = nil;
}

- (void) referenceAndQueue:(NSString*)name contents:(NSString*)contents type:(XcodeSourceFileType)type {
    NSString* filePath;
    SourceFile* currentSourceFile = [self memberWithDisplayName:name];
    if ((currentSourceFile) == nil) {
        NSDictionary* reference = [self makeFileReferenceWithPath:name name:nil type:type];
        NSString* fileKey = [[KeyBuilder forItemNamed:name] build];
        [[_project objects] setObject:reference forKey:fileKey];
        [self addMemberWithKey:fileKey];
        filePath = [self pathRelativeToProjectRoot];
    }
    else {
        [self warnPendingOverwrite:name];
        filePath = [[currentSourceFile pathRelativeToProjectRoot] stringByDeletingLastPathComponent];
    }
    //[_fileOperationQueue queueWrite:name inDirectory:filePath withContents:contents];
}

- (NSDictionary*) makeFileReferenceWithPath:(NSString*)path name:(NSString*)name type:(XcodeSourceFileType)type {
    NSMutableDictionary* reference = [[NSMutableDictionary alloc] init];
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
    NSMutableDictionary* groupData = [[[NSMutableDictionary alloc] init] autorelease];
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

- (void) warnPendingOverwrite:(NSString*)resourceName {
    LogInfo(@"*** WARNING *** Group %@ already contains member with name %@. Contents will be updated", [self
            displayName], resourceName);
}


@end