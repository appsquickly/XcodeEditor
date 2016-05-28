////////////////////////////////////////////////////////////////////////////////
//
//  JASPER BLUES
//  Copyright 2012 Jasper Blues
//  All Rights Reserved.
//
//  NOTICE: Jasper Blues permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "XCGroup.h"
#import "XCKeyBuilder.h"
#import "XCTarget.h"
#import "XCSourceFile.h"
#import "XCProject.h"
#import "XCProjectBuildConfig.h"
#import "XcodeGroupMember.h"
#import "XCBuildShellScript.h"
#import "XCBuildShellScriptDefinition.h"
#import "XCVersionGroup.h"

@implementation XCTarget

/* ====================================================================================================================================== */
#pragma mark - Class Methods

+ (XCTarget*)targetWithProject:(XCProject*)project key:(NSString*)key name:(NSString*)name productName:(NSString*)productName
              productReference:(NSString*)productReference productType:(NSString*)productType
{
    return [[XCTarget alloc] initWithProject:project key:key name:name productName:productName productReference:productReference productType:productType];
}


/* ====================================================================================================================================== */
#pragma mark - Initialization & Destruction

- (id)initWithProject:(XCProject*)project key:(NSString*)key name:(NSString*)name productName:(NSString*)productName
     productReference:(NSString*)productReference productType:(NSString*)productType
{
    self = [super init];
    if (self)
    {
        _project = project;
        _key = [key copy];
        _name = [name copy];
        _productName = [productName copy];
        _productReference = [productReference copy];
        _productType = [productType copy];
    }
    return self;
}

/* ====================================================================================================================================== */
#pragma mark - Interface Methods

- (NSArray*)resources
{
    if (_resources == nil)
    {
        _resources = [[NSMutableArray alloc] init];
        for (NSString* buildPhaseKey in [[[_project objects] objectForKey:_key] objectForKey:@"buildPhases"])
        {
            NSDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
            if ([[buildPhase valueForKey:@"isa"] xce_hasResourcesBuildPhaseType])
            {
                for (NSString* buildFileKey in [buildPhase objectForKey:@"files"])
                {
                    id<XCBuildFile> targetMember = [self buildFileWithKey:buildFileKey];
                    if (targetMember)
                    {
                        [_resources addObject:[self buildFileWithKey:buildFileKey]];
                    }
                }
            }
        }
    }
    
    return _resources;
}

- (NSDictionary*)configurations
{
    if (_configurations == nil)
    {
        NSString* buildConfigurationRootSectionKey = [[[_project objects] objectForKey:_key] objectForKey:@"buildConfigurationList"];
        NSDictionary* buildConfigurationDictionary = [[_project objects] objectForKey:buildConfigurationRootSectionKey];
        _configurations =
        [[XCProjectBuildConfig buildConfigurationsFromArray:[buildConfigurationDictionary objectForKey:@"buildConfigurations"]
                                                  inProject:_project] mutableCopy];
        _defaultConfigurationName = [[buildConfigurationDictionary objectForKey:@"defaultConfigurationName"] copy];
    }
    
    return _configurations;
}

- (XCProjectBuildConfig *)defaultConfiguration
{
    return [[self configurations] objectForKey:_defaultConfigurationName];
}

- (XCProjectBuildConfig *)configurationWithName:(NSString*)name
{
    return [[self configurations] objectForKey:name];
}

- (NSArray*)members
{
    if (_members == nil)
    {
        _members = [[NSMutableArray alloc] init];
        for (NSString* buildPhaseKey in [[[_project objects] objectForKey:_key] objectForKey:@"buildPhases"])
        {
            NSDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
            if ([[buildPhase valueForKey:@"isa"] xce_hasSourcesOrFrameworksBuildPhaseType])
            {
                for (NSString* buildFileKey in [buildPhase objectForKey:@"files"])
                {
                    id<XCBuildFile,XcodeGroupMember> targetMember = [self buildFileWithKey:buildFileKey];
                    if (targetMember)
                    {
                        [_members addObject:targetMember];
                    }
                }
            }
        }
    }
    return _members;
}

- (NSArray*)buildShellScripts
{
    if (_buildShellScripts == nil)
    {
        _buildShellScripts = [[NSMutableArray alloc] init];
        for (NSString* buildPhaseKey in [[[_project objects] objectForKey:_key] objectForKey:@"buildPhases"])
        {
            NSDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
            if ([[buildPhase valueForKey:@"isa"] xce_hasShellScriptBuildPhase])
            {
                
                XCBuildShellScript* targetMember = [[XCBuildShellScript alloc]initWithProject:_project
                                                                                          key:buildPhaseKey
                                                                                         name:buildPhase[@"name"]
                                                                                        files:buildPhase[@"files"]
                                                                                   inputPaths:buildPhase[@"inputPaths"]
                                                                                  outputPaths:buildPhase[@"outputPaths"]
                                                           runOnlyForDeploymentPostprocessing:[buildPhase[@"runOnlyForDeploymentPostprocessing"] boolValue]
                                                                                    shellPath:buildPhase[@"shellPath"]
                                                                                  shellScript:buildPhase[@"shellScript"]];
                if (targetMember)
                {
                    [_buildShellScripts addObject:targetMember];
                }
            }
        }
    }
    
    return _buildShellScripts;
}

- (void)addMember:(id<XCBuildFile>)member
{
    [member becomeBuildFile];
    NSDictionary* target = [[_project objects] objectForKey:_key];
    
    for (NSString* buildPhaseKey in [target objectForKey:@"buildPhases"])
    {
        NSMutableDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
        if ([[buildPhase valueForKey:@"isa"] xce_asMemberType] == [member buildPhase])
        {
            
            NSMutableArray* files = [buildPhase objectForKey:@"files"];
            if (![files containsObject:[member buildFileKey]])
            {
                [files addObject:[member buildFileKey]];
            }
            
            [buildPhase setObject:files forKey:@"files"];
        }
    }
    [self flagMembersAsDirty];
}

- (void)makeAndAddShellScript:(XCBuildShellScriptDefinition *)shellScript
{
    NSDictionary* target = [[_project objects] objectForKey:_key];
    
    NSDictionary* reference = @{
                                @"isa":[NSString xce_stringFromMemberType:PBXShellScriptBuildPhase],
                                @"buildActionMask":@"2147483647",
                                @"files":shellScript.files,
                                @"inputPaths":shellScript.inputPaths,
                                @"outputPaths":shellScript.outputPaths,
                                @"runOnlyForDeploymentPostprocessing":@(shellScript.runOnlyForDeploymentPostprocessing),
                                @"shellPath":shellScript.shellPath,
                                @"shellScript":shellScript.shellScript,
                                @"name":shellScript.name
                                
                                };
    NSString* fileKey = [[XCKeyBuilder forItemNamed:shellScript.name] build];
    [_project objects][fileKey] = reference;
    
    NSMutableArray *buildPhases =[target objectForKey:@"buildPhases"];
    [buildPhases addObject:fileKey];
    [target setValue:buildPhases forKey:@"buildPhases"];
    
    [self flagMembersAsDirty];
}

- (void)removeShellScriptByName:(NSString*)name {
    NSDictionary* target = [[_project objects] objectForKey:_key];
    NSMutableArray *removedPhases = [NSMutableArray array];
    for (NSString* buildPhaseKey in [target objectForKey:@"buildPhases"])
    {
        NSMutableDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
        NSString* type = [buildPhase objectForKey:@"isa"];
        if (type && [type xce_hasShellScriptBuildPhase]) {
            NSString* currentName = [buildPhase objectForKey:@"name"];
            if ([currentName isEqualToString:name]) {
                [_project removeObjectWithKey:buildPhaseKey];
                [removedPhases addObject:buildPhaseKey];
            }
        }
    }
    
    NSMutableArray *buildPhases =[target objectForKey:@"buildPhases"];
    [buildPhases removeObjectsInArray:removedPhases];
    [target setValue:buildPhases forKey:@"buildPhases"];
}

- (NSDictionary*)buildRefWithFileRefKey
{
    NSMutableDictionary* buildRefWithFileRefDict = [NSMutableDictionary dictionary];
    NSDictionary* allObjects = [_project objects];
    NSArray* keys = [allObjects allKeys];
    
    for (NSString* key in keys)
    {
        NSDictionary* dictionaryInfo = [allObjects objectForKey:key];
        
        NSString* type = [dictionaryInfo objectForKey:@"isa"];
        if (type)
        {
            if ([type isEqualToString:@"PBXBuildFile"])
            {
                NSString* fileRef = [dictionaryInfo objectForKey:@"fileRef"];
                
                if (fileRef)
                {
                    [buildRefWithFileRefDict setObject:key forKey:fileRef];
                }
            }
        }
    }
    return buildRefWithFileRefDict;
}

- (void)removeResourceWithKey:(NSString*)key
{
    [self removeResourcesWithKeys:[NSArray arrayWithObject:key]];
}

- (void)removeResourcesWithKeys:(NSArray*)keys
{
    NSDictionary* target = [[_project objects] objectForKey:_key];
    for (NSString* buildPhaseKey in [target objectForKey:@"buildPhases"])
    {
        NSMutableDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
        NSMutableArray* files = [buildPhase objectForKey:@"files"];
        NSMutableIndexSet* toRemoveIndexes = [NSMutableIndexSet indexSet];
        
        for (int i = 0; i < files.count; i ++)
        {
            XCSourceFile* resource = [self buildFileWithKey:files[i]];
            if ([keys containsObject:resource.key]) {
                [toRemoveIndexes addIndex:i];
            }
        }
        
        [files removeObjectsAtIndexes:toRemoveIndexes];
        [buildPhase setObject:files forKey:@"files"];
    }
    [self flagMembersAsDirty];
}


- (void)removeMemberWithKey:(NSString*)key
{
    
    NSDictionary* buildRefWithFileRef = [self buildRefWithFileRefKey];
    NSDictionary* target = [[_project objects] objectForKey:_key];
    NSString* buildRef = [buildRefWithFileRef objectForKey:key];
    
    if (!buildRef)
    {
        return;
    }
    
    for (NSString* buildPhaseKey in [target objectForKey:@"buildPhases"])
    {
        NSMutableDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
        NSMutableArray* files = [buildPhase objectForKey:@"files"];
        
        [files removeObjectIdenticalTo:buildRef];
        [buildPhase setObject:files forKey:@"files"];
    }
    [self flagMembersAsDirty];
}

- (void)removeMembersWithKeys:(NSArray*)keys
{
    for (NSString* key in keys)
    {
        [self removeMemberWithKey:key];
    }
}

- (void)addDependency:(NSString*)key
{
    NSDictionary* targetObj = [[_project objects] objectForKey:_key];
    NSMutableArray* dependencies = [targetObj valueForKey:@"dependencies"];
    // add only if not already there
    BOOL found = NO;
    for (NSString* dependency in dependencies)
    {
        if ([dependency isEqualToString:key])
        {
            found = YES;
            break;
        }
    }
    if (!found)
    {
        [dependencies addObject:key];
    }
}

- (instancetype)duplicateWithTargetName:(NSString*)targetName productName:(NSString*)productName
{
    
    NSDictionary* targetObj = _project.objects[_key];
    NSMutableDictionary* dupTargetObj = [targetObj mutableCopy];
    
    dupTargetObj[@"name"] = targetName;
    dupTargetObj[@"productName"] = productName;
    
    NSString* buildConfigurationListKey = dupTargetObj[@"buildConfigurationList"];
    
    void(^visitor)(NSMutableDictionary*) = ^(NSMutableDictionary* buildConfiguration)
    {
        buildConfiguration[@"buildSettings"][@"PRODUCT_NAME"] = productName;
    };
    
    dupTargetObj[@"buildConfigurationList"] =
    [XCProjectBuildConfig duplicatedBuildConfigurationListWithKey:buildConfigurationListKey inProject:_project
                                    withBuildConfigurationVisitor:visitor];
    
    [self duplicateProductReferenceForTargetObject:dupTargetObj withProductName:productName];
    
    [self duplicateBuildPhasesForTargetObject:dupTargetObj];
    
    [self addReferenceToProductsGroupForTargetObject:dupTargetObj];
    
    NSString* dupTargetObjKey = [self addTargetToRootObjectTargets:dupTargetObj];
    
    [_project dropCache];
    
    return [[XCTarget alloc] initWithProject:_project key:dupTargetObjKey name:targetName productName:productName
                            productReference:dupTargetObj[@"productReference"] productType:dupTargetObj[@"productType"]];
}

-(BOOL)isApplicationType {
    return [_productType isEqualToString:@"com.apple.product-type.application"];
}

/* ====================================================================================================================================== */
#pragma mark - Overridden Methods

- (void)setName:(NSString*)name
{
    _name = name;
    NSDictionary* dictionary = [_project.objects objectForKey:_key];
    [dictionary setValue:_name forKey:@"name"];
}

- (void)setProductName:(NSString*)productName
{
    _productName = productName;
    NSDictionary* dictionary = [_project.objects objectForKey:_key];
    [dictionary setValue:_productName forKey:@"productName"];
}



/* ====================================================================================================================================== */
#pragma mark - Utility Methods

- (NSString*)description
{
    return [NSString stringWithFormat:@"Target: name=%@, files=%@", _name, _members];
}

/* ====================================================================================================================================== */
#pragma mark - Private Methods

- (id<XCBuildFile,XcodeGroupMember>)buildFileWithKey:(NSString*)theKey
{
    NSDictionary* obj = [[_project objects] valueForKey:theKey];
    if (obj)
    {
        if ([[obj valueForKey:@"isa"] xce_hasBuildFileType])
        {
            id<XcodeGroupMember> targetFile = [_project groupMemberWithKey:[obj valueForKey:@"fileRef"]];
            if([targetFile conformsToProtocol:@protocol(XCBuildFile)])
                return (id<XcodeGroupMember,XCBuildFile>) targetFile;
        }
    }
    return nil;
}

- (void)flagMembersAsDirty
{
    _members = nil;
    _resources = nil;
    _buildShellScripts = nil;
}

- (void)duplicateProductReferenceForTargetObject:(NSMutableDictionary*)dupTargetObj withProductName:(NSString*)productName
{
    
    NSString* productReferenceKey = dupTargetObj[@"productReference"];
    NSMutableDictionary* dupProductReference = [_project.objects[productReferenceKey] mutableCopy];
    
    NSString* path = dupProductReference[@"path"];
    NSString* dupPath = [path stringByDeletingLastPathComponent];
    dupPath = [dupPath stringByAppendingPathComponent:productName];
    dupPath = [dupPath stringByAppendingPathExtension:@"app"];
    dupProductReference[@"path"] = dupPath;
    
    NSString* dupProductReferenceKey = [[XCKeyBuilder createUnique] build];
    
    _project.objects[dupProductReferenceKey] = dupProductReference;
    dupTargetObj[@"productReference"] = dupProductReferenceKey;
}

- (void)duplicateBuildPhasesForTargetObject:(NSMutableDictionary*)dupTargetObj
{
    
    NSMutableArray* buildPhases = [NSMutableArray array];
    
    for (NSString* buildPhaseKey in dupTargetObj[@"buildPhases"])
    {
        
        NSMutableDictionary* dupBuildPhase = [_project.objects[buildPhaseKey] mutableCopy];
        NSMutableArray* dupFiles = [NSMutableArray array];
        
        for (NSString* fileKey in dupBuildPhase[@"files"])
        {
            
            NSMutableDictionary* dupFile = [_project.objects[fileKey] mutableCopy];
            NSString* dupFileKey = [[XCKeyBuilder createUnique] build];
            
            _project.objects[dupFileKey] = dupFile;
            [dupFiles addObject:dupFileKey];
        }
        
        dupBuildPhase[@"files"] = dupFiles;
        
        NSString* dupBuildPhaseKey = [[XCKeyBuilder createUnique] build];
        _project.objects[dupBuildPhaseKey] = dupBuildPhase;
        [buildPhases addObject:dupBuildPhaseKey];
    }
    
    dupTargetObj[@"buildPhases"] = buildPhases;
}

- (void)addReferenceToProductsGroupForTargetObject:(NSMutableDictionary*)dupTargetObj
{
    
    XCGroup* mainGroup = nil;
    NSPredicate* productsPredicate = [NSPredicate predicateWithFormat:@"displayName == 'Products'"];
    NSArray* filteredGroups = [_project.groups filteredArrayUsingPredicate:productsPredicate];
    
    if (filteredGroups.count > 0)
    {
        mainGroup = filteredGroups[0];
        NSMutableArray* children = [_project.objects[mainGroup.key][@"children"] mutableCopy];
        [children addObject:dupTargetObj[@"productReference"]];
        _project.objects[mainGroup.key][@"children"] = children;
    }
}

- (NSString*)addTargetToRootObjectTargets:(NSMutableDictionary*)dupTargetObj
{
    NSString* dupTargetObjKey = [[XCKeyBuilder createUnique] build];
    
    _project.objects[dupTargetObjKey] = dupTargetObj;
    
    NSString* rootObjKey = _project.dataStore[@"rootObject"];
    NSMutableDictionary* rootObj = [_project.objects[rootObjKey] mutableCopy];
    NSMutableArray* rootObjTargets = [rootObj[@"targets"] mutableCopy];
    [rootObjTargets addObject:dupTargetObjKey];
    
    rootObj[@"targets"] = rootObjTargets;
    _project.objects[rootObjKey] = rootObj;
    
    return dupTargetObjKey;
}

@end
