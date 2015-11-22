////////////////////////////////////////////////////////////////////////////////
//
//  JASPER BLUES
//  Copyright 2012 - 2013 Jasper Blues
//  All Rights Reserved.
//
//  NOTICE: Jasper Blues permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


#import "XCProject.h"
#import "XCGroup.h"
#import "XCSourceFile.h"
#import "XCTarget.h"
#import "XCFileOperationQueue.h"
#import "XCProjectBuildConfig.h"

NSString *const XCProjectNotFoundException;

@implementation XCProject


@synthesize fileOperationQueue = _fileOperationQueue;

//-------------------------------------------------------------------------------------------
#pragma mark - Class Methods
//-------------------------------------------------------------------------------------------

+ (XCProject *)projectWithFilePath:(NSString *)filePath
{
    return [[XCProject alloc] initWithFilePath:filePath];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Initialization & Destruction
//-------------------------------------------------------------------------------------------

- (id)initWithFilePath:(NSString *)filePath
{
    if ((self = [super init])) {
        _filePath = [filePath copy];
        _dataStore = [[NSMutableDictionary alloc]
                initWithContentsOfFile:[_filePath stringByAppendingPathComponent:@"project.pbxproj"]];

        if (!_dataStore) {
            [NSException raise:XCProjectNotFoundException format:@"Project file not found at file path %@", _filePath];
        }

        _fileOperationQueue =
                [[XCFileOperationQueue alloc] initWithBaseDirectory:[_filePath stringByDeletingLastPathComponent]];

    }
    return self;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Interface Methods
//-------------------------------------------------------------------------------------------

#pragma mark Files

- (NSArray *)files
{
    NSMutableArray *results = [NSMutableArray array];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
        if ([[obj valueForKey:@"isa"] xce_hasFileReferenceType]) {
            XcodeSourceFileType fileType = XCSourceFileTypeFromStringRepresentation(
                    [obj valueForKey:@"lastKnownFileType"] ?: [obj valueForKey:@"explicitFileType"]);
            NSString *path = [obj valueForKey:@"path"];
            NSString *sourceTree = [obj valueForKey:@"sourceTree"];
            XCSourceFile *sourceFile = [XCSourceFile sourceFileWithProject:self key:key type:fileType name:path
                                                                sourceTree:(sourceTree ?: @"<_group>") path:nil];
            [results addObject:sourceFile];
        }
    }];
    return results;
}

- (XCSourceFile *)fileWithKey:(NSString *)key
{
    NSDictionary *obj = [[self objects] valueForKey:key];
    if (obj && [[obj valueForKey:@"isa"] xce_hasFileReferenceOrReferenceProxyType]) {
        XcodeSourceFileType fileType = XCSourceFileTypeFromStringRepresentation(
                [obj valueForKey:@"lastKnownFileType"] ?: [obj valueForKey:@"explicitFileType"]);

        NSString *name = [obj valueForKey:@"name"];
        NSString *sourceTree = [obj valueForKey:@"sourceTree"];
        NSString *path = [obj valueForKey:@"path"];

        if (name == nil) {
            name = path;
        }
        return [XCSourceFile sourceFileWithProject:self key:key type:fileType name:name
                                        sourceTree:(sourceTree ?: @"<_group>") path:path];
    }
    return nil;
}

- (XCSourceFile *)fileWithName:(NSString *)name
{
    for (XCSourceFile *projectFile in [self files]) {
        if ([[projectFile name] isEqualToString:name]) {
            return projectFile;
        }
    }
    return nil;
}


- (NSArray *)headerFiles
{
    return [self projectFilesOfType:SourceCodeHeader];
}

- (NSArray *)objectiveCFiles
{
    return [self projectFilesOfType:SourceCodeObjC];
}

- (NSArray *)objectiveCPlusPlusFiles
{
    return [self projectFilesOfType:SourceCodeObjCPlusPlus];
}


- (NSArray *)xibFiles
{
    return [self projectFilesOfType:XibFile];
}

- (NSArray *)imagePNGFiles
{
    return [self projectFilesOfType:ImageResourcePNG];
}


// need this value to construct relative path in XcodeprojDefinition
- (NSString *)filePath
{
    return _filePath;
}

//-------------------------------------------------------------------------------------------
#pragma mark Groups
//-------------------------------------------------------------------------------------------

- (NSArray *)groups
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
        if ([[obj valueForKey:@"isa"] xce_hasGroupType]) {
            XCGroup *group = _groups[key];
            if (group == nil) {
                group = [self createGroupWithDictionary:obj forKey:key];
                _groups[key] = group;
            }
            [results addObject:group];
        }
    }];
    return results;
}

//TODO: Optimize this implementation.
- (XCGroup *)rootGroup
{
    for (XCGroup *group in [self groups]) {
        if ([group isRootGroup]) {
            return group;
        }
    }
    return nil;
}

- (NSArray *)rootGroups
{
    XCGroup *group = [self rootGroup];
    if (group) {
        return [NSArray arrayWithObject:group];
    }

    NSMutableArray *results = [NSMutableArray array];
    for (XCGroup *group in [self groups]) {
        if ([group parentGroup] == nil) {
            [results addObject:group];
        }
    }

    return [results copy];
}

- (XCGroup *)groupWithKey:(NSString *)key
{
    XCGroup *group = [_groups objectForKey:key];
    if (group) {
        return group;
    }

    NSDictionary *obj = [[self objects] objectForKey:key];
    if (obj && [[obj valueForKey:@"isa"] xce_hasGroupType]) {
        XCGroup *group = [self createGroupWithDictionary:obj forKey:key];
        _groups[key] = group;

        return group;
    }
    return nil;
}

- (XCGroup *)groupWithDisplayName:(NSString *)name
{
    for (XCGroup *group in [self groups]) {
        if ([[group displayName] isEqualToString:name]) {
            return group;
        }
    }
    return nil;
}


- (XCGroup *)groupForGroupMemberWithKey:(NSString *)key
{
    for (XCGroup *group in [self groups]) {
        if ([group memberWithKey:key]) {
            return group;
        }
    }
    return nil;
}

- (XCGroup *)groupWithSourceFile:(XCSourceFile *)sourceFile
{
    for (XCGroup *group in [self groups]) {
        for (id <XcodeGroupMember> member in [group members]) {
            if ([member isKindOfClass:[XCSourceFile class]] && [[sourceFile key] isEqualToString:[member key]]) {
                return group;
            }
        }
    }
    return nil;
}

- (void)pruneEmptyGroups
{
    [self doPruneEmptyGroups];
}


//TODO: This could fail if the path attribute on a given group is more than one directory. Start with candidates and
//TODO: search backwards.
- (XCGroup *)groupWithPathFromRoot:(NSString *)path
{
    NSArray *pathItems = [path pathComponents];
    XCGroup *currentGroup = [self rootGroup];
    for (NSString *pathItem in pathItems) {
        id <XcodeGroupMember> group = [currentGroup memberWithDisplayName:pathItem];
        if ([group isKindOfClass:[XCGroup class]]) {
            currentGroup = group;
        } else {
            return nil;
        }
    }
    return currentGroup;
}

- (XCGroup *)createGroupWithDictionary:(NSDictionary *)dictionary forKey:(NSString *)key
{
    return [XCGroup groupWithProject:self key:key alias:[dictionary valueForKey:@"name"]
                                path:[dictionary valueForKey:@"path"] children:[dictionary valueForKey:@"children"]];
}


//-------------------------------------------------------------------------------------------
#pragma mark targets
//-------------------------------------------------------------------------------------------

- (NSArray *)targets
{
    if (_targets == nil) {
        _targets = [[NSMutableArray alloc] init];
        [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
            if ([[obj valueForKey:@"isa"] xce_hasNativeTargetType]) {
                XCTarget *target = [XCTarget targetWithProject:self key:key name:[obj valueForKey:@"name"]
                                                   productName:[obj valueForKey:@"productName"]
                                              productReference:[obj valueForKey:@"productReference"]];
                [_targets addObject:target];
            }
        }];
    }
    return _targets;
}

- (XCTarget *)targetWithName:(NSString *)name
{
    for (XCTarget *target in [self targets]) {
        if ([[target name] isEqualToString:name]) {
            return target;
        }
    }
    return nil;
}

- (void)save
{
    [_fileOperationQueue commitFileOperations];
    [_dataStore writeToFile:[_filePath stringByAppendingPathComponent:@"project.pbxproj"] atomically:YES];

    NSLog(@"Saved project");
}

- (NSMutableDictionary *)objects
{
    return [_dataStore objectForKey:@"objects"];
}

- (NSMutableDictionary *)dataStore
{
    return _dataStore;
}

- (void)dropCache
{
    _targets = nil;
    _configurations = nil;
    _rootObjectKey = nil;
}


- (NSDictionary *)configurations
{
    if (_configurations == nil) {
        NSString *buildConfigurationRootSectionKey =
                [[[self objects] objectForKey:[self rootObjectKey]] objectForKey:@"buildConfigurationList"];
        NSDictionary *buildConfigurationDictionary = [[self objects] objectForKey:buildConfigurationRootSectionKey];
        _configurations =
                [[XCProjectBuildConfig buildConfigurationsFromArray:[buildConfigurationDictionary objectForKey:@"buildConfigurations"]
                                                          inProject:self] mutableCopy];
        _defaultConfigurationName = [[buildConfigurationDictionary objectForKey:@"defaultConfigurationName"] copy];
    }

    return [_configurations copy];
}

- (XCProjectBuildConfig *)configurationWithName:(NSString *)name
{
    return [[self configurations] objectForKey:name];
}

- (XCProjectBuildConfig *)defaultConfiguration
{
    return [[self configurations] objectForKey:_defaultConfigurationName];
}

//-------------------------------------------------------------------------------------------
#pragma mark Private
//-------------------------------------------------------------------------------------------

- (NSString *)rootObjectKey
{
    if (_rootObjectKey == nil) {
        _rootObjectKey = [[_dataStore objectForKey:@"rootObject"] copy];;
    }

    return _rootObjectKey;
}

- (NSArray *)projectFilesOfType:(XcodeSourceFileType)projectFileType
{
    NSMutableArray *results = [NSMutableArray array];
    for (XCSourceFile *file in [self files]) {
        if ([file type] == projectFileType) {
            [results addObject:file];
        }
    }
    return results;
}

- (BOOL)doPruneEmptyGroups
{
    BOOL hadEmptyGroups = NO;
    for (XCGroup *group in [self groups]) {
        if ([group isEmpty]) {
            hadEmptyGroups = YES;
            [group removeFromParentGroup];
        }
    }
    //Prune any groups made empty as a result of pruning a child group.
    if (hadEmptyGroups) {
        [self doPruneEmptyGroups];
    }
    return hadEmptyGroups;
}

@end