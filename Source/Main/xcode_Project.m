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

- (NSString*) makeContainerItemProxyForName:(NSString*)name fileRef:(NSString*)fileRef proxyType:(NSString*)proxyType;

- (NSString*) makeTargetDependency:(NSString*)name forContainerItemProxyKey:(NSString*)containerItemProxyKey;

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

/* ================================================================================================================== */
#pragma mark xcodeproj related public methods

// returns the key for the reference proxy with the given path (nil if not found)
// does not use keysForProjectObjectsOfType:withIdentifier: because the identifier it uses for
// PBXReferenceProxy is different.
- (NSString*) referenceProxyKeyForName:(NSString*)name {
    __block NSString* result = nil;
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

// returns an array of build products, excluding bundles with extensions other than ".bundle" (which is kind
// of gross, but I didn't see a better way to exclude test bundles without giving them their own XcodeSourceFileType)
- (NSArray*) buildProductsForTargets:(NSString*)xcodeprojKey {
    NSMutableArray* results = [[NSMutableArray alloc] init];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXReferenceProxy) {
            // make sure it belongs to the xcodeproj we're adding
            NSString* remoteRef = [obj valueForKey:@"remoteRef"];
            NSDictionary* containerProxy = [[self objects] valueForKey:remoteRef];
            NSString* containerPortal = [containerProxy valueForKey:@"containerPortal"];
            if ([containerPortal isEqualToString:xcodeprojKey]) {
                XcodeSourceFileType type = [(NSString *)[obj valueForKey:@"fileType"] asSourceFileType];
                NSString* path = (NSString *)[obj valueForKey:@"path"];
                if (type != Bundle || [[path pathExtension] isEqualToString:@"bundle"]) {
                    [results addObject:[SourceFile sourceFileWithProject:self key:key type:type name:path sourceTree:nil]];
                }
            }
        }
    }];
    return results;
}

// makes PBXContainerItemProxy and PBXTargetDependency objects for the xcodeproj, and adds the dependency key
// to all the specified targets
- (void) addAsTargetDependency:(XcodeprojDefinition*)xcodeprojDefinition toTargets:(NSArray*)targets {
    // make a new PBXContainerItemProxy
    NSString* name = [xcodeprojDefinition sourceFileName];
    NSString* key = [[self fileWithName:[xcodeprojDefinition pathRelativeToProjectRoot]] key];
    NSString* containerItemProxyKey = [self makeContainerItemProxyForName:name fileRef:key proxyType:@"1"];
    // make a PBXTargetDependency
    NSString* targetDependencyKey = [self makeTargetDependency:name forContainerItemProxyKey:containerItemProxyKey];
    // add entry in each targets dependencies list
    for (Target* target in targets) {
        [target addDependency:targetDependencyKey];
    }
}

// compares the given path to the filePath of the project, and returns a relative version
- (NSString*) makePathRelativeToProjectRoot:(NSString*)fullPath {
    NSMutableArray* projectPathComponents = [[_filePath pathComponents] mutableCopy];
    NSArray* objectPathComponents = [fullPath pathComponents];
    NSString* convertedPath = [[NSString alloc] init];
    
    // skip over path components from root that are equal
    int limit = ([projectPathComponents count] > [objectPathComponents count]) ? [projectPathComponents count] : [objectPathComponents count];
    int index1 = 0;
    for (; index1 < limit; index1++) {
        if ([[projectPathComponents objectAtIndex:index1] isEqualToString:[objectPathComponents objectAtIndex:index1]])
            continue;
        else
            break;
    }
    // insert "../" for each remaining path component in project's xcodeproj path
    for (int index2 = 0; index2 < ([projectPathComponents count] - index1); index2++) {
        convertedPath = [convertedPath stringByAppendingString:@"../"];
    }
    // tack on the unique part of the object's path
    for (int index3 = index1; index3 < [objectPathComponents count] - 1; index3++) {
        convertedPath = [convertedPath stringByAppendingFormat:@"%@/", [objectPathComponents objectAtIndex:index3]];
    }
    return [convertedPath stringByAppendingString:[objectPathComponents lastObject]];
}

// returns an array of keys for all project objects (not just files) that match the given criteria
- (NSArray*) keysForProjectObjectsOfType:(XcodeMemberType)memberType  withIdentifier:(NSString*)identifier singleton:(BOOL)singleton required:(BOOL)required {
    __block NSMutableArray* returnValue = [[NSMutableArray alloc] init];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == memberType) {
            if (memberType == PBXContainerItemProxy) {
                if ([[obj valueForKey:@"containerPortal"] isEqualToString:identifier]) {
                    [returnValue addObject:key];
                }
            } else if (memberType == PBXReferenceProxy) {
                if ([[obj valueForKey:@"remoteRef"] isEqualToString:identifier]) {
                    [returnValue addObject:key];
                }
            } else if (memberType == PBXTargetDependency || memberType == PBXGroup) {
                if ([[obj valueForKey:@"name"] isEqualToString:identifier]) {
                    [returnValue addObject:key];
                }
            } else if (memberType == PBXNativeTarget) {
                for (NSString* dependencyKey in [obj valueForKey:@"dependencies"]) {
                    if ([dependencyKey isEqualToString:identifier]) {
                        [returnValue addObject:key];
                    }
                }
            } else if (memberType == PBXBuildFile) {
                if ([[obj valueForKey:@"fileRef"] isEqualToString:identifier]) {
                    [returnValue addObject:key];
                }
            } else if (memberType == PBXProject) {
                [returnValue addObject:key];
            } else if (memberType == PBXFileReference) {
                if ([[obj valueForKey:@"path"] isEqualToString:identifier]) {
                    [returnValue addObject:key];
                }
            } else {
                [NSException raise:NSInvalidArgumentException format:@"Unrecognized member type %@", memberType];
            }
            if (singleton && [returnValue count] > 1) {
                [NSException raise:NSGenericException format:@"Searched for one instance of member type %@ with value %@, but found %d", memberType, identifier, [returnValue count]];
            }
            if (required && [returnValue count] == 0) {
                [NSException raise:NSGenericException format:@"Searched for instances of member type %@ with value %@, but did not find any", memberType, identifier];
            }
        }
    }];
    return returnValue;
}

// returns the dictionary for the PBXProject.  Raises an exception if more or less than 1 are found.
- (NSMutableDictionary*) PBXProjectDict {
    NSString* PBXProjectKey;
    NSArray* PBXProjectKeys = [self keysForProjectObjectsOfType:PBXProject withIdentifier:nil singleton:YES required:YES];
    PBXProjectKey = [PBXProjectKeys objectAtIndex:0];
    NSMutableDictionary *PBXProjectDict = [[self objects] valueForKey:PBXProjectKey];
    return PBXProjectDict;
}

#pragma mark xcodeproj related private methods

// returns the key of the PBXContainerItemProxy for the given name and proxy type
- (NSString*) containerItemProxyKeyForName:(NSString*)name proxyType:(NSString*)proxyType {
    NSMutableArray* results;
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXContainerItemProxy) {
            NSString* remoteInfo = [obj valueForKey:@"remoteInfo"];
            NSString* proxy = [obj valueForKey:@"proxyType"];
            if ([remoteInfo isEqualToString:name] && [proxy isEqualToString:proxyType] ) {
                [results addObject:key];
            }
        }
    }];
    if ([results count] > 1) {
        [NSException raise:NSGenericException format:@"Searched for one instance of member type %@ with value %@, but found %d", @"PBXContainerItemProxy", [NSString stringWithFormat:@"%@ and proxyType of %@", name, proxyType], [results count]];
    }
    return [results objectAtIndex:0];
}

// makes a PBXContainerItemProxy object for a given PBXFileReference object.  Replaces pre-existing objects.
- (NSString*) makeContainerItemProxyForName:(NSString*)name fileRef:(NSString*)fileRef proxyType:(NSString*)proxyType {
    // remove old if it exists
    NSString *existingProxyKey = [self containerItemProxyKeyForName:name proxyType:proxyType];
    if (existingProxyKey) {
        [[self objects] removeObjectForKey:existingProxyKey];
    }
    // make new one
    NSMutableDictionary* proxy = [NSMutableDictionary dictionary];
    [proxy setObject:[NSString stringFromMemberType:PBXContainerItemProxy] forKey:@"isa"];
    [proxy setObject:fileRef forKey:@"containerPortal"];
    [proxy setObject:proxyType forKey:@"proxyType"];
    // give it a random key - the keys xcode puts here are not in the project file anywhere else
    NSString *key = [[KeyBuilder forItemNamed:[NSString stringWithFormat:@"%@-junk", name]] build];
    [proxy setObject:key forKey:@"remoteGlobalIDString"];
    [proxy setObject:name forKey:@"remoteInfo"];
    // add to project. use proxyType to generate key, so that multiple keys for the same name don't overwrite each other
    key = [[KeyBuilder forItemNamed:[NSString stringWithFormat:@"%@-containerProxy-%@", name, proxyType]] build];
    [[self objects] setObject:proxy forKey:key];
    
    return key;
}

// makes a PBXReferenceProxy object for a given PBXContainerProxy object.  Replaces pre-existing objects.
- (void) makeReferenceProxyForContainerItemProxy:(NSString*)containerItemProxyKey buildProductReference:(NSDictionary*)buildProductReference {
    NSString* path = [buildProductReference valueForKey:@"path"];
    // remove old if any exists
    NSArray *existingProxyKeys = [self keysForProjectObjectsOfType:PBXReferenceProxy withIdentifier:path singleton:NO required:NO];
    if ([existingProxyKeys count] > 0) {
        for (NSString* existingProxyKey in existingProxyKeys) {
            [[self objects] removeObjectForKey:existingProxyKey];
        }
    }
    // make new one
    NSMutableDictionary* proxy = [NSMutableDictionary dictionary];
    [proxy setObject:[NSString stringFromMemberType:PBXReferenceProxy] forKey:@"isa"];
    [proxy setObject:[buildProductReference valueForKey:@"explicitFileType"] forKey:@"fileType"];
    [proxy setObject:path forKey:@"path"];
    [proxy setObject:containerItemProxyKey forKey:@"remoteRef"];
    [proxy setObject:[buildProductReference valueForKey:@"sourceTree"] forKey:@"sourceTree"];
    // add to project
    NSString* key = [[KeyBuilder forItemNamed:[NSString stringWithFormat:@"%@-referenceProxy", path]] build];
    [[self objects] setObject:proxy forKey:key];
}

// makes a PBXTargetDependency object for a given PBXContainerItemProxy.  Replaces pre-existing objects.
- (NSString*) makeTargetDependency:(NSString*)name forContainerItemProxyKey:(NSString*)containerItemProxyKey {
    // remove old if it exists
    NSArray *existingDependencyKeys = [self keysForProjectObjectsOfType:PBXTargetDependency withIdentifier:name singleton:NO required:NO];
    if ([existingDependencyKeys count] > 0) {
        for (NSString* existingDependencyKey in existingDependencyKeys) {
            [[self objects] removeObjectForKey:existingDependencyKey];
        }
    }
    // make new one
    NSMutableDictionary *targetDependency = [NSMutableDictionary dictionary];
    [targetDependency setObject:[NSString stringFromMemberType:PBXTargetDependency] forKey:@"isa"];
    [targetDependency setObject:name forKey:@"name"];
    [targetDependency setObject:containerItemProxyKey forKey:@"targetProxy"];
    NSString* targetDependencyKey = [[KeyBuilder forItemNamed:[NSString stringWithFormat:@"%@-targetProxy", name]] build];
    [[self objects] setObject:targetDependency forKey:targetDependencyKey];
    return targetDependencyKey;
}

// make a PBXContainerItemProxy and PBXReferenceProxy for each target in the subproject
- (void) addProxies:(XcodeprojDefinition *)xcodeproj {
    NSString* fileRef = [[self fileWithName:[xcodeproj pathRelativeToProjectRoot]] key];
    for (NSDictionary* target in [xcodeproj.subproject targets]) {
        NSString* containerItemProxyKey = [self makeContainerItemProxyForName:[target valueForKey:@"productName"] fileRef:fileRef proxyType:@"2"];
        NSString* productFileReferenceKey = [target valueForKey:@"productReference"];
        NSDictionary* productFileReference = [[xcodeproj.subproject objects] valueForKey:productFileReferenceKey];
        [self makeReferenceProxyForContainerItemProxy:containerItemProxyKey buildProductReference:productFileReference];
    }
}

// remove the PBXContainerItemProxy and PBXReferenceProxy objects for the given object key (which is the PBXFilereference
// for the xcodeproj file.
- (void) removeProxies:(NSString*)xcodeprojKey {
    NSMutableArray* keysToDelete = [[NSMutableArray alloc] init];
    // use the xcodeproj's PBXFileReference key to get the PBXContainerItemProxy keys
    NSArray* containerItemProxyKeys = [self keysForProjectObjectsOfType:PBXContainerItemProxy withIdentifier:xcodeprojKey singleton:NO required:YES];
    // use the PBXContainerItemProxy keys to get the PBXReferenceProxy keys
    for (NSString* key in containerItemProxyKeys) {
        [keysToDelete addObjectsFromArray:[self keysForProjectObjectsOfType:PBXReferenceProxy withIdentifier:key singleton:NO required:YES]];
        [keysToDelete addObject:key];
    }
    // remove all objects located above
    [keysToDelete enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        [[self objects] removeObjectForKey:obj];
    }];
}

// removes a file reference from the projectReferences array in PBXProject (removing the array itself if this action
// leaves it empty).  Returns the ProductGroup key from the removed reference.
- (NSString*) removeFromProjectReferences:(NSString*)key {
    NSMutableArray* projectReferences = [[self PBXProjectDict] valueForKey:@"projectReferences"];
    // remove entry from PBXProject's projectReferences
    NSString* productsGroupKey = nil;
    NSMutableArray* referencesToRemove = [[NSMutableArray alloc] init];
    for (NSDictionary* projectRef in projectReferences) {
        if ([[projectRef valueForKey:@"ProjectRef"] isEqualToString:key]) {
            // it's an error if we find more than one
            if (productsGroupKey != nil) {
                [NSException raise:NSGenericException format:@"Found more than one project reference for key %@", key];
            }
            productsGroupKey = [projectRef valueForKey:@"ProductGroup"];
            [referencesToRemove addObject:projectRef];
        }
    }
    for (NSDictionary* projectRef in referencesToRemove) {
        [projectReferences removeObject:projectRef];
    }
    // if that was the last project reference, remove the array from the project
    if ([projectReferences count] == 0) {
        [[self PBXProjectDict] removeObjectForKey:@"projectReferences"];
    }
    return productsGroupKey;
}

// removes a specific xcodeproj file from any targets (by name).  It's not an error if no entries are found,
// because we support adding a project file without adding it to any targets.
- (void) removeTargetDependencies:(NSString*)name {
    // get the key for the PBXTargetDependency with name = xcodeproj file name (without extension)
    NSArray* targetDependencyKeys = [self keysForProjectObjectsOfType:PBXTargetDependency withIdentifier:name singleton:YES required:NO];
    NSString* targetDependencyKey = [targetDependencyKeys objectAtIndex:0];
    // use the key for the PBXTargetDependency to get the key for the PBXNativeTarget
    NSArray* nativeTargetKeys = [self keysForProjectObjectsOfType:PBXNativeTarget withIdentifier:targetDependencyKey singleton:YES required:NO];
    // remove the key for the PBXTargetDependency from the PBXNativeTarget's dependencies array (leave in place even if empty)
    NSMutableDictionary* nativeTarget = [[self objects] valueForKey:[nativeTargetKeys objectAtIndex:0]];
    NSMutableArray* dependencies = [nativeTarget valueForKey:@"dependencies"];
    [dependencies removeObject:targetDependencyKey];
    [nativeTarget setObject:dependencies forKey:@"dependencies"];
    // remove the PBXTargetDependency
    [[self objects] removeObjectForKey:targetDependencyKey];
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