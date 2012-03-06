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

#import "xcode_Target.h"
#import "xcode_FileWriteQueue.h"
#import "xcode_XibDefinition.h"
#import "xcode_SourceFile.h"
#import "xcode_Group.h"
#import "xcode_Project.h"
#import "xcode_ClassDefinition.h"
#import "xcode_KeyBuilder.h"

@interface xcode_Group (private)

- (void) addChildWithKey:(NSString*)key;

- (NSDictionary*) makeFileReference:(NSString*)name type:(XcodeSourceFileType)type;

- (NSDictionary*) asDictionary;

- (XcodeMemberType) typeForKey:(NSString*)key;

- (void) addFile:(SourceFile*)sourceFile toTargets:(NSArray*)targets;

@end

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
    NSDictionary* header = [self makeFileReference:[classDefinition headerFileName] type:SourceCodeHeader];
    NSString* headerKey = [[KeyBuilder forItemNamed:[classDefinition headerFileName]] build];
    [[_project objects] setObject:header forKey:headerKey];

    NSDictionary* source = [self makeFileReference:[classDefinition sourceFileName] type:SourceCodeObjC];
    NSString* sourceKey = [[KeyBuilder forItemNamed:[classDefinition sourceFileName]] build];
    [[_project objects] setObject:source forKey:sourceKey];

    [self addChildWithKey:headerKey];
    [self addChildWithKey:sourceKey];
    [[_project objects] setObject:[self asDictionary] forKey:_key];

    [_writeQueue queueFile:[classDefinition headerFileName] inDirectory:[self pathRelativeToProjectRoot]
            withContents:[classDefinition header]];
    [_writeQueue queueFile:[classDefinition sourceFileName] inDirectory:[self pathRelativeToProjectRoot]
            withContents:[classDefinition source]];
}

- (void) addClass:(ClassDefinition*)classDefinition toTargets:(NSArray*)targets {
    [self addClass:classDefinition];
    SourceFile* sourceFile = [_project fileWithName:[classDefinition sourceFileName]];
    [self addFile:sourceFile toTargets:targets];
}

- (void) addXib:(XibDefinition*)xibDefinition {
    NSDictionary* xib = [self makeFileReference:[xibDefinition name] type:XibFile];
    NSString* xibKey = [[KeyBuilder forItemNamed:[xibDefinition name]] build];
    [[_project objects] setObject:xib forKey:xibKey];

    [self addChildWithKey:xibKey];
    [[_project objects] setObject:[self asDictionary] forKey:_key];

    [_writeQueue queueFile:[xibDefinition name] inDirectory:[self pathRelativeToProjectRoot]
            withContents:[xibDefinition content]];
}

- (void) addXib:(xcode_XibDefinition*)xibDefinition toTargets:(NSArray*)targets {
    [self addXib:xibDefinition];
    SourceFile* sourceFile = [_project fileWithName:[xibDefinition name]];
    [self addFile:sourceFile toTargets:targets];
}



/* ================================================================================================================== */
#pragma mark Locating children
- (NSArray*) members {
    NSMutableArray* children = [[NSMutableArray alloc] init];
    for (NSString* childKey in _children) {
        XcodeMemberType type = [self typeForKey:childKey];
        if (type == PBXGroup) {
            [children addObject:[_project groupWithKey:childKey]];
        }
        else if (type == PBXFileReference) {
            [children addObject:[_project fileWithKey:childKey]];
        }
    }
    NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    return [children sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
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
- (void) addChildWithKey:(NSString*)key {
    if (![_children containsObject:key]) {
        [_children addObject:key];
    }
}

- (NSDictionary*) makeFileReference:(NSString*)name type:(XcodeSourceFileType)type {
    NSMutableDictionary* reference = [[NSMutableDictionary alloc] init];
    [reference setObject:[NSString stringFromMemberType:PBXFileReference] forKey:@"isa"];
    [reference setObject:@"4" forKey:@"FileEncoding"];
    [reference setObject:[NSString stringFromSourceFileType:type] forKey:@"lastKnownFileType"];
    [reference setObject:name forKey:@"path"];
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

- (void) addFile:(SourceFile*)sourceFile toTargets:(NSArray*)targets {
    LogDebug(@"Adding source file %@ to targets %@", sourceFile, targets);
    for (Target* target in targets) {
        [target addMember:sourceFile];
    }
}


@end