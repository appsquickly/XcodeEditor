////////////////////////////////////////////////////////////////////////////////
//
//  EXPANZ
//  Copyright 2012 Zach Drayer
//  All Rights Reserved.
//
//  NOTICE: Zach Drayer permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "XCBuildConfigurationList.h"
#import "XCGroup.h"
#import "XCProject.h"
#import "XCSourceFile.h"
#import "Utils/XCMemoryUtils.h"

@implementation XCBuildConfigurationList
+ (NSDictionary *) buildConfigurationsFromDictionary:(NSDictionary *) dictionary inProject:(XCProject *) project {
	NSMutableDictionary *configurations = [NSMutableDictionary dictionary];

    for (NSString* buildConfigurationKey in dictionary) {
        NSDictionary* buildConfiguration = [[project objects] objectForKey:buildConfigurationKey];

        if ([[buildConfiguration valueForKey:@"isa"] asMemberType] == XCBuildConfiguration) {
			XCBuildConfigurationList *configuration = [configurations objectForKey:[buildConfiguration objectForKey:@"name"]];
			if (!configuration) {
				configuration =  [[XCBuildConfigurationList alloc] init];

				[configurations setObject:configuration forKey:[buildConfiguration objectForKey:@"name"]];
			}


			XCSourceFile *configurationFile = [project fileWithKey:[buildConfiguration objectForKey:@"baseConfigurationReference"]];
			if (configurationFile) {
				NSString *path = configurationFile.path;

				if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
					XCGroup *group = [project groupWithSourceFile:configurationFile];
					path = [[group pathRelativeToParent] stringByAppendingPathComponent:path];
				}

				if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
					path = [[[project filePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:path];
				}

				if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
					path = [[[project filePath] stringByDeletingLastPathComponent] stringByAppendingPathComponent:configurationFile.path];
				}

				if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
					[NSException raise:@"XCConfig not found" format:@"Unable to find XCConfig file at %@", path];
				}

				[configuration addXCConfigAtPath:path];
			}

			[configuration addBuildSettings:[buildConfiguration objectForKey:@"buildSettings"]];
        }
	}

	return configurations;
}

#pragma mark -

- (id) init {
    if (!(self = [super init]))
        return nil;

    _buildSettings = [[NSMutableDictionary alloc] init];
    _xcconfigSettings = [[NSMutableDictionary alloc] init];

    return self;
}

- (void) dealloc {
    XCRelease(_buildSettings)
	XCRelease(_xcconfigSettings)

	XCSuperDealloc
}

#pragma mark -

- (NSString *) description {
	NSMutableString *description = [[super description] mutableCopy];

	[description appendFormat:@"build settings: %@, inherited: %@", _buildSettings, _xcconfigSettings];

	return XCAutorelease(description);
}

#pragma mark -

- (NSDictionary *) specifiedBuildSettings {
	return XCAutorelease([_buildSettings copy])
}

#pragma mark -

- (void) addXCConfigAtPath:(NSString *) path {
	path = [[path stringByResolvingSymlinksInPath] stringByExpandingTildeInPath];

    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

        for (NSString *setting in [contents componentsSeparatedByString:@"\n"]) {
			// rudimentary #include support
			NSString *workingSetting = [setting stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            NSRange range = [workingSetting rangeOfString:@"#include" options:NSAnchoredSearch range:NSMakeRange(0, workingSetting.length)];

            if (range.location != NSNotFound) {
                workingSetting = [workingSetting substringFromIndex:@"#include \"".length];

                [self addXCConfigAtPath:[setting substringToIndex:(setting.length - 1)]];
            } else {
                NSArray *parts = [setting componentsSeparatedByString:@"="];
                if (parts.count == 2) {
					// XCConfig files can be used to unset properties, a la `FOO=`
					// so, we have to be able to insert blank (but non-nil) values into the dictionary
                    NSString *key = [[parts objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
					NSString *value = [[parts objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                    [_xcconfigSettings setObject:value forKey:key];
                }
            }
        }
    }
}

#pragma mark -

- (void) addBuildSettings:(NSDictionary *) buildSettings {
	[_xcconfigSettings removeObjectsForKeys:[buildSettings allKeys]];
    [_buildSettings addEntriesFromDictionary:buildSettings];
}

- (NSString *) valueForKey:(NSString *) key {
	NSString *value = [_buildSettings objectForKey:key];
	if (!value)
		value = [_xcconfigSettings objectForKey:key];
    return value;
}
@end
