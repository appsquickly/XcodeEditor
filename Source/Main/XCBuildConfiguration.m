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



#import "XCBuildConfiguration.h"
#import "XCGroup.h"
#import "XCProject.h"
#import "XCSourceFile.h"
#import "Utils/XCMemoryUtils.h"

@implementation XCBuildConfiguration
+ (NSDictionary*)buildConfigurationsFromArray:(NSArray*)array inProject:(XCProject*)project
{
    NSMutableDictionary* configurations = [NSMutableDictionary dictionary];

    for (NSString* buildConfigurationKey in array)
    {
        NSDictionary* buildConfiguration = [[project objects] objectForKey:buildConfigurationKey];

        if ([[buildConfiguration valueForKey:@"isa"] asMemberType] == XCBuildConfigurationType)
        {
            XCBuildConfiguration* configuration = [configurations objectForKey:[buildConfiguration objectForKey:@"name"]];
            if (!configuration)
            {
                configuration = [[XCBuildConfiguration alloc] init];

                [configurations setObject:configuration forKey:[buildConfiguration objectForKey:@"name"]];
            }


            XCSourceFile* configurationFile = [project fileWithKey:[buildConfiguration objectForKey:@"baseConfigurationReference"]];
            if (configurationFile)
            {
                NSString* path = configurationFile.path;

                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    XCGroup* group = [project groupWithSourceFile:configurationFile];
                    path = [[group pathRelativeToParent] stringByAppendingPathComponent:path];
                }

                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    path = [[[project filePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:path];
                }

                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    path = [[[project filePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:configurationFile.path];
                }

                if (![[NSFileManager defaultManager] fileExistsAtPath:path])
                {
                    [NSException raise:@"XCConfig not found" format:@"Unable to find XCConfig file at %@", path];
                }

            }

            [configuration addBuildSettings:[buildConfiguration objectForKey:@"buildSettings"]];
        }
    }

    return configurations;
}

#pragma mark -

- (id)init
{
    if (!(self = [super init]))
    {
            return nil;
    }

    _buildSettings = [[NSMutableDictionary alloc] init];
    _xcconfigSettings = [[NSMutableDictionary alloc] init];

    return self;
}

- (void)dealloc
{
    XCRelease(_buildSettings)
    XCRelease(_xcconfigSettings)

    XCSuperDealloc
}

#pragma mark -

- (NSString*)description
{
    NSMutableString* description = [[super description] mutableCopy];

    [description appendFormat:@"build settings: %@, inherited: %@", _buildSettings, _xcconfigSettings];

    return XCAutorelease(description);
}

#pragma mark -

- (NSDictionary*)specifiedBuildSettings
{
    return XCAutorelease([_buildSettings copy])}

#pragma mark -

- (void)addBuildSettings:(NSDictionary*)buildSettings
{
    [_xcconfigSettings removeObjectsForKeys:[buildSettings allKeys]];
    [_buildSettings addEntriesFromDictionary:buildSettings];
}

- (void)addOrReplaceBuildSetting:(id <NSCopying>)setting forKey:(NSString*)key
{
    [self addBuildSettings:[NSDictionary dictionaryWithObject:setting forKey:key]];
}


- (id<NSCopying>)valueForKey:(NSString*)key
{
    id<NSCopying> value = [_buildSettings objectForKey:key];
    if (!value)
    {
            value = [_xcconfigSettings objectForKey:key];
    }
    return value;
}
@end
