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
@synthesize tree = _tree;

/* ================================================== Initializers ================================================== */
- (id) initWithProject:(xcode_Project*)project 
				   key:(NSString*)key 
				 alias:(NSString*)alias 
				  path:(NSString*)path
				  tree:(NSString*)tree
			  children:(NSArray*)children {
	
    self = [super init];
    if (self) {
        _project = project;
        _fileOperationQueue = [_project fileWriteQueue];
        _key = [key copy];
        _alias = [alias copy];
		if( [tree length] ) { _tree = [tree copy]; } else { _tree = @"<group>"; }
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
    [self referenceAndQueue:[classDefinition sourceFileName] contents:[classDefinition source] type:SourceCodeObjC];
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

- (void) addGroupWithPath:(NSString*)path {
    NSString* groupKey = [[KeyBuilder forItemNamed:path] build];
    Group* group = [[Group alloc] initWithProject:_project key:groupKey alias:nil path:path tree:@"" children:nil];
    LogDebug(@"Here's the group: %@", [group asDictionary]);
    [[_project objects] setObject:[group asDictionary] forKey:groupKey];
    [_fileOperationQueue queueDirectory:path inDirectory:[self pathRelativeToProjectRoot]];
    [self addMemberWithKey:groupKey];
    [[_project objects] setObject:[self asDictionary] forKey:_key];
}

- (void) addGroupWithPath:(NSString*)path alias:(NSString*)alias {
    NSString* groupKey = [[KeyBuilder forItemNamed:path] build];
    Group* group = [[Group alloc] initWithProject:_project key:groupKey alias:alias path:path tree:@"SOURCE_ROOT" children:nil];
    LogDebug(@"Here's the group: %@", [group asDictionary]);
    [[_project objects] setObject:[group asDictionary] forKey:groupKey];
    [_fileOperationQueue queueDirectory:path inDirectory:[self pathRelativeToProjectRoot]];
    [self addMemberWithKey:groupKey];
    [[_project objects] setObject:[self asDictionary] forKey:_key];
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
		BOOL foundSourceRoot = NO;

		for( xcode_Group *group = self; group != nil; group = [_project groupForGroupMemberWithKey:group.key] ) {
			LogDebug(@"Key: %@; Name: %@; Tree: %@; Path: %@", group.key, group.alias, group.tree, group.pathRelativeToParent);

			if( [group pathRelativeToParent] != nil ) {
				[pathComponents addObject:[group pathRelativeToParent]];
			}
			
			if( [group.tree isEqualToString:@"SOURCE_ROOT"] ) {
				foundSourceRoot = YES;
				break;
			}
        }

        NSMutableString* fullPath = [[NSMutableString alloc] init];
		for (int i = [pathComponents count] - 1; i >= 0; i--) {
			[fullPath appendFormat:@"%@/", [pathComponents objectAtIndex:i]];
		}
        _pathRelativeToProjectRoot = fullPath;
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
    [_children addObject:key];
    [self flagMembersAsDirty];
}

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
    [_fileOperationQueue queueWrite:name inDirectory:filePath withContents:contents];
}

- (xcode_SourceFile*)reference:(NSString*)name relativePath:(NSString*)path type:(XcodeSourceFileType)type {
	SourceFile* currentSourceFile = [self memberWithDisplayName:name];
    if ((currentSourceFile) == nil) {
        NSDictionary* reference = [self makeFileReferenceWithPath:path name:path type:type];
        NSString* fileKey = [[KeyBuilder forItemNamed:name] build];
        [[_project objects] setObject:reference forKey:fileKey];
        [self addMemberWithKey:fileKey];
		currentSourceFile = [self memberWithKey:fileKey];
		[[_project objects] setObject:[self asDictionary] forKey:_key];
    }
	return currentSourceFile;
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
    [reference setObject:self.tree forKey:@"sourceTree"];
    return reference;
}


- (NSDictionary*) asDictionary {
    NSMutableDictionary* groupData = [[NSMutableDictionary alloc] init];
    [groupData setObject:[NSString stringFromMemberType:PBXGroup] forKey:@"isa"];
    [groupData setObject:self.tree forKey:@"sourceTree"];
    if (_alias != nil) {
        [groupData setObject:_alias forKey:@"name"];
    }
	if( _pathRelativeToParent ) {
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