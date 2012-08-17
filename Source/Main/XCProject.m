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

#import "XCProject.h"
#import "XCGroup.h"
#import "XCSourceFile.h"
#import "XCTarget.h"
#import "XCFileOperationQueue.h"
#import "OCLogTemplate.h"


/* ================================================================================================================== */
@interface XCProject (Private)

- (NSArray*) projectFilesOfType:(XcodeSourceFileType)fileReferenceType;

- (NSString*) makeContainerItemProxyForName:(NSString*)name fileRef:(NSString*)fileRef proxyType:(NSString*)proxyType
        uniqueName:(NSString*)uniqueName;

- (NSString*) makeTargetDependency:(NSString*)name forContainerItemProxyKey:(NSString*)containerItemProxyKey
        uniqueName:(NSString*)uniqueName;

@end


@implementation XCProject


@synthesize fileOperationQueue = _fileOperationQueue;

/* ================================================= Class Methods ================================================== */
+ (XCProject*) projectWithFilePath:(NSString*)filePath {
    return [[XCProject alloc] initWithFilePath:filePath];
}


/* ================================================== Initializers ================================================== */
- (id) initWithFilePath:(NSString*)filePath {
    
    self = [super init];
    
    if (self) {
        _filePath = [filePath copy];
        _dataStore = [[NSMutableDictionary alloc]
                initWithContentsOfFile:[_filePath stringByAppendingPathComponent:@"project.pbxproj"]];

        if (!_dataStore) {
            [NSException raise:NSInvalidArgumentException format:@"Project file not found at file path %@", _filePath];
        }
        _fileOperationQueue =
                [[XCFileOperationQueue alloc] initWithBaseDirectory:[_filePath stringByDeletingLastPathComponent]];
    }
    return self;
}


/* ================================================ Interface Methods =============================================== */

#pragma mark Files

- (NSArray*) files {
    NSMutableArray* results = [NSMutableArray array];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXFileReference) {
            XcodeSourceFileType fileType = [[obj valueForKey:@"lastKnownFileType"] asSourceFileType];
            NSString* path = [obj valueForKey:@"path"];
            NSString* sourceTree = [obj valueForKey:@"sourceTree"];
            [results addObject:[XCSourceFile sourceFileWithProject:self key:key type:fileType name:path
                                       sourceTree:(sourceTree ? sourceTree : @"<group>")]];
        }
    }];
    NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [results sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}

- (XCSourceFile*) fileWithKey:(NSString*)key {
    NSDictionary* obj = [[self objects] valueForKey:key];
    if (obj && [[obj valueForKey:@"isa"] asMemberType] == PBXFileReference) {
        XcodeSourceFileType fileType = [[obj valueForKey:@"lastKnownFileType"] asSourceFileType];

        NSString* name = [obj valueForKey:@"name"];
        NSString* sourceTree = [obj valueForKey:@"sourceTree"];

        if (name == nil) {
            name = [obj valueForKey:@"path"];
        }
        return [XCSourceFile sourceFileWithProject:self key:key type:fileType name:name
                sourceTree:(sourceTree ? sourceTree : @"<group>")];
    }
    return nil;
}

- (XCSourceFile*) fileWithName:(NSString*)name {
    for (XCSourceFile* projectFile in [self files]) {
        if ([[projectFile name] isEqualToString:name]) {
            return projectFile;
        }
    }
    return nil;
}


- (NSArray*) headerFiles {
    return [self projectFilesOfType:SourceCodeHeader];
}

- (NSArray*) objectiveCFiles {
    return [self projectFilesOfType:SourceCodeObjC];
}

- (NSArray*) objectiveCPlusPlusFiles {
    return [self projectFilesOfType:SourceCodeObjCPlusPlus];
}


- (NSArray*) xibFiles {
    return [self projectFilesOfType:XibFile];
}

- (NSArray*) imagePNGFiles {
    return [self projectFilesOfType:ImageResourcePNG];
}

// need this value to construct relative path in XcodeprojDefinition
- (NSString*) filePath {
    return _filePath;
}

/* ================================================================================================================== */
#pragma mark Groups

- (NSArray*) groups {

    NSMutableArray* results = [[NSMutableArray alloc] init];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {

        if ([[obj valueForKey:@"isa"] asMemberType] == PBXGroup) {
            [results addObject:[self groupWithKey:key]];
        }
    }];
    return results;
}

//TODO: Optimize this implementation.
- (XCGroup*) rootGroup {
    for (XCGroup* group in [self groups]) {
        if ([group isRootGroup]) {
            return group;
        }
    }
    return nil;
}


- (XCGroup*) groupWithKey:(NSString*)key {
    NSDictionary* obj = [[self objects] valueForKey:key];
    if (obj && [[obj valueForKey:@"isa"] asMemberType] == PBXGroup) {

        NSString* name = [obj valueForKey:@"name"];
        NSString* path = [obj valueForKey:@"path"];
        NSArray* children = [obj valueForKey:@"children"];

        return [XCGroup groupWithProject:self key:key alias:name path:path children:children];
    }
    return nil;
}

- (XCGroup*) groupForGroupMemberWithKey:(NSString*)key {
    for (XCGroup* group in [self groups]) {
        if ([group memberWithKey:key]) {
            return group;
        }
    }
    return nil;
}

//TODO: This could fail if the path attribute on a given group is more than one directory. Start with candidates and
//TODO: search backwards.
- (XCGroup*) groupWithPathFromRoot:(NSString*)path {
    NSArray* pathItems = [path componentsSeparatedByString:@"/"];
    XCGroup* currentGroup = [self rootGroup];
    for (NSString* pathItem in pathItems) {
        id<XcodeGroupMember> group = [currentGroup memberWithDisplayName:pathItem];
        if ([group isKindOfClass:[XCGroup class]]) {
            currentGroup = group;
        }
        else {
            return nil;
        }
    }
    return currentGroup;
}


/* ================================================================================================================== */
#pragma mark Targets

- (NSArray*) targets {
    if (_targets == nil) {
        _targets = [[NSMutableArray alloc] init];
        [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
            if ([[obj valueForKey:@"isa"] asMemberType] == PBXNativeTarget) {
                XCTarget* target = [XCTarget targetWithProject:self key:key name:[obj valueForKey:@"name"]
                        productName:[obj valueForKey:@"productName"]
                        productReference:[obj valueForKey:@"productReference"]];
                [_targets addObject:target];
            }
        }];
    }
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [_targets sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (XCTarget*) targetWithName:(NSString*)name {
    for (XCTarget* target in [self targets]) {
        if ([[target name] isEqualToString:name]) {
            return target;
        }
    }
    return nil;
}

- (void) save {
    [_fileOperationQueue commitFileOperations];
    LogDebug(@"Done committing file operations");
    [_dataStore writeToFile:[_filePath stringByAppendingPathComponent:@"project.pbxproj"] atomically:NO];
    LogDebug(@"Done writing project file.");
}

- (NSMutableDictionary*) objects {
    return [_dataStore objectForKey:@"objects"];
}


/* ================================================== Private Methods =============================================== */
#pragma mark Private

- (NSArray*) projectFilesOfType:(XcodeSourceFileType)projectFileType {
    NSMutableArray* results = [NSMutableArray array];
    for (XCSourceFile* file in [self files]) {
        if ([file type] == projectFileType) {
            [results addObject:file];
        }
    }
    NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [results sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}

@end