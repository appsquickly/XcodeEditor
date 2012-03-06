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

#import "xcode_SourceFile.h"
#import "xcode_Project.h"
#import "xcode_KeyBuilder.h"
#import "xcode_Group.h"

@implementation xcode_SourceFile

@synthesize type = _type;
@synthesize name = _name;
@synthesize key = _key;

/* ================================================== Initializers ================================================== */
- (id) initWithProject:(xcode_Project*)project key:(NSString*)key type:(XcodeSourceFileType)type name:(NSString*)name {
    self = [super init];
    if (self) {
        _project = project;
        _key = [key copy];
        _type = type;
        _name = [name copy];
    }
    return self;
}

/* ================================================ Interface Methods =============================================== */

- (BOOL) isBuildFile {
    if ([self canBecomeBuildFile] && _isBuildFile == nil) {
        _isBuildFile = [NSNumber numberWithBool:NO];
        [[_project objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
            if ([[obj valueForKey:@"isa"] asMemberType] == PBXBuildFile) {
                if ([[obj valueForKey:@"fileRef"] isEqualToString:_key]) {
                    _isBuildFile = nil;
                    _isBuildFile = [NSNumber numberWithBool:YES];
                }
            }
        }];
    }
    LogDebug(@"Is build file: %@", [_isBuildFile boolValue] == YES? @"YES" : @"NO");
    return [_isBuildFile boolValue];
}

- (BOOL) canBecomeBuildFile {
    return _type == SourceCodeObjC || _type == SourceCodeObjCPlusPlus || _type == XibFile;
}


- (NSString*) buildFileKey {
    if (_buildFileKey == nil) {
        [[_project objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop) {
            if ([[obj valueForKey:@"isa"] asMemberType] == PBXBuildFile) {
                if ([[obj valueForKey:@"fileRef"] isEqualToString:_key]) {
                    _buildFileKey = key;
                }
            }
        }];
    }
    return _buildFileKey;

}


- (void) becomeBuildFile {
    if (![self isBuildFile]) {
        if ([self canBecomeBuildFile]) {
            NSMutableDictionary* sourceBuildFile = [[NSMutableDictionary alloc] init];
            [sourceBuildFile setObject:[NSString stringFromMemberType:PBXBuildFile] forKey:@"isa"];
            [sourceBuildFile setObject:_key forKey:@"fileRef"];
            NSString* buildFileKey = [[KeyBuilder forItemNamed:[_name stringByAppendingString:@".buildFile"]] build];
            LogDebug(@"Build file key: %@", buildFileKey);
            [[_project objects] setObject:sourceBuildFile forKey:buildFileKey];
            LogDebug(@"Done becoming build file.");
        }
        else if (_type == Framework) {
            [NSException raise:NSInvalidArgumentException format:@"Add framework to target not implemented yet."];
        }
        else {
            [NSException raise:NSInvalidArgumentException format:@"Project file of type %@ can't become a build file.",
                                                                 [NSString stringFromSourceFileType:_type]];
        }

    }
}

- (NSString*) sourcePath {
    return [[[_project groupForGroupMemberWithKey:_key] pathRelativeToProjectRoot]
            stringByAppendingPathComponent:_name];
}

/* ================================================= Protocol Methods =============================================== */
- (XcodeMemberType) groupMemberType {
    return PBXFileReference;
}

- (NSString*) displayName {
    return _name;
}


/* ================================================== Utility Methods =============================================== */
- (NSString*) description {
    return [NSString stringWithFormat:@"Project file: key=%@, name=%@, fullPath=%@", _key, _name, [self sourcePath]];
}


@end