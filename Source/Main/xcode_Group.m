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
#import "xcode_FileWriteQueue.h"
#import "xcode_XibDefinition.h"
#import "xcode_SourceFile.h"
#import "xcode_Group.h"
#import "xcode_Project.h"
#import "xcode_ClassDefinition.h"
#import "xcode_KeyBuilder.h"

@interface xcode_Group (private)

- (void) addMemberWithKey:(NSString*)key;

- (void) flagMembersAsDirty;

- (NSDictionary*) makeFileReferenceWithPath:(NSString*)path type:(XcodeSourceFileType)type;

- (NSDictionary*) makeFileReferenceWithPath:(NSString*)path name:(NSString*)name type:(XcodeSourceFileType)type;

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


/* ================================================== Initializers ================================================== */
- (id) initWithProject:(xcode_Project*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path
        children:(NSArray*)children {
    self = [super init];
    if (self) {
        _project = project;
        _writeQueue = [_project fileWriteQueue];
        _key = [key copy];
        _alias = [alias copy];
        _pathRelativeToParent = [path copy];
        _children = [[NSMutableArray alloc] init];
        [_children addObjectsFromArray:children];
    }
    return self;
}

/* ================================================ Interface Methods =============================================== */
#pragma mark Adding children
- (void) addClass:(ClassDefinition*)classDefinition {

    SourceFile* currentHeaderFile = [self memberWithDisplayName:[classDefinition headerFileName]];
    if ((currentHeaderFile) == nil) {
        NSDictionary* header = [self makeFileReferenceWithPath:[classDefinition headerFileName] type:SourceCodeHeader];
        NSString* headerKey = [[KeyBuilder forItemNamed:[classDefinition headerFileName]] build];
        [[_project objects] setObject:header forKey:headerKey];
        [self addMemberWithKey:headerKey];
        [_writeQueue queueFile:[classDefinition headerFileName] inDirectory:[self pathRelativeToProjectRoot]
                withContents:[classDefinition source]];
    }
    else {
        [self warnPendingOverwrite:[classDefinition headerFileName]];
        [_writeQueue queueFile:[classDefinition headerFileName]
                inDirectory:[[currentHeaderFile sourcePath] stringByDeletingLastPathComponent]
                withContents:[classDefinition source]];
    }

    SourceFile* currentSourceFile = [self memberWithDisplayName:[classDefinition sourceFileName]];
    if ((currentSourceFile) == nil) {
        NSDictionary* source = [self makeFileReferenceWithPath:[classDefinition sourceFileName] type:SourceCodeObjC];
        NSString* sourceKey = [[KeyBuilder forItemNamed:[classDefinition sourceFileName]] build];
        [[_project objects] setObject:source forKey:sourceKey];
        [self addMemberWithKey:sourceKey];
        [_writeQueue queueFile:[classDefinition sourceFileName] inDirectory:[self pathRelativeToProjectRoot]
                withContents:[classDefinition source]];
    }
    else {
        [self warnPendingOverwrite:[classDefinition sourceFileName]];
        [_writeQueue queueFile:[classDefinition sourceFileName]
                inDirectory:[[currentSourceFile sourcePath] stringByDeletingLastPathComponent]
                withContents:[classDefinition source]];
    }
    [[_project objects] setObject:[self asDictionary] forKey:_key];
}

- (void) addClass:(ClassDefinition*)classDefinition toTargets:(NSArray*)targets {
    [self addClass:classDefinition];
    SourceFile* sourceFile = [_project fileWithName:[classDefinition sourceFileName]];
    [self addSourceFile:sourceFile toTargets:targets];
}

- (void) addXib:(XibDefinition*)xibDefinition {
    SourceFile* currentXibFile = [self memberWithDisplayName:[xibDefinition xibFileName]];
    if (currentXibFile == nil) {
        NSDictionary* xib = [self makeFileReferenceWithPath:[xibDefinition xibFileName] type:XibFile];
        NSString* xibKey = [[KeyBuilder forItemNamed:[xibDefinition xibFileName]] build];
        [[_project objects] setObject:xib forKey:xibKey];
        [self addMemberWithKey:xibKey];
        [_writeQueue queueFile:[xibDefinition xibFileName] inDirectory:[self pathRelativeToProjectRoot]
                withContents:[xibDefinition content]];
    }
    else {
        [self warnPendingOverwrite:[xibDefinition xibFileName]];
        [_writeQueue queueFile:[xibDefinition xibFileName]
                inDirectory:[[currentXibFile sourcePath] stringByDeletingLastPathComponent]
                withContents:[xibDefinition content]];
    }
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
            fileReference = [self makeFileReferenceWithPath:[frameworkDefinition name] type:Framework];
            [_writeQueue queueFrameworkWithFilePath:[frameworkDefinition filePath]
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


/* ================================================================================================================== */
#pragma mark File paths

- (NSString*) pathRelativeToProjectRoot {
    if (_pathRelativeToProjectRoot == nil) {
        NSMutableArray* pathComponents = [[NSMutableArray alloc] init];
        Group* group;
        NSString* key = _key;

        while ((group = [_project groupForGroupMemberWithKey:key]) != nil && [group pathRelativeToParent] != nil) {
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


/* ================================================== Utility Methods =============================================== */
- (NSString*) description {
    return [NSString stringWithFormat:@"Group: displayName = %@, key=%@", [self displayName], _key];
}

/* ================================================== Private Methods =============================================== */
#pragma mark Private
- (void) addMemberWithKey:(NSString*)key {
    [_children addObject:key];
    [self flagMembersAsDirty];
}

- (void) flagMembersAsDirty {
    _members = nil;
}

- (NSDictionary*) makeFileReferenceWithPath:(NSString*)path type:(XcodeSourceFileType)type {
    return [self makeFileReferenceWithPath:path name:nil type:type];
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
    NSMutableDictionary* groupData = [[NSMutableDictionary alloc] init];
    [groupData setObject:[NSString stringFromMemberType:PBXGroup] forKey:@"isa"];
    [groupData setObject:@"<group>" forKey:@"sourceTree"];
    if (_alias != nil) {
        [groupData setObject:_alias forKey:@"name"];
    }
    [groupData setObject:_pathRelativeToParent forKey:@"path"];
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