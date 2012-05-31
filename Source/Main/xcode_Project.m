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

#import "xcode_Project.h"
#import "xcode_Group.h"
#import "xcode_SourceFile.h"
#import "xcode_Target.h"
#import "xcode_FileOperationQueue.h"
#import "xcode_utils_KeyBuilder.h"
#import "xcode_XcodeprojDefinition.h"


/* ================================================================================================================== */
@interface xcode_Project (Private)

- (NSArray*) projectFilesOfType:(XcodeSourceFileType)fileReferenceType;
- (NSDictionary*) makeContainerItemProxyForName:(NSString*)name projectRef:(NSString*)projectRef;
- (NSDictionary*) findContainerItemProxyForName:(NSString*)name;

@end


@implementation xcode_Project


@synthesize fileOperationQueue = _fileOperationQueue;

/* ================================================= Class Methods ================================================== */
+ (Project*) projectWithFilePath:(NSString*)filePath {
    return [[Project alloc] initWithFilePath:filePath];
}


/* ================================================== Initializers ================================================== */
- (id) initWithFilePath:(NSString*)filePath {
    if (self) {
        _filePath = [filePath copy];
        _dataStore = [[NSMutableDictionary alloc]
                initWithContentsOfFile:[_filePath stringByAppendingPathComponent:@"project.pbxproj"]];

        if (!_dataStore) {
            [NSException raise:NSInvalidArgumentException format:@"Project file not found at file path %@", _filePath];
        }
        _fileOperationQueue =
                [[FileOperationQueue alloc] initWithBaseDirectory:[_filePath stringByDeletingLastPathComponent]];
    }
    return self;
}


/* ================================================ Interface Methods =============================================== */

#pragma mark Methods used when adding an xcodeproj to an existing project

- (NSDictionary*) findContainerItemProxyForName:(NSString*)name {
    __block NSDictionary* proxy = nil;
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXContainerItemProxy) {
            NSString* remoteInfo = [obj valueForKey:@"remoteInfo"];
            if ([remoteInfo isEqualToString:name]) {
                proxy = obj;
                *stop = YES;
            }
        }
    }];
    return proxy;
}

- (NSString*) makeContainerItemProxyForName:(NSString*)name fileRef:(NSString*)fileRef {
    // remove one if it exists
    NSDictionary *existingProxy = [self findContainerItemProxyForName:name];
    if (existingProxy) {
        [[self objects] removeObjectForKey:[existingProxy valueForKey:@"key"]];
    }
    // make new one
    NSMutableDictionary* proxy = [NSMutableDictionary dictionary];
    [proxy setObject:[NSString stringFromMemberType:PBXContainerItemProxy] forKey:@"isa"];
    [proxy setObject:fileRef forKey:@"containerPortal"];
    [proxy setObject:@"2" forKey:@"proxyType"];
    // give it a random key - the keys xcode puts here are not in the project file anywhere else
    NSString *key = [[KeyBuilder forItemNamed:name] build];
    [proxy setObject:key forKey:@"remoteGlobalIDString"];
    [proxy setObject:name forKey:@"remoteInfo"];
    // add to project
    key = [[KeyBuilder forItemNamed:name] build];
    [[self objects] setObject:proxy forKey:key];
    
    return key;
}

- (NSDictionary*) findReferenceProxyForName:(NSString*)name {
    __block NSDictionary* proxy = nil;
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXReferenceProxy) {
            NSString* path = [obj valueForKey:@"path"];
            if ([path isEqualToString:name]) {
                proxy = obj;
                *stop = YES;
            }
        }
    }];
    return proxy;
}


- (void)makeReferenceProxyForContainerItemProxy:(NSString*)containerItemProxyKey buildProductReference:(NSDictionary*)buildProductReference {
    NSString* path = [buildProductReference valueForKey:@"path"];
    // remove one if it exists
    NSDictionary *existingProxy = [self findReferenceProxyForName:path];
    if (existingProxy) {
        [[self objects] removeObjectForKey:[existingProxy valueForKey:@"key"]];
    }
    // make new one
    NSMutableDictionary* proxy = [NSMutableDictionary dictionary];
    [proxy setObject:[NSString stringFromMemberType:PBXReferenceProxy] forKey:@"isa"];
    [proxy setObject:[buildProductReference valueForKey:@"explicitFileType"] forKey:@"fileType"];
    [proxy setObject:path forKey:@"path"];
    [proxy setObject:containerItemProxyKey forKey:@"remoteRef"];
    [proxy setObject:[buildProductReference valueForKey:@"sourceTree"] forKey:@"sourceTree"];
    // add to project
    NSString* key = [[KeyBuilder forItemNamed:path] build];
    [[self objects] setObject:proxy forKey:key];
}

- (void)addProxies:(XcodeprojDefinition *)xcodeproj {
    NSString* fileRef = [[self fileWithName:[xcodeproj xcodeprojFullPathName]] key];
    for (NSDictionary* target in [xcodeproj.subproject targets]) {
        NSString* containerItemProxyKey = [self makeContainerItemProxyForName:[target valueForKey:@"productName"] fileRef:fileRef];
        NSString* productFileReferenceKey = [target valueForKey:@"productReference"];
        NSDictionary* prooductFileReference = [[xcodeproj.subproject objects] valueForKey:productFileReferenceKey];
        [self makeReferenceProxyForContainerItemProxy:containerItemProxyKey buildProductReference:prooductFileReference];
    }
}

#pragma mark Files

- (NSArray*) files {
    NSMutableArray* results = [NSMutableArray array];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXFileReference) {
            XcodeSourceFileType fileType = [[obj valueForKey:@"lastKnownFileType"] asSourceFileType];
            NSString* path = [obj valueForKey:@"path"];
            NSString* sourceTree = [obj valueForKey:@"sourceTree"];
            [results addObject:[SourceFile sourceFileWithProject:self key:key type:fileType name:path
                                       sourceTree:(sourceTree ? sourceTree : @"<group>")]];
        }
    }];
    NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [results sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}

- (SourceFile*) fileWithKey:(NSString*)key {
    NSDictionary* obj = [[self objects] valueForKey:key];
    if (obj && [[obj valueForKey:@"isa"] asMemberType] == PBXFileReference) {
        XcodeSourceFileType fileType = [[obj valueForKey:@"lastKnownFileType"] asSourceFileType];

        NSString* name = [obj valueForKey:@"name"];
        NSString* sourceTree = [obj valueForKey:@"sourceTree"];

        if (name == nil) {
            name = [obj valueForKey:@"path"];
        }
        return [SourceFile sourceFileWithProject:self key:key type:fileType name:name
                sourceTree:(sourceTree ? sourceTree : @"<group>")];
    }
    return nil;
}

- (SourceFile*) fileWithName:(NSString*)name {
    for (SourceFile* projectFile in [self files]) {
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

- (NSString*) referenceProxyKeyForName:(NSString*)name {
    __block NSString* result;
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXReferenceProxy) {
            if ([[obj valueForKey:@"path"] isEqualTo:name]) {
                result = key;
                *stop = YES;
            }
        }
    }];
    return result;
}

- (NSDictionary*) PBXProject {
    __block NSDictionary* result;
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXProject) {
            result = obj;
            *stop = YES;       
        }
    }];
    return result;    
}

- (NSString*) PBXProjectKey {
    __block NSString* result;
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXProject) {
            result = key;
            *stop = YES;       
        }
    }];
    return result;        
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
- (Group*) rootGroup {
    for (Group* group in [self groups]) {
        if ([group isRootGroup]) {
            return group;
        }
    }
    return nil;
}


- (Group*) groupWithKey:(NSString*)key {
    NSDictionary* obj = [[self objects] valueForKey:key];
    if (obj && [[obj valueForKey:@"isa"] asMemberType] == PBXGroup) {

        NSString* name = [obj valueForKey:@"name"];
        NSString* path = [obj valueForKey:@"path"];
        NSArray* children = [obj valueForKey:@"children"];

        return [Group groupWithProject:self key:key alias:name path:path children:children];
    }
    return nil;
}

- (Group*) groupForGroupMemberWithKey:(NSString*)key {
    for (Group* group in [self groups]) {
        if ([group memberWithKey:key]) {
            return group;
        }
    }
    return nil;
}

//TODO: This could fail if the path attribute on a given group is more than one directory. Start with candidates and
//TODO: search backwards.
- (Group*) groupWithPathFromRoot:(NSString*)path {
    NSArray* pathItems = [path componentsSeparatedByString:@"/"];
    Group* currentGroup = [self rootGroup];
    for (NSString* pathItem in pathItems) {
        id<XcodeGroupMember> group = [currentGroup memberWithDisplayName:pathItem];
        if ([group isKindOfClass:[Group class]]) {
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
                Target* target = [Target targetWithProject:self key:key name:[obj valueForKey:@"name"] productName:[obj valueForKey:@"productName"] productReference:[obj valueForKey:@"productReference"]];
                [_targets addObject:target];
            }
        }];
    }
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [_targets sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
}

- (Target*) targetWithName:(NSString*)name {
    for (Target* target in [self targets]) {
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
    for (SourceFile* file in [self files]) {
        if ([file type] == projectFileType) {
            [results addObject:file];
        }
    }
    NSSortDescriptor* sorter = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    return [results sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
}


@end