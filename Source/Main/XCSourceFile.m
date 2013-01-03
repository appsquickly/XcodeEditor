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
#import "Utils/XCMemoryUtils.h"
#import "XCGroup.h"

@implementation XCSourceFile

@synthesize type = _type;
@synthesize key = _key;
@synthesize name = _name;
@synthesize sourceTree = _sourceTree;
@synthesize path = _path;

/* =========================================================== Class Methods ============================================================ */
+ (XCSourceFile*)sourceFileWithProject:(XCProject*)project key:(NSString*)key type:(XcodeSourceFileType)type
                                  name:(NSString*)name sourceTree:(NSString*)_tree path:(NSString*)path
{
    return XCAutorelease([[XCSourceFile alloc] initWithProject:project key:key type:type name:name sourceTree:_tree path:path])}


/* ============================================================ Initializers ============================================================ */
- (id)initWithProject:(XCProject*)project
                  key:(NSString*)key
                 type:(XcodeSourceFileType)type
                 name:(NSString*)name
           sourceTree:(NSString*)tree
                 path:(NSString*)path
{

    self = [super init];
    if (self)
    {
        _project = XCRetain(project)_key = [key copy];
        _type = type;
        _name = [name copy];
        _sourceTree = [tree copy];
        _path = [path copy];
    }
    return self;
}

/* ====================================================================================================================================== */
- (void)dealloc
{
    XCRelease(_project)
    XCRelease(_key)
    XCRelease(_name)
    XCRelease(_sourceTree)
    XCRelease(_path)
    XCRelease(_buildFileKey)
    XCRelease(_isBuildFile)

    XCSuperDealloc
}

/* ========================================================== Interface Methods ========================================================= */

- (BOOL)isBuildFile
{
    if ([self canBecomeBuildFile] && _isBuildFile == nil)
    {
        id old = _isBuildFile;
        _isBuildFile = [[NSNumber numberWithBool:NO] copy];
        [[_project objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop)
        {
            if ([[obj valueForKey:@"isa"] asMemberType] == PBXBuildFileType)
            {
                if ([[obj valueForKey:@"fileRef"] isEqualToString:_key])
                {
                    XCRelease(_isBuildFile)
                    _isBuildFile = nil;

                    _isBuildFile = [[NSNumber numberWithBool:YES] copy];
                }
            }
        }];
        XCRelease(old)
    }
    return [_isBuildFile boolValue];
}

- (BOOL)canBecomeBuildFile
{
    return _type == SourceCodeObjC || _type == SourceCodeObjCPlusPlus || _type == SourceCodeCPlusPlus || _type == XibFile || _type ==
            Framework || _type == ImageResourcePNG || _type == HTML || _type == Bundle || _type == Archive;
}


- (XcodeMemberType)buildPhase
{
    if (_type == SourceCodeObjC || _type == SourceCodeObjCPlusPlus || _type == SourceCodeCPlusPlus || _type == XibFile)
    {
        return PBXSourcesBuildPhaseType;
    }
    else if (_type == Framework)
    {
        return PBXFrameworksBuildPhaseType;
    }
    else if (_type == ImageResourcePNG || _type == HTML || _type == Bundle)
    {
        return PBXResourcesBuildPhaseType;
    }
    else if (_type == Archive)
    {
        return PBXFrameworksBuildPhaseType;
    }
    return PBXNilType;
}

- (NSString*)buildFileKey
{
    if (_buildFileKey == nil)
    {
        [[_project objects] enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop)
        {
            if ([[obj valueForKey:@"isa"] asMemberType] == PBXBuildFileType)
            {
                if ([[obj valueForKey:@"fileRef"] isEqualToString:_key])
                {
                    _buildFileKey = [key copy];
                }
            }
        }];
    }
    return XCAutorelease([_buildFileKey copy])

}


- (void)becomeBuildFile
{
    if (![self isBuildFile])
    {
        if ([self canBecomeBuildFile])
        {
            NSMutableDictionary* sourceBuildFile = [NSMutableDictionary dictionary];
            [sourceBuildFile setObject:[NSString stringFromMemberType:PBXBuildFileType] forKey:@"isa"];
            [sourceBuildFile setObject:_key forKey:@"fileRef"];
            NSString* buildFileKey = [[XCKeyBuilder forItemNamed:[_name stringByAppendingString:@".buildFile"]] build];
            [[_project objects] setObject:sourceBuildFile forKey:buildFileKey];
        }
        else if (_type == Framework)
        {
            [NSException raise:NSInvalidArgumentException format:@"Add framework to target not implemented yet."];
        }
        else
        {
            [NSException raise:NSInvalidArgumentException format:@"Project file of type %@ can't become a build file.",
                                                                 [NSString stringFromSourceFileType:_type]];
        }

    }
}

/* =========================================================== Protocol Methods ========================================================= */
- (XcodeMemberType)groupMemberType
{
    return PBXFileReferenceType;
}

- (NSString*)displayName
{
    return _name;
}

- (NSString*)pathRelativeToProjectRoot
{
    NSString* parentPath = [[_project groupForGroupMemberWithKey:_key] pathRelativeToProjectRoot];
    NSString* result = [parentPath stringByAppendingPathComponent:_name];
    return result;
}

/* ============================================================ Utility Methods ========================================================= */
- (NSString*)description
{
    return [NSString stringWithFormat:@"Project file: key=%@, name=%@, fullPath=%@", _key, _name, [self pathRelativeToProjectRoot]];
}


@end