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

/* ================================================= Class Methods ================================================== */
+ (xcode_XcodeprojDefinition*) sourceDefinitionWithName:(NSString*)name projPath:(NSString*)path type:(XcodeSourceFileType)type {
    
    return [[XcodeprojDefinition alloc] initWithName:name projPath:path type:type];
}

/* ================================================== Initializers ================================================== */

// TODO path is fully qualified;  want _path to be relative to SRCROOT
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
- (NSArray *) buildProducts {
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

@end