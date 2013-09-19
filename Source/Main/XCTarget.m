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
#import "XCBuildConfiguration.h"
#import "Utils/XCMemoryUtils.h"

/* ================================================================================================================== */
@interface XCTarget ()

- (XCSourceFile*) buildFileWithKey:(NSString*)key;

- (void) flagMembersAsDirty;

@end


@implementation XCTarget

@synthesize key = _key;
@synthesize name = _name;
@synthesize productName = _productName;
@synthesize productReference = _productReference;

/* ================================================= Class Methods ================================================== */
+ (XCTarget*) targetWithProject:(XCProject*)project key:(NSString*)key name:(NSString*)name
        productName:(NSString*)productName productReference:(NSString*)productReference {
    return XCAutorelease([[XCTarget alloc]
            initWithProject:project key:key name:name productName:productName productReference:productReference])
}


/* ================================================== Initializers ================================================== */
- (id) initWithProject:(XCProject*)project key:(NSString*)key name:(NSString*)name productName:(NSString*)productName
        productReference:(NSString*)productReference {
    self = [super init];
    if (self) {
        _project = XCRetain(project)
        _key = [key copy];
        _name = [name copy];
        _productName = [productName copy];
        _productReference = [productReference copy];
    }
    return self;
}

- (NSArray*) resources {
    if (_resources == nil) {
        _resources = [[NSMutableArray alloc] init];
        for (NSString* buildPhaseKey in [[[_project objects] objectForKey:_key] objectForKey:@"buildPhases"]) {
            NSDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
            if ([[buildPhase valueForKey:@"isa"] asMemberType] == PBXResourcesBuildPhaseType) {
                for (NSString* buildFileKey in [buildPhase objectForKey:@"files"]) {
                    XCSourceFile* targetMember = [self buildFileWithKey:buildFileKey];
                    if (targetMember) {
                        [_resources addObject:[self buildFileWithKey:buildFileKey]];
                    }
                }
            }
        }
    }

    return _resources;
}

/* ================================================== Deallocation ================================================== */
- (void) dealloc {
	XCRelease(_project)
	XCRelease(_key)
	XCRelease(_name)
	XCRelease(_productName)
	XCRelease(_productReference)
	XCRelease(_members)
	XCRelease(_resources)
	XCRelease(_defaultConfigurationName)

	XCSuperDealloc
}

/* ================================================ Interface Methods =============================================== */
- (NSDictionary*) configurations {
	if (_configurations == nil) {
		NSString *buildConfigurationRootSectionKey = [[[_project objects] objectForKey:_key] objectForKey:@"buildConfigurationList"];
		NSDictionary *buildConfigurationDictionary = [[_project objects] objectForKey:buildConfigurationRootSectionKey];
		_configurations = [[XCBuildConfiguration buildConfigurationsFromArray:[buildConfigurationDictionary objectForKey:@"buildConfigurations"]
                                                                         inProject:_project] mutableCopy];
		_defaultConfigurationName = [[buildConfigurationDictionary objectForKey:@"defaultConfigurationName"] copy];
	}

	return _configurations;
}

- (XCBuildConfiguration*)defaultConfiguration {
	return [[self configurations] objectForKey:_defaultConfigurationName];
}

- (XCBuildConfiguration*)configurationWithName:(NSString*)name
{
    return [[self configurations] objectForKey:name];
}

- (NSArray*) members {
    if (_members == nil) {
        _members = [[NSMutableArray alloc] init];
        for (NSString* buildPhaseKey in [[[_project objects] objectForKey:_key] objectForKey:@"buildPhases"]) {
            NSDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
            if ([[buildPhase valueForKey:@"isa"] asMemberType] == PBXSourcesBuildPhaseType ||
                    [[buildPhase valueForKey:@"isa"] asMemberType] == PBXFrameworksBuildPhaseType) {
                for (NSString* buildFileKey in [buildPhase objectForKey:@"files"]) {
                    XCSourceFile* targetMember = [self buildFileWithKey:buildFileKey];
                    if (targetMember) {
                        [_members addObject:[_project fileWithKey:targetMember.key]];
                    }
                }
            }
        }
    }
    return _members;
}

- (void) addMember:(XCSourceFile*)member {
    [member becomeBuildFile];
    NSDictionary* target = [[_project objects] objectForKey:_key];

    for (NSString* buildPhaseKey in [target objectForKey:@"buildPhases"]) {
        NSMutableDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
        if ([[buildPhase valueForKey:@"isa"] asMemberType] == [member buildPhase]) {

            NSMutableArray* files = [buildPhase objectForKey:@"files"];
            if (![files containsObject:[member buildFileKey]]) {
                [files addObject:[member buildFileKey]];
            }

            [buildPhase setObject:files forKey:@"files"];
        }
    }
    [self flagMembersAsDirty];
}

- (NSDictionary*) buildRefWithFileRefKey {
    NSMutableDictionary* buildRefWithFileRefDict = [NSMutableDictionary dictionary];
    NSDictionary* allObjects = [_project objects];
    NSArray* keys = [allObjects allKeys];

    for (NSString* key in keys) {
        NSDictionary* dictionaryInfo = [allObjects objectForKey:key];

        NSString* type = [dictionaryInfo objectForKey:@"isa"];
        if (type) {
            if ([type isEqualToString:@"PBXBuildFile"]) {
                NSString* fileRef = [dictionaryInfo objectForKey:@"fileRef"];

                if (fileRef) {
                    [buildRefWithFileRefDict setObject:key forKey:fileRef];
                }
            }
        }
    }
    return buildRefWithFileRefDict;
}

- (void) removeMemberWithKey:(NSString*)key {

    NSDictionary* buildRefWithFileRef = [self buildRefWithFileRefKey];
    NSDictionary* target = [[_project objects] objectForKey:_key];
    NSString* buildRef = [buildRefWithFileRef objectForKey:key];

    if (!buildRef) {
        return;
    }

    for (NSString* buildPhaseKey in [target objectForKey:@"buildPhases"]) {
        NSMutableDictionary* buildPhase = [[_project objects] objectForKey:buildPhaseKey];
        NSMutableArray* files = [buildPhase objectForKey:@"files"];

        [files removeObjectIdenticalTo:buildRef];
        [buildPhase setObject:files forKey:@"files"];
    }
    [self flagMembersAsDirty];
}

- (void) removeMembersWithKeys:(NSArray*)keys {
    for (NSString* key in keys) {
        [self removeMemberWithKey:key];
    }
}

- (void) addDependency:(NSString*)key {
    NSDictionary* targetObj = [[_project objects] objectForKey:_key];
    NSMutableArray* dependencies = [targetObj valueForKey:@"dependencies"];
    // add only if not already there
    BOOL found = NO;
    for (NSString* dependency in dependencies) {
        if ([dependency isEqualToString:key]) {
            found = YES;
            break;
        }
    }
    if (!found) {
        [dependencies addObject:key];
    }
}

- (instancetype) duplicateWithTargetName:(NSString*)targetName
                             productName:(NSString*)productName {
    
    NSDictionary* targetObj           = _project.objects[_key];
    NSMutableDictionary* dupTargetObj = XCAutorelease([targetObj mutableCopy]);
    
    dupTargetObj[@"name"]        = targetName;
    dupTargetObj[@"productName"] = productName;

    NSString *buildConfigurationListKey = dupTargetObj[@"buildConfigurationList"];

    void(^visitor)(NSMutableDictionary*) =  ^(NSMutableDictionary* buildConfiguration) {
        buildConfiguration[@"buildSettings"][@"PRODUCT_NAME"] = productName;
    };
    
    dupTargetObj[@"buildConfigurationList"] = [XCBuildConfiguration duplicatedBuildConfigurationListWithKey: buildConfigurationListKey
                                                                                                  inProject: _project
                                                                              withBuildConfigurationVisitor: visitor];
    
    [self duplicateProductReferenceForTargetObject: dupTargetObj
                                          withProductName: productName];
    
    [self duplicateBuildPhasesForTargetObject: dupTargetObj];
 
    [self addReferenceToProductsGroupForTargetObject: dupTargetObj];
 
    NSString *dupTargetObjKey = [self addTargetToRootObjectTargets:dupTargetObj];
    
    [_project dropCache];

    return XCAutorelease([[XCTarget alloc] initWithProject: _project
                                                       key: dupTargetObjKey
                                                      name: targetName
                                               productName: productName
                                          productReference: dupTargetObj[@"productReference"]]);
}

/* ================================================== Utility Methods =============================================== */
- (NSString*) description {
    return [NSString stringWithFormat:@"Target: name=%@, files=%@", _name, _members];
}

/* ================================================== Private Methods =============================================== */
- (XCSourceFile*) buildFileWithKey:(NSString*)theKey {
    NSDictionary* obj = [[_project objects] valueForKey:theKey];
    if (obj) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXBuildFileType) {
            return [_project fileWithKey:[obj valueForKey:@"fileRef"]];
        }
    }
    return nil;
}

- (void) flagMembersAsDirty {
	XCRelease(_members)
    _members = nil;
}

- (void) duplicateProductReferenceForTargetObject:(NSMutableDictionary *)dupTargetObj
                                  withProductName:(NSString *)productName {
    
    NSString* productReferenceKey = dupTargetObj[@"productReference"];
    NSMutableDictionary* dupProductReference = XCAutorelease([_project.objects[productReferenceKey] mutableCopy]);
    
    NSString* path = dupProductReference[@"path"];
    NSString* dupPath = [path stringByDeletingLastPathComponent];
    dupPath = [dupPath stringByAppendingPathComponent: productName];
    dupPath = [dupPath stringByAppendingPathExtension: @"app"];
    dupProductReference[@"path"] = dupPath;
    
    NSString* dupProductReferenceKey = [[XCKeyBuilder createUnique] build];
    
    _project.objects[dupProductReferenceKey] = dupProductReference;
    dupTargetObj[@"productReference"]        = dupProductReferenceKey;
}

- (void) duplicateBuildPhasesForTargetObject:(NSMutableDictionary*)dupTargetObj {
    
    NSMutableArray* buildPhases = [NSMutableArray array];
    
    for(NSString* buildPhaseKey in dupTargetObj[@"buildPhases"]) {
        
        NSMutableDictionary* dupBuildPhase = XCAutorelease([_project.objects[buildPhaseKey] mutableCopy]);
        NSMutableArray* dupFiles           = [NSMutableArray array];
        
        for(NSString* fileKey in dupBuildPhase[@"files"]) {
            
            NSMutableDictionary* dupFile = XCAutorelease([_project.objects[fileKey] mutableCopy]);
            NSString* dupFileKey = [[XCKeyBuilder createUnique] build];
            
            _project.objects[dupFileKey] = dupFile;
            [dupFiles addObject: dupFileKey];
        }
        
        dupBuildPhase[@"files"] = dupFiles;
        
        NSString* dupBuildPhaseKey = [[XCKeyBuilder createUnique] build];
        _project.objects[dupBuildPhaseKey] = dupBuildPhase;
        [buildPhases addObject: dupBuildPhaseKey];
    }
    
    dupTargetObj[@"buildPhases"] = buildPhases;
}

- (void)addReferenceToProductsGroupForTargetObject:(NSMutableDictionary *)dupTargetObj {

    XCGroup* mainGroup = nil;
    NSPredicate* productsPredicate = [NSPredicate predicateWithFormat:@"displayName == 'Products'"];
    NSArray* filteredGroups = [_project.groups filteredArrayUsingPredicate: productsPredicate];
    
    if(filteredGroups.count > 0) {
        mainGroup = filteredGroups[0];
        NSMutableArray* children = XCAutorelease([_project.objects[mainGroup.key][@"children"] mutableCopy]);
        [children addObject: dupTargetObj[@"productReference"]];
        _project.objects[mainGroup.key][@"children"] = children;
    }
}

- (NSString *) addTargetToRootObjectTargets:(NSMutableDictionary *)dupTargetObj
{
    NSString* dupTargetObjKey = [[XCKeyBuilder createUnique] build];
    
    _project.objects[dupTargetObjKey] = dupTargetObj;
    
    NSString* rootObjKey = _project.dataStore[@"rootObject"];
    NSMutableDictionary* rootObj   = XCAutorelease([_project.objects[rootObjKey] mutableCopy]);
    NSMutableArray* rootObjTargets = XCAutorelease([rootObj[@"targets"] mutableCopy]);
    [rootObjTargets addObject: dupTargetObjKey];
    
    rootObj[@"targets"] = rootObjTargets;
    _project.objects[rootObjKey] = rootObj;
    
    return dupTargetObjKey;
}

@end
