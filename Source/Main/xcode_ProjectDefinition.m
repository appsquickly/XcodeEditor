////////////////////////////////////////////////////////////////////////////////
//
//  Synapticats, LLC
//  Copyright 2012 Synapticats, LLC
//  All Rights Reserved.
//
//  NOTICE: Expanz and Synapticats, LLC permit you to use, modify, and distribute 
//  this file in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "xcode_ProjectDefinition.h"

@interface xcode_ProjectDefinition ()
@property(nonatomic, strong, readwrite) NSString* relativePath;
@end

@implementation xcode_ProjectDefinition

@synthesize sourceFileName = _sourceFileName;
@synthesize path = _path;
@synthesize type = _type;
@synthesize subproject = _subproject;
@synthesize relativePath = _relativePath;
@synthesize key = _key;
@synthesize fullProjectPath = _fullProjectPath;

/* ================================================= Class Methods ================================================== */
+ (ProjectDefinition*) projectDefinitionWithName:(NSString*)name path:(NSString*)path {

    return [[ProjectDefinition alloc] initWithName:name path:path];
}

/* ================================================== Initializers ================================================== */

// Note - _path is most often going to be an absolute path.  The method pathRelativeToProjectRoot below should be
// used to get the form that's stored in the main project file.
- (id) initWithName:(NSString*)name path:(NSString*)path {
    self = [super init];
    if (self) {
        _sourceFileName = [name copy];
        _path = [path copy];
        _type = XcodeProject;
        _subproject = [[Project alloc] initWithFilePath:[NSString stringWithFormat:@"%@/%@.xcodeproj", path, name]];
    }
    return self;
}

/* ================================================ Interface Methods =============================================== */
- (NSString*) xcodeprojFileName {
    return [_sourceFileName stringByAppendingString:@".xcodeproj"];
}

- (NSString*) xcodeprojFullPathName {
    return [NSString stringWithFormat:@"%@/%@", _path, [_sourceFileName stringByAppendingString:@".xcodeproj"]];
}

// returns an array of names of the build products of this project
- (NSArray*) buildProductNames {
    NSMutableArray* results = [NSMutableArray array];
    NSDictionary* objects = [_subproject objects];
    [objects enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXProject) {
            NSString* productRefGroupKey = [obj valueForKey:@"productRefGroup"];
            NSDictionary* products = [objects valueForKey:productRefGroupKey];
            NSArray* children = [products valueForKey:@"children"];
            for (NSString* childKey in children) {
                NSDictionary* child = [objects valueForKey:childKey];
                [results addObject:[child valueForKey:@"path"]];
            }
        }
    }];
    return results;
}

// returns the key of the PBXFileReference of the xcodeproj file
- (NSString*) xcodeprojKeyForProject:(Project*)project {
    if (_key == nil) {
        NSArray* xcodeprojKeys =
                [project keysForProjectObjectsOfType:PBXFileReference withIdentifier:[self pathRelativeToProjectRoot]
                        singleton:YES required:YES];
        _key = [xcodeprojKeys objectAtIndex:0];
    }
    return _key;
}

- (void) initFullProjectPath:(NSString*)fullProjectPath groupPath:(NSString*)groupPath {
    if (groupPath != nil) {
        NSMutableArray* fullPathComponents = [[fullProjectPath pathComponents] mutableCopy];
        [fullPathComponents removeLastObject];
        fullProjectPath = [[NSString pathWithComponents:fullPathComponents] stringByAppendingFormat:@"/%@", groupPath];
    }
    _fullProjectPath = fullProjectPath;

}

// compares the given path to the filePath of the project, and returns a relative version. _fullProjectPath, which has
// to hve been previously set, is the full path to the project *plus* the path to the xcodeproj's group, if any.
- (NSString*) pathRelativeToProjectRoot {
    if (_relativePath == nil) {
        if (_fullProjectPath == nil) {
            [NSException raise:NSInvalidArgumentException format:@"fullProjectPath has not been set"];
        }
        NSMutableArray* projectPathComponents = [[_fullProjectPath pathComponents] mutableCopy];
        NSArray* objectPathComponents = [[self xcodeprojFullPathName] pathComponents];
        NSString* convertedPath = [[NSString alloc] init];

        // skip over path components from root that are equal
        int limit = ([projectPathComponents count] < [objectPathComponents count]) ? [projectPathComponents count] :
                    [objectPathComponents count];
        int index1 = 0;
        for (; index1 < limit; index1++) {
            if ([[projectPathComponents objectAtIndex:index1]
                    isEqualToString:[objectPathComponents objectAtIndex:index1]]) {
                continue;
            }
            else {
                break;
            }
        }
        // insert "../" for each remaining path component in project's xcodeproj path
        for (int index2 = 0; index2 < ([projectPathComponents count] - index1); index2++) {
            convertedPath = [convertedPath stringByAppendingString:@"../"];
        }
        // tack on the unique part of the object's path
        for (int index3 = index1; index3 < [objectPathComponents count] - 1; index3++) {
            convertedPath = [convertedPath stringByAppendingFormat:@"%@/", [objectPathComponents objectAtIndex:index3]];
        }
        _relativePath = [[convertedPath stringByAppendingString:[objectPathComponents lastObject]] copy];
    }
    return _relativePath;
}


/* ================================================== Utility Methods =============================================== */
- (NSString*) description {
    return [NSString stringWithFormat:@"XcodeprojDefinition: sourceFileName = %@, path=%@, type=%@", _sourceFileName, _path, _type];
}

@end