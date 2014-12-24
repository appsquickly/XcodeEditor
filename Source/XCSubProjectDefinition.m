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



#import "XCProject.h"
#import "XCProject+SubProject.h"
#import "XCSubProjectDefinition.h"

@interface XCSubProjectDefinition ()
@property(nonatomic, strong, readwrite) NSString* relativePath;
@end

@implementation XCSubProjectDefinition

@synthesize name = _name;
@synthesize path = _path;
@synthesize type = _type;
@synthesize parentProject = _parentProject;
@synthesize subProject = _subProject;
@synthesize relativePath = _relativePath;
@synthesize key = _key;
@synthesize fullProjectPath = _fullProjectPath;

/* ====================================================================================================================================== */
#pragma mark - Class Methods

+ (XCSubProjectDefinition*)withName:(NSString*)name path:(NSString*)path parentProject:(XCProject*)parentProject
{

    return [[XCSubProjectDefinition alloc] initWithName:name path:path parentProject:parentProject];
}

/* ====================================================================================================================================== */
#pragma mark - Initialization & Destruction

// Note - _path is most often going to be an absolute path.  The method pathRelativeToProjectRoot below should be
// used to get the form that's stored in the main project file.
- (id)initWithName:(NSString*)name path:(NSString*)path parentProject:(XCProject*)parentProject
{
    self = [super init];
    if (self)
    {
        _name = [name copy];
        _path = [path copy];
        _type = XcodeProject;
        _parentProject = parentProject;
        _subProject = [[XCProject alloc] initWithFilePath:[NSString stringWithFormat:@"%@/%@.xcodeproj", path, name]];
    }
    return self;
}

/* ====================================================================================================================================== */
#pragma mark - Interface Methods

- (NSString*)projectFileName
{
    return [_name stringByAppendingString:@".xcodeproj"];
}

- (NSString*)fullPathName
{
    return [NSString stringWithFormat:@"%@/%@", _path, [_name stringByAppendingString:@".xcodeproj"]];
}

// returns an array of names of the build products of this project
- (NSArray*)buildProductNames
{
    NSMutableArray* results = [NSMutableArray array];
    NSDictionary* objects = [_subProject objects];
    [objects enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSDictionary* obj, BOOL* stop)
    {
        if ([[obj valueForKey:@"isa"] asMemberType] == PBXProjectType)
        {
            NSString* productRefGroupKey = [obj valueForKey:@"productRefGroup"];
            NSDictionary* products = [objects valueForKey:productRefGroupKey];
            NSArray* children = [products valueForKey:@"children"];
            for (NSString* childKey in children)
            {
                NSDictionary* child = [objects valueForKey:childKey];
                [results addObject:[child valueForKey:@"path"]];
            }
        }
    }];
    return results;
}

// returns the key of the PBXFileReference of the xcodeproj file
- (NSString*)projectKey
{
    if (_key == nil)
    {
        NSArray* xcodeprojKeys =
            [_parentProject keysForProjectObjectsOfType:PBXFileReferenceType withIdentifier:[self pathRelativeToProjectRoot] singleton:YES
                required:YES];
        _key = [[xcodeprojKeys objectAtIndex:0] copy];
    }
    return [_key copy];
}

- (void)initFullProjectPath:(NSString*)fullProjectPath groupPath:(NSString*)groupPath
{
    if (groupPath != nil)
    {
        NSMutableArray* fullPathComponents = [[fullProjectPath pathComponents] mutableCopy];
        [fullPathComponents removeLastObject];
        fullProjectPath = [[NSString pathWithComponents:fullPathComponents] stringByAppendingFormat:@"/%@", groupPath];
    }
    _fullProjectPath = [fullProjectPath copy];

}

// compares the given path to the filePath of the project, and returns a relative version. _fullProjectPath, which has
// to hve been previously set, is the full path to the project *plus* the path to the xcodeproj's group, if any.
- (NSString*)pathRelativeToProjectRoot
{
    if (_relativePath == nil)
    {
        if (_fullProjectPath == nil)
        {
            [NSException raise:NSInvalidArgumentException format:@"fullProjectPath has not been set"];
        }
        NSMutableArray* projectPathComponents = [[_fullProjectPath pathComponents] mutableCopy];
        NSArray* objectPathComponents = [[self fullPathName] pathComponents];
        NSString* convertedPath = @"";

        // skip over path components from root that are equal
        NSInteger limit =
            ([projectPathComponents count] < [objectPathComponents count]) ? [projectPathComponents count] : [objectPathComponents count];
        NSInteger index1 = 0;
        for (; index1 < limit; index1++)
        {
            if ([[projectPathComponents objectAtIndex:index1] isEqualToString:[objectPathComponents objectAtIndex:index1]])
            {
                continue;
            }
            else
            {
                break;
            }
        }
        // insert "../" for each remaining path component in project's xcodeproj path
        for (NSInteger index2 = 0; index2 < ([projectPathComponents count] - index1); index2++)
        {
            convertedPath = [convertedPath stringByAppendingString:@"../"];
        }
        // tack on the unique part of the object's path
        for (NSInteger index3 = index1; index3 < [objectPathComponents count] - 1; index3++)
        {
            convertedPath = [convertedPath stringByAppendingFormat:@"%@/", [objectPathComponents objectAtIndex:index3]];
        }
        _relativePath = [[convertedPath stringByAppendingString:[objectPathComponents lastObject]] copy];
    }
    return [_relativePath copy];
}


/* ====================================================================================================================================== */
#pragma mark - Utility Methods

- (NSString*)description
{
    return [NSString stringWithFormat:@"XcodeprojDefinition: sourceFileName = %@, path=%@, type=%d", _name, _path, _type];
}

@end