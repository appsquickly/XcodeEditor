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



#import "XCSourceFile.h"
#import "XCTarget.h"
#import "Utils/XCKeyBuilder.h"
#import "XCProject+SubProject.h"
#import "XCSubProjectDefinition.h"


@implementation XCProject (SubProject)


#pragma mark sub-project related public methods

// returns the key for the reference proxy with the given path (nil if not found)
// does not use keysForProjectObjectsOfType:withIdentifier: because the identifier it uses for
// PBXReferenceProxy is different.
- (NSString*)referenceProxyKeyForName:(NSString*)name
{
    __block NSString* result = nil;
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop)
    {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXReferenceProxyType)
        {
            if ([[obj valueForKey:@"path"] isEqualTo:name])
            {
                result = key;
                *stop = YES;
            }
        }
    }];
    return result;
}

// returns an array of build products, excluding bundles with extensions other than ".bundle" (which is kind
// of gross, but I didn't see a better way to exclude test bundles without giving them their own XcodeSourceFileType)
- (NSArray*)buildProductsForTargets:(NSString*)xcodeprojKey
{
    NSMutableArray* results = [[NSMutableArray alloc] init];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop)
    {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXReferenceProxyType)
        {
            // make sure it belongs to the xcodeproj we're adding
            NSString* remoteRef = [obj valueForKey:@"remoteRef"];
            NSDictionary* containerProxy = [[self objects] valueForKey:remoteRef];
            NSString* containerPortal = [containerProxy valueForKey:@"containerPortal"];
            if ([containerPortal isEqualToString:xcodeprojKey])
            {
                XcodeSourceFileType type = XCSourceFileTypeFromStringRepresentation([obj valueForKey:@"fileType"]);
                NSString* path = (NSString*) [obj valueForKey:@"path"];
                if (type != Bundle || [[path pathExtension] isEqualToString:@"bundle"])
                {
                    [results addObject:[XCSourceFile sourceFileWithProject:self key:key type:type name:path sourceTree:nil path:nil]];
                }
            }
        }
    }];
    return results;
}

// makes PBXContainerItemProxy and PBXTargetDependency objects for the xcodeproj, and adds the dependency key
// to all the specified targets
- (void)addAsTargetDependency:(XCSubProjectDefinition*)xcodeprojDefinition toTargets:(NSArray*)targets
{
    for (XCTarget* target in targets)
    {
        // make a new PBXContainerItemProxy
        NSString* key = [[self fileWithName:[xcodeprojDefinition pathRelativeToProjectRoot]] key];
        NSString* containerItemProxyKey =
            [self makeContainerItemProxyForName:[xcodeprojDefinition name] fileRef:key proxyType:@"1" uniqueName:[target name]];
        // make a PBXTargetDependency
        NSString* targetDependencyKey =
            [self makeTargetDependency:[xcodeprojDefinition name] forContainerItemProxyKey:containerItemProxyKey uniqueName:[target name]];
        // add entry in each targets dependencies list
        [target addDependency:targetDependencyKey];
    }
}

// returns an array of keys for all project objects (not just files) that match the given criteria.  Since this is
// a convenience method intended to save typing elsewhere, each type has its own field to match to rather than each
// matching on name or path as you might expect.
- (NSArray*)keysForProjectObjectsOfType:(XcodeMemberType)memberType withIdentifier:(NSString*)identifier singleton:(BOOL)singleton
    required:(BOOL)required
{
    __block NSMutableArray* returnValue = [[NSMutableArray alloc] init];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop)
    {
        if ([[obj valueForKey:@"isa"] asMemberType] == memberType)
        {
            if (memberType == PBXContainerItemProxyType)
            {
                if ([[obj valueForKey:@"containerPortal"] isEqualToString:identifier])
                {
                    [returnValue addObject:key];
                }
            }
            else if (memberType == PBXReferenceProxyType)
            {
                if ([[obj valueForKey:@"remoteRef"] isEqualToString:identifier])
                {
                    [returnValue addObject:key];
                }
            }
            else if (memberType == PBXTargetDependencyType || memberType == PBXGroupType || memberType == PBXVariantGroupType)
            {
                if ([[obj valueForKey:@"name"] isEqualToString:identifier])
                {
                    [returnValue addObject:key];
                }
            }
            else if (memberType == PBXNativeTargetType)
            {
                for (NSString* dependencyKey in [obj valueForKey:@"dependencies"])
                {
                    if ([dependencyKey isEqualToString:identifier])
                    {
                        [returnValue addObject:key];
                    }
                }
            }
            else if (memberType == PBXBuildFileType)
            {
                if ([[obj valueForKey:@"fileRef"] isEqualToString:identifier])
                {
                    [returnValue addObject:key];
                }
            }
            else if (memberType == PBXProjectType)
            {
                [returnValue addObject:key];
            }
            else if (memberType == PBXFileReferenceType)
            {
                if ([[obj valueForKey:@"path"] isEqualToString:identifier])
                {
                    [returnValue addObject:key];
                }
            }
            else if (memberType == PBXFrameworksBuildPhaseType || memberType == PBXResourcesBuildPhaseType)
            {
                [returnValue addObject:key];
            }
            else
            {
                [NSException raise:NSInvalidArgumentException format:@"Unrecognized member type %@",
                                                                     [NSString stringFromMemberType:memberType]];
            }
        }
    }];
    if (singleton && [returnValue count] > 1)
    {
        [NSException raise:NSGenericException format:@"Searched for one instance of member type %@ with value %@, but found %ld",
                                                     [NSString stringFromMemberType:memberType], identifier, [returnValue count]];
    }
    if (required && [returnValue count] == 0)
    {
        [NSException raise:NSGenericException format:@"Searched for instances of member type %@ with value %@, but did not find any",
                                                     [NSString stringFromMemberType:memberType], identifier];
    }
    return returnValue;
}

// returns the dictionary for the PBXProject.  Raises an exception if more or less than 1 are found.
- (NSMutableDictionary*)PBXProjectDict
{
    NSString* PBXProjectKey;
    NSArray* PBXProjectKeys = [self keysForProjectObjectsOfType:PBXProjectType withIdentifier:nil singleton:YES required:YES];
    PBXProjectKey = [PBXProjectKeys objectAtIndex:0];
    NSMutableDictionary* PBXProjectDict = [[self objects] valueForKey:PBXProjectKey];
    return PBXProjectDict;
}

// returns the key of the PBXContainerItemProxy for the given name and proxy type. nil if not found.
- (NSString*)containerItemProxyKeyForName:(NSString*)name proxyType:(NSString*)proxyType
{
    NSMutableArray* results = [[NSMutableArray alloc] init];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop)
    {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXContainerItemProxyType)
        {
            NSString* remoteInfo = [obj valueForKey:@"remoteInfo"];
            NSString* proxy = [obj valueForKey:@"proxyType"];
            if ([remoteInfo isEqualToString:name] && [proxy isEqualToString:proxyType])
            {
                [results addObject:key];
            }
        }
    }];
    if ([results count] > 1)
    {
        [NSException raise:NSGenericException format:@"Searched for one instance of member type %@ with value %@, but found %ld",
                                                     @"PBXContainerItemProxy",
                                                     [NSString stringWithFormat:@"%@ and proxyType of %@", name, proxyType],
                                                     [results count]];
    }
    if ([results count] == 0)
    {
        return nil;
    }
    return [results objectAtIndex:0];
}

/* ====================================================================================================================================== */
#pragma mark - Private Methods
#pragma mark sub-project related private methods

// makes a PBXContainerItemProxy object for a given PBXFileReference object.  Replaces pre-existing objects.
- (NSString*)makeContainerItemProxyForName:(NSString*)name fileRef:(NSString*)fileRef proxyType:(NSString*)proxyType
    uniqueName:(NSString*)uniqueName
{
    NSString* keyName;
    if (uniqueName != nil)
    {
        keyName = [NSString stringWithFormat:@"%@-%@", name, uniqueName];
    }
    else
    {
        keyName = name;
    }
    // remove old if it exists
    NSString* existingProxyKey = [self containerItemProxyKeyForName:keyName proxyType:proxyType];
    if (existingProxyKey)
    {
        [[self objects] removeObjectForKey:existingProxyKey];
    }
    // make new one
    NSMutableDictionary* proxy = [NSMutableDictionary dictionary];
    [proxy setObject:[NSString stringFromMemberType:PBXContainerItemProxyType] forKey:@"isa"];
    [proxy setObject:fileRef forKey:@"containerPortal"];
    [proxy setObject:proxyType forKey:@"proxyType"];
    // give it a random key - the keys xcode puts here are not in the project file anywhere else
    NSString* key = [[XCKeyBuilder forItemNamed:[NSString stringWithFormat:@"%@-junk", keyName]] build];
    [proxy setObject:key forKey:@"remoteGlobalIDString"];
    [proxy setObject:name forKey:@"remoteInfo"];
    // add to project. use proxyType to generate key, so that multiple keys for the same name don't overwrite each other
    key = [[XCKeyBuilder forItemNamed:[NSString stringWithFormat:@"%@-containerProxy-%@", keyName, proxyType]] build];
    [[self objects] setObject:proxy forKey:key];

    return key;
}

// makes a PBXReferenceProxy object for a given PBXContainerProxy object.  Replaces pre-existing objects.
- (void)makeReferenceProxyForContainerItemProxy:(NSString*)containerItemProxyKey buildProductReference:(NSDictionary*)buildProductReference
{
    NSString* path = [buildProductReference valueForKey:@"path"];
    // remove old if any exists
    NSArray* existingProxyKeys = [self keysForProjectObjectsOfType:PBXReferenceProxyType withIdentifier:path singleton:NO required:NO];
    if ([existingProxyKeys count] > 0)
    {
        for (NSString* existingProxyKey in existingProxyKeys)
        {
            [[self objects] removeObjectForKey:existingProxyKey];
        }
    }
    // make new one
    NSMutableDictionary* proxy = [NSMutableDictionary dictionary];
    [proxy setObject:[NSString stringFromMemberType:PBXReferenceProxyType] forKey:@"isa"];
    [proxy setObject:[buildProductReference valueForKey:@"explicitFileType"] forKey:@"fileType"];
    [proxy setObject:path forKey:@"path"];
    [proxy setObject:containerItemProxyKey forKey:@"remoteRef"];
    [proxy setObject:[buildProductReference valueForKey:@"sourceTree"] forKey:@"sourceTree"];
    // add to project
    NSString* key = [[XCKeyBuilder forItemNamed:[NSString stringWithFormat:@"%@-referenceProxy", path]] build];
    [[self objects] setObject:proxy forKey:key];
}

// makes a PBXTargetDependency object for a given PBXContainerItemProxy.  Replaces pre-existing objects.
- (NSString*)makeTargetDependency:(NSString*)name forContainerItemProxyKey:(NSString*)containerItemProxyKey uniqueName:(NSString*)uniqueName
{
    NSString* keyName;
    if (uniqueName != nil)
    {
        keyName = [NSString stringWithFormat:@"%@-%@", name, uniqueName];
    }
    else
    {
        keyName = name;
    }
    // remove old if it exists
    NSArray* existingDependencyKeys =
        [self keysForProjectObjectsOfType:PBXTargetDependencyType withIdentifier:keyName singleton:NO required:NO];
    if ([existingDependencyKeys count] > 0)
    {
        for (NSString* existingDependencyKey in existingDependencyKeys)
        {
            [[self objects] removeObjectForKey:existingDependencyKey];
        }
    }
    // make new one
    NSMutableDictionary* targetDependency = [NSMutableDictionary dictionary];
    [targetDependency setObject:[NSString stringFromMemberType:PBXTargetDependencyType] forKey:@"isa"];
    [targetDependency setObject:name forKey:@"name"];
    [targetDependency setObject:containerItemProxyKey forKey:@"targetProxy"];
    NSString* targetDependencyKey = [[XCKeyBuilder forItemNamed:[NSString stringWithFormat:@"%@-targetProxy", keyName]] build];
    [[self objects] setObject:targetDependency forKey:targetDependencyKey];
    return targetDependencyKey;
}

// make a PBXContainerItemProxy and PBXReferenceProxy for each target in the subProject
- (void)addProxies:(XCSubProjectDefinition*)xcodeproj
{
    NSString* fileRef = [[self fileWithName:[xcodeproj pathRelativeToProjectRoot]] key];
    for (NSDictionary* target in [xcodeproj.subProject targets])
    {
        NSString* containerItemProxyKey =
            [self makeContainerItemProxyForName:[target valueForKey:@"name"] fileRef:fileRef proxyType:@"2" uniqueName:nil];
        NSString* productFileReferenceKey = [target valueForKey:@"productReference"];
        NSDictionary* productFileReference = [[xcodeproj.subProject objects] valueForKey:productFileReferenceKey];
        [self makeReferenceProxyForContainerItemProxy:containerItemProxyKey buildProductReference:productFileReference];
    }
}

// remove the PBXContainerItemProxy and PBXReferenceProxy objects for the given object key (which is the PBXFilereference
// for the xcodeproj file)
- (void)removeProxies:(NSString*)xcodeprojKey
{
    NSMutableArray* keysToDelete = [NSMutableArray array];
    // use the xcodeproj's PBXFileReference key to get the PBXContainerItemProxy keys
    NSArray* containerItemProxyKeys =
        [self keysForProjectObjectsOfType:PBXContainerItemProxyType withIdentifier:xcodeprojKey singleton:NO required:YES];
    // use the PBXContainerItemProxy keys to get the PBXReferenceProxy keys
    for (NSString* key in containerItemProxyKeys)
    {
        [keysToDelete addObjectsFromArray:[self keysForProjectObjectsOfType:PBXReferenceProxyType withIdentifier:key singleton:NO
            required:NO]];
        [keysToDelete addObject:key];
    }
    // remove all objects located above
    [keysToDelete enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop)
    {
        [[self objects] removeObjectForKey:obj];
    }];
}

// returns the Products group key for the given PBXFileReference key, nil if not found.
- (NSString*)productsGroupKeyForKey:(NSString*)key
{
    NSMutableArray* projectReferences = [[self PBXProjectDict] valueForKey:@"projectReferences"];
    NSString* productsGroupKey = nil;
    for (NSDictionary* projectRef in projectReferences)
    {
        if ([[projectRef valueForKey:@"ProjectRef"] isEqualToString:key])
        {
            // it's an error if we find more than one
            if (productsGroupKey != nil)
            {
                [NSException raise:NSGenericException format:@"Found more than one project reference for key %@", key];
            }
            productsGroupKey = [projectRef valueForKey:@"ProductGroup"];
        }
    }
    return productsGroupKey;
}

// removes a file reference from the projectReferences array in PBXProject (removing the array itself if this action
// leaves it empty).
- (void)removeFromProjectReferences:(NSString*)key forProductsGroup:(NSString*)productsGroupKey
{
    NSMutableArray* projectReferences = [[self PBXProjectDict] valueForKey:@"projectReferences"];
    // remove entry from PBXProject's projectReferences
    NSMutableArray* referencesToRemove = [NSMutableArray array];
    for (NSDictionary* projectRef in projectReferences)
    {
        if ([[projectRef valueForKey:@"ProjectRef"] isEqualToString:key])
        {
            [referencesToRemove addObject:projectRef];
        }
    }
    for (NSDictionary* projectRef in referencesToRemove)
    {
        [projectReferences removeObject:projectRef];
    }
    // if that was the last project reference, remove the array from the project
    if ([projectReferences count] == 0)
    {
        [[self PBXProjectDict] removeObjectForKey:@"projectReferences"];
    }
}

// removes a specific xcodeproj file from any targets (by name).  It's not an error if no entries are found,
// because we support adding a project file without adding it to any targets.
- (void)removeTargetDependencies:(NSString*)name
{
    // get the key for the PBXTargetDependency with name = xcodeproj file name (without extension)
    NSArray* targetDependencyKeys = [self keysForProjectObjectsOfType:PBXTargetDependencyType withIdentifier:name singleton:NO required:NO];
    // we might not find any if the project wasn't added to targets in the first place
    if ([targetDependencyKeys count] == 0)
    {
        return;
    }
    NSString* targetDependencyKey = [targetDependencyKeys objectAtIndex:0];
    // use the key for the PBXTargetDependency to get the key for any PBXNativeTargets that depend on it
    NSArray* nativeTargetKeys =
        [self keysForProjectObjectsOfType:PBXNativeTargetType withIdentifier:targetDependencyKey singleton:NO required:NO];
    // remove the key for the PBXTargetDependency from the PBXNativeTarget's dependencies arrays (leave in place even if empty)
    for (NSString* nativeTargetKey in nativeTargetKeys)
    {
        NSMutableDictionary* nativeTarget = [[self objects] objectForKey:nativeTargetKey];
        NSMutableArray* dependencies = [nativeTarget valueForKey:@"dependencies"];
        [dependencies removeObject:targetDependencyKey];
        [nativeTarget setObject:dependencies forKey:@"dependencies"];
    }
    // remove the PBXTargetDependency
    [[self objects] removeObjectForKey:targetDependencyKey];
}

@end