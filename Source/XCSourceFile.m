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
#import "XCProject.h"
#import "Utils/XCKeyBuilder.h"
#import "XCGroup.h"

@implementation XCSourceFile

@synthesize type = _type;
@synthesize key = _key;
@synthesize sourceTree = _sourceTree;

//-------------------------------------------------------------------------------------------
#pragma mark - Class Methods
//-------------------------------------------------------------------------------------------

+ (XCSourceFile *)sourceFileWithProject:(XCProject *)project key:(NSString *)key type:(XcodeSourceFileType)type
    name:(NSString *)name sourceTree:(NSString *)_tree path:(NSString *)path
{
    return [[XCSourceFile alloc] initWithProject:project key:key type:type name:name sourceTree:_tree path:path];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Initialization & Destruction
//-------------------------------------------------------------------------------------------

- (id)initWithProject:(XCProject *)project key:(NSString *)key type:(XcodeSourceFileType)type name:(NSString *)name
    sourceTree:(NSString *)tree path:(NSString *)path
{

    self = [super init];
    if (self) {
        _project = project;
        _key = [key copy];
        _type = type;
        _name = [name copy];
        _sourceTree = [tree copy];
        _path = [path copy];
    }
    return self;
}


//-------------------------------------------------------------------------------------------
#pragma mark - Interface Methods
//-------------------------------------------------------------------------------------------

// Goes to the entry for this object in the project and sets a value for one of the keys, such as name, path, etc.
- (void)setValue:(id)val forProjectItemPropertyWithKey:(NSString *)key
{
    NSMutableDictionary *obj = [[[_project objects] objectForKey:_key] mutableCopy];
    if (nil == obj) {
        [NSException raise:@"Project item not found" format:@"Project item with key %@ not found.", _key];
    }
    [obj setValue:val forKey:key];
    [[_project objects] setValue:obj forKey:_key];
}


- (NSString *)name
{
    return _name;
}

- (void)setName:(NSString *)name
{
    _name = [name copy];

    [self setValue:name forProjectItemPropertyWithKey:@"name"];
}


- (NSString *)path
{
    return _path;
}

- (void)setPath:(NSString *)path
{
    _path = [path copy];

    [self setValue:path forProjectItemPropertyWithKey:@"path"];
}

- (BOOL)isBuildFile
{
    if ([self canBecomeBuildFile] && _isBuildFile == nil) {
        _isBuildFile = @NO;
        [[_project objects] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
            if ([[obj valueForKey:@"isa"] xce_hasBuildFileType]) {
                if ([[obj valueForKey:@"fileRef"] isEqualToString:_key]) {
                    _isBuildFile = nil;

                    _isBuildFile = @YES;
                }
            }
        }];
    }
    return [_isBuildFile boolValue];
}

- (BOOL)canBecomeBuildFile
{
    return _type == SourceCodeObjC || _type == SourceCodeObjCPlusPlus || _type == SourceCodeCPlusPlus || _type == XibFile || _type == Framework || _type == ImageResourcePNG || _type == HTML || _type == Bundle || _type == Archive || _type == AssetCatalog || _type == SourceCodeSwift;
}


- (XcodeMemberType)buildPhase
{
    if (_type == SourceCodeObjC || _type == SourceCodeObjCPlusPlus || _type == SourceCodeCPlusPlus || _type == XibFile || _type == SourceCodeSwift) {
        return PBXSourcesBuildPhaseType;
    }
    else if (_type == Framework) {
        return PBXFrameworksBuildPhaseType;
    }
    else if (_type == ImageResourcePNG || _type == HTML || _type == Bundle || _type == AssetCatalog) {
        return PBXResourcesBuildPhaseType;
    }
    else if (_type == Archive) {
        return PBXFrameworksBuildPhaseType;
    }
    return PBXNilType;
}

- (NSString *)buildFileKey
{
    if (_buildFileKey == nil) {
        [[_project objects] enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
            if ([[obj valueForKey:@"isa"] xce_hasBuildFileType]) {
                if ([[obj valueForKey:@"fileRef"] isEqualToString:_key]) {
                    _buildFileKey = [key copy];
                }
            }
        }];
    }
    return [_buildFileKey copy];

}


- (void)becomeBuildFile
{
    if (![self isBuildFile]) {
        if ([self canBecomeBuildFile]) {
            NSMutableDictionary *sourceBuildFile = [NSMutableDictionary dictionary];
            sourceBuildFile[@"isa"] = [NSString xce_stringFromMemberType:PBXBuildFileType];
            sourceBuildFile[@"fileRef"] = _key;
            NSString *buildFileKey = [[XCKeyBuilder forItemNamed:[_name stringByAppendingString:@".buildFile"]] build];
            [_project objects][buildFileKey] = sourceBuildFile;
        }
        else if (_type == Framework) {
            [NSException raise:NSInvalidArgumentException format:@"Add framework to target not implemented yet."];
        }
        else {
            [NSException raise:NSInvalidArgumentException format:@"Project file of type %@ can't become a build file.",
                                                                 NSStringFromXCSourceFileType(_type)];
        }

    }
}

- (void)setCompilerFlags:(NSString *)value
{
    NSMutableDictionary *objectArrayCopy = [[_project objects] mutableCopy];
    [objectArrayCopy enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSDictionary *obj, BOOL *stop) {
        if ([[obj valueForKey:@"isa"] xce_hasBuildFileType]) {
            if ([obj[@"fileRef"] isEqualToString:self.key]) {
                NSMutableDictionary *replaceBuildFile = [NSMutableDictionary dictionaryWithDictionary:obj];
                NSDictionary *compilerFlagsDict = @{@"COMPILER_FLAGS" : value};
                if ([replaceBuildFile[@"settings"] objectForKey:@"COMPILER_FLAGS"] != nil) {
                    NSMutableDictionary *newSettings = [NSMutableDictionary dictionaryWithDictionary:replaceBuildFile[@"settings"]];
                    [newSettings removeObjectForKey:@"COMPILER_FLAGS"];
                    replaceBuildFile[@"settings"] = compilerFlagsDict;
                }
                else {
                    replaceBuildFile[@"settings"] = compilerFlagsDict;
                }
                [[_project objects] removeObjectForKey:key];
                [_project objects][key] = replaceBuildFile;
            }
        }
    }];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Protocol Methods

- (XcodeMemberType)groupMemberType
{
    return PBXFileReferenceType;
}

- (NSString *)displayName
{
    return _name;
}

- (NSString *)pathRelativeToProjectRoot
{
    NSString *parentPath = [[_project groupForGroupMemberWithKey:_key] pathRelativeToProjectRoot];
    NSString *result = [parentPath stringByAppendingPathComponent:_name];
    return result;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Utility Methods

- (NSString *)description
{
    return [NSString stringWithFormat:@"Project file: key=%@, name=%@, fullPath=%@", _key, _name,
                                      [self pathRelativeToProjectRoot]];
}


@end

