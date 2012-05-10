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
#import "xcode_utils_KeyBuilder.h"
#import "xcode_Group.h"

@implementation xcode_SourceFile

@synthesize type = _type;
@synthesize key = _key;
@synthesize name = _name;
@synthesize sourceTree = _sourceTree;

/* ================================================= Class Methods ================================================== */
+ (xcode_SourceFile*) sourceFileWithProject:(xcode_Project*)project key:(NSString*)key type:(XcodeSourceFileType)type
        name:(NSString*)name sourceTree:(NSString*)_tree {
    return [[SourceFile alloc] initWithProject:project key:key type:type name:name sourceTree:_tree];
}


/* ================================================== Initializers ================================================== */
- (id) initWithProject:(xcode_Project*)project
        key:(NSString*)key
        type:(XcodeSourceFileType)type
        name:(NSString*)name
        sourceTree:(NSString*)tree {

    self = [super init];
    if (self) {
        _project = project;
        _key = [key copy];
        _type = type;
        _name = [name copy];
        _sourceTree = [tree copy];
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
    return [_isBuildFile boolValue];
}

- (BOOL) canBecomeBuildFile {
    return _type == SourceCodeObjC || _type == SourceCodeObjCPlusPlus || _type == XibFile || _type == Framework || _type == ImageResourcePNG || _type == HTML || _type == Bundle || _type == Archive;
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
    LogDebug(@"$$$$$$$$$$$$$$$$$ Start becoming build file");
    if (![self isBuildFile]) {
        if ([self canBecomeBuildFile]) {
            NSMutableDictionary* sourceBuildFile = [NSMutableDictionary dictionary];
            [sourceBuildFile setObject:[NSString stringFromMemberType:PBXBuildFile] forKey:@"isa"];
            [sourceBuildFile setObject:_key forKey:@"fileRef"];
            NSString* buildFileKey = [[KeyBuilder forItemNamed:[_name stringByAppendingString:@".buildFile"]] build];
            [[_project objects] setObject:sourceBuildFile forKey:buildFileKey];
        }
        else if (_type == Framework) {
            [NSException raise:NSInvalidArgumentException format:@"Add framework to target not implemented yet."];
        }
        else {
            [NSException raise:NSInvalidArgumentException format:@"Project file of type %@ can't become a build file.",
                                                                 [NSString stringFromSourceFileType:_type]];
        }

    }LogDebug(@"Done becoming build file");
}

/* ================================================= Protocol Methods =============================================== */
- (XcodeMemberType) groupMemberType {
    return PBXFileReference;
}

- (NSString*) displayName {
    return _name;
}

- (NSString*) pathRelativeToProjectRoot {
    if ([self.sourceTree isEqualToString:@"SOURCE_ROOT"]) {
        return _name;
    }
    else {
        NSString* parentPath = [[_project groupForGroupMemberWithKey:_key] pathRelativeToProjectRoot];
        NSString* result = [parentPath stringByAppendingPathComponent:_name];
        LogDebug(@"%@ -> %@ -> %@", _name, parentPath, result);
        return result;
    }
}

/* ================================================== Utility Methods =============================================== */
- (NSString*) description {
    return [NSString stringWithFormat:@"Project file: key=%@, name=%@, fullPath=%@", _key, _name,
                                      [self pathRelativeToProjectRoot]];
}



@end