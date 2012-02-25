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

#import "xcode_FileResource.h"
#import "xcode_Project.h"
#import "XcodeProjectNodeType.h"
#import "xcode_KeyBuilder.h"

@implementation xcode_FileResource

@synthesize type = _type;
@synthesize path = _path;


/* ================================================== Initializers ================================================== */
- (id) initWithProject:(xcode_Project*)project key:(NSString*)key type:(XcodeProjectFileType)type path:(NSString*)path {
    self = [super init];
    if (self) {
        _project = project;
        _key = [key copy];
        _type = type;
        _path = [path copy];
    }
    return self;
}

/* ================================================ Interface Methods =============================================== */


- (BOOL) isBuildFile {
    __block BOOL isBuildFile = NO;
    if (_type == SourceCodeObjC) {
        [[_project objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
            if ([[obj valueForKey:@"isa"] asProjectNodeType] == PBXBuildFile) {
                if ([[obj valueForKey:@"fileRef"] isEqualToString:_key]) {
                    isBuildFile = YES;
                }
            }
        }];
    }
    return isBuildFile;
}

- (NSString*) buildFileKey {
    __block NSString* buildFileKey;
    if (_type == SourceCodeObjC) {
        [[_project objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
            if ([[obj valueForKey:@"isa"] asProjectNodeType] == PBXBuildFile) {
                if ([[obj valueForKey:@"fileRef"] isEqualToString:_key]) {
                    buildFileKey = key;
                }
            }
        }];
    }
    return buildFileKey;

}


- (void) becomeBuildFile {
    if (![self isBuildFile]) {
        if (_type == SourceCodeObjC) {
            NSMutableDictionary* sourceBuildFile = [[NSMutableDictionary alloc] init];
            [sourceBuildFile setObject:[NSString stringFromProjectNodeType:PBXBuildFile] forKey:@"isa"];
            [sourceBuildFile setObject:_key forKey:@"fileRef"];
            NSString* buildFileKey = [[KeyBuilder forItemNamed:[_path stringByAppendingString:@".buildFile"]] build];
            [[_project objects] setObject:sourceBuildFile forKey:buildFileKey];
        }
        else if (_type == Framework) {
            [NSException raise:NSInvalidArgumentException format:@"Add framework to target not implemented yet."];
        }
        else {
            [NSException raise:NSInvalidArgumentException format:@"Project file of type %@ can't become a build file.",
                                                                 [NSString stringFromProjectFileType:_type]];
        }

    }
}


/* ================================================== Utility Methods =============================================== */
- (NSString*) description {
    return [NSString stringWithFormat:@"Project file: key=%@, path=%@", _key, _path];
}


@end