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

#import "xcode_XcodeprojDefinition.h"


@implementation xcode_XcodeprojDefinition

@synthesize sourceFileName = _sourceFileName;
@synthesize path = _path;
@synthesize type = _type;
@synthesize subproject = _subproject;
@synthesize pathRelativeToProjectRoot = _pathRelativeToProjectRoot;
@synthesize key = _key;

/* ================================================= Class Methods ================================================== */
+ (xcode_XcodeprojDefinition*) sourceDefinitionWithName:(NSString*)name projPath:(NSString*)path type:(XcodeSourceFileType)type {
    
    return [[XcodeprojDefinition alloc] initWithName:name projPath:path type:type];
}

/* ================================================== Initializers ================================================== */

// Note - because _path is used to find the external project, it's often going to be an absoulute path name.
// We will need to convert it into a path relative to SRCROOT, but can't do that here as we don't have access
// to the project.  It has to be done at the time this object is added to the group, which is part of the
// project.
- (id) initWithName:(NSString*)name projPath:(NSString*)path type:(XcodeSourceFileType)type {
    self = [super init];
    if (self) {
        _sourceFileName = [name copy];
        _path = [path copy];
        _type = type;
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
- (NSArray *) buildProductNames {
    NSMutableArray* results = [NSMutableArray array];
    NSDictionary* objects = [_subproject objects];
    [objects enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXProject) {
            NSString *productRefGroupKey = [obj valueForKey:@"productRefGroup"];
            NSDictionary *products = [objects valueForKey:productRefGroupKey];
            NSArray *children = [products valueForKey:@"children"];
            for (NSString *childKey in children) {
                NSDictionary* child = [objects valueForKey:childKey];
                [results addObject:[child valueForKey:@"path"]];
            }
        }
    }];
    return results;
}

// returns the key of the PBXFileReference of the xcodeproj file
- (NSString*) xcodeprojKey:(Project *)project {
    if (_key == nil) {
        NSArray* xcodeprojKeys = [project keysForProjectObjectsOfType:PBXFileReference withIdentifier:[self pathRelativeToProjectRoot] singleton:YES];
        if ([xcodeprojKeys count] == 0) {
            [NSException raise:NSGenericException format:@"Did not find a PBXFileReference for name %@", [self pathRelativeToProjectRoot]];
        }
        _key = [xcodeprojKeys objectAtIndex:0];
    }
    return _key;
}

/* ================================================== Utility Methods =============================================== */
- (NSString*) description {
    return [NSString stringWithFormat:@"XcodeprojDefinition: sourceFileName = %@, path=%@, type=%@", _sourceFileName, _path, _type];
}

@end