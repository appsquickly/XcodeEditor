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

#import "xcode_FileWriteQueue.h"

@interface xcode_FileWriteQueue (private)

- (NSString*) destinationPathFor:(NSString*)fileName inProjectDirectory:(NSString*)directory;

@end


@implementation xcode_FileWriteQueue

/* ================================================== Initializers ================================================== */
- (id) initWithBaseDirectory:(NSString*)baseDirectory {
    self = [super init];
    if (self) {
        _data = [[NSMutableDictionary alloc] init];
        _frameworks = [[NSMutableDictionary alloc] init];
        _baseDirectory = [baseDirectory copy];
    }
    return self;
}

/* ================================================ Interface Methods =============================================== */
- (void) queueFile:(NSString*)fileName inDirectory:(NSString*)directory withContents:(NSString*)contents {
    [_data setObject:contents forKey:[self destinationPathFor:fileName inProjectDirectory:directory]];
}

- (void) queueFrameworkWithFilePath:(NSString*)filePath inDirectory:(NSString*)directory {
    NSURL* sourceUrl = [NSURL fileURLWithPath:filePath isDirectory:YES];
    NSURL* destinationUrl = [NSURL fileURLWithPath:[[_baseDirectory stringByAppendingPathComponent:directory]
                                                           stringByAppendingPathComponent:[filePath lastPathComponent]]
            isDirectory:YES];
    [_frameworks setObject:sourceUrl forKey:destinationUrl];
}


- (void) writePendingFilesToDisk {
    [_data enumerateKeysAndObjectsUsingBlock:^(id filePath, id data, BOOL* stop) {
        NSError* error;
        [data writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            [NSException raise:NSInternalInconsistencyException format:@"Error writing file at filePath: %@", filePath];
        }
    }];
    [_data removeAllObjects];

    [_frameworks enumerateKeysAndObjectsUsingBlock:^(NSURL* destinationPath, NSURL* frameworkPath, BOOL* stop) {
        NSError* error;

        LogDebug(@"Source path: %@, destination path: %@", [frameworkPath absoluteString], [destinationPath
                absoluteString]);

        LogDebug(@"#########################");
        [[NSFileManager defaultManager] copyItemAtURL:frameworkPath toURL:destinationPath error:&error];


        if (error) {
            LogDebug(@"User info: %@", [error userInfo]);
            [NSException raise:NSInternalInconsistencyException format:@"Error writing file at filePath: %@",
                                                                       [frameworkPath absoluteString]];
        }
    }];
    [_frameworks removeAllObjects];

}


/* ================================================== Private Methods =============================================== */
- (NSString*) destinationPathFor:(NSString*)fileName inProjectDirectory:(NSString*)directory {
    return [[_baseDirectory stringByAppendingPathComponent:directory] stringByAppendingPathComponent:fileName];
}


@end