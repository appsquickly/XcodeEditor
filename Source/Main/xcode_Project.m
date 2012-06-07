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

- (NSString*) findContainerItemProxyForName:(NSString*)name proxyType:(NSString*)proxyType {
    __block NSString* itemKey = nil;
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXContainerItemProxy) {
            NSString* remoteInfo = [obj valueForKey:@"remoteInfo"];
            NSString* proxy = [obj valueForKey:@"proxyType"];
            if ([remoteInfo isEqualToString:name] && [proxy isEqualToString:proxyType] ) {
                itemKey = key;
                *stop = YES;
            }
        }
    }];
    return itemKey;
}

- (NSString*) makeContainerItemProxyForName:(NSString*)name fileRef:(NSString*)fileRef proxyType:(NSString*)proxyType {
    // remove old if it exists
    NSString *existingProxyKey = [self findContainerItemProxyForName:name proxyType:proxyType];
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

- (NSString*) findReferenceProxyForName:(NSString*)name {
    __block NSString* proxyKey = nil;
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXReferenceProxy) {
            NSString* path = [obj valueForKey:@"path"];
            if ([path isEqualToString:name]) {
                proxyKey = key;
                *stop = YES;
            }
        }
    }];
    return proxyKey;
}

- (void) makeReferenceProxyForContainerItemProxy:(NSString*)containerItemProxyKey buildProductReference:(NSDictionary*)buildProductReference {
    NSString* path = [buildProductReference valueForKey:@"path"];
    // remove old if it exists
    NSString *existingProxyKey = [self findReferenceProxyForName:path];
    if (existingProxyKey) {
        [[self objects] removeObjectForKey:existingProxyKey];
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

- (NSString*) findTargetDependencyForName:(NSString*)name {
    __block NSString* dependencyKey = nil;
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXTargetDependency) {
            NSString* targetName = [obj valueForKey:@"name"];
            if ([targetName isEqualToString:name]) {
                dependencyKey = key;
                *stop = YES;
            }
        }
    }];
    return dependencyKey;
}

- (NSString*) makeTargetDependency:(NSString*)name forContainerItemProxyKey:(NSString*)containerItemProxyKey {
    // remove old if it exists
    NSString *existingDependencyKey = [self findTargetDependencyForName:name];
    if (existingDependencyKey) {
        [[self objects] removeObjectForKey:existingDependencyKey];
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

- (void) addProxies:(XcodeprojDefinition *)xcodeproj {
    NSString* fileRef = [[self fileWithName:[xcodeproj pathRelativeToProjectRoot]] key];
    for (NSDictionary* target in [xcodeproj.subproject targets]) {
        NSString* containerItemProxyKey = [self makeContainerItemProxyForName:[target valueForKey:@"productName"] fileRef:fileRef proxyType:@"2"];
        NSString* productFileReferenceKey = [target valueForKey:@"productReference"];
        NSDictionary* productFileReference = [[xcodeproj.subproject objects] valueForKey:productFileReferenceKey];
        [self makeReferenceProxyForContainerItemProxy:containerItemProxyKey buildProductReference:productFileReference];
    }
}

// this is kind of gross, but I didn't see any other way to avoid processing the test bundle, without giving
// it its own type.  I don't want to add the subproject's test bundle to any of the main project's targets.
- (NSArray*) buildProductsForTargets {
    NSMutableArray* results = [[NSMutableArray alloc] init];
    [[self objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXReferenceProxy) {
            XcodeSourceFileType type = [(NSString *)[obj valueForKey:@"fileType"] asSourceFileType];
            NSString* path = (NSString *)[obj valueForKey:@"path"];
            if (type == Archive) {
                [results addObject:[SourceFile sourceFileWithProject:self key:key type:type name:path sourceTree:nil]];
            } else {
                if (type == Bundle) {
                    if ([[path pathExtension] isEqualToString:@"bundle"]) {
                        [results addObject:[SourceFile sourceFileWithProject:self key:key type:type name:path sourceTree:nil]];
                    }
                }
            }
        }
    }];
    return results;
}

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
#pragma mark xcodeproj related methods

// returns the key for the reference proxy with the given path (nil if not found)
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

// finds the given project file in the current project and returns an XcodeprojDefinition for it (nil if not found)
- (XcodeprojDefinition*) xcodeprojDefinitionWithName:(NSString*)name projPath:(NSString*)projPath type:(XcodeSourceFileType)type {
    XcodeprojDefinition* xcodeprojDefinition = nil;
    NSString* fullName;
    if (![name hasSuffix:@".xcodeproj"]) {
        fullName = [name stringByAppendingString:@".xcodeproj"];
    } else {
        fullName = name;
    }
    NSString* filePath = [[self makePathRelativeToProjectRoot:projPath] stringByAppendingFormat:@"/%@", fullName];
    for (SourceFile* file in [self files]) {
        if ([filePath isEqualToString:[file name]]) {
            xcodeprojDefinition = [[XcodeprojDefinition alloc] initWithName:name projPath:projPath type:type];
            break;
        }
    }
    return xcodeprojDefinition;
}

// returns an array of keys for all project objects (not just files) that match the given criteria
- (NSArray*) keysForProjectObjectsOfType:(XcodeMemberType)memberType  withIdentifier:(NSString*)identifier {
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
                *stop = YES;  // we know there's only one of these, so no need to keep going
            }
        }
    }];
    return returnValue;
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