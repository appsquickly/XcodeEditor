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

#import "xcode_FileOperationQueue.h"

@interface xcode_FileOperationQueue ()

- (NSString*) destinationPathFor:(NSString*)fileName inProjectDirectory:(NSString*)directory;

- (void) performFileWrites;

- (void) performCopyFrameworks;

- (void) performFileDeletions;

@end


@implementation xcode_FileOperationQueue

/* ================================================== Initializers ================================================== */
- (id) initWithBaseDirectory:(NSString*)baseDirectory {
    self = [super init];
    if (self) {
        _filesToWrite = [[NSMutableDictionary alloc] init];
        _frameworksToCopy = [[NSMutableDictionary alloc] init];
        _filesToDelete = [[NSMutableArray alloc] init];
        _baseDirectory = [baseDirectory copy];
    }
    return self;
}

/* ================================================ Interface Methods =============================================== */
- (void) queueWrite:(NSString*)fileName inDirectory:(NSString*)directory withContents:(NSString*)contents {
    [_filesToWrite setObject:contents forKey:[self destinationPathFor:fileName inProjectDirectory:directory]];
}

- (void) queueFrameworkWithFilePath:(NSString*)filePath inDirectory:(NSString*)directory {
    NSURL* sourceUrl = [NSURL fileURLWithPath:filePath isDirectory:YES];
    NSURL* destinationUrl = [NSURL fileURLWithPath:[[_baseDirectory stringByAppendingPathComponent:directory]
                                                           stringByAppendingPathComponent:[filePath lastPathComponent]]
            isDirectory:YES];
    [_frameworksToCopy setObject:sourceUrl forKey:destinationUrl];
}

- (void) queueDeletion:(NSString*)filePath {
    LogDebug(@"Queing deletion for path: %@", filePath);
    [_filesToDelete addObject:filePath];
}


- (void) commitFileOperations {
    [self performFileWrites];
    [self performCopyFrameworks];
    [self performFileDeletions];
}


/* ================================================== Private Methods =============================================== */
- (NSString*) destinationPathFor:(NSString*)fileName inProjectDirectory:(NSString*)directory {
    return [[_baseDirectory stringByAppendingPathComponent:directory] stringByAppendingPathComponent:fileName];
}

- (void) performFileWrites {
    [_filesToWrite enumerateKeysAndObjectsUsingBlock:^(id filePath, id data, BOOL* stop) {
        NSError* error;
        [data writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            [NSException raise:NSInternalInconsistencyException format:@"Error writing file at filePath: %@", filePath];
        }
    }];
    [_filesToWrite removeAllObjects];
}

- (void) performCopyFrameworks {
    [_frameworksToCopy enumerateKeysAndObjectsUsingBlock:^(NSURL* destinationPath, NSURL* frameworkPath, BOOL* stop) {
        NSError* error;
        [[NSFileManager defaultManager] copyItemAtURL:frameworkPath toURL:destinationPath error:&error];

        if (error) {
            LogDebug(@"User info: %@", [error userInfo]);
            [NSException raise:NSInternalInconsistencyException format:@"Error writing file at filePath: %@",
                                                                       [frameworkPath absoluteString]];
        }
    }];
    [_frameworksToCopy removeAllObjects];
}

- (void) performFileDeletions {
    for (NSString* filePath in [_filesToDelete reverseObjectEnumerator]) {
        NSError* error;
        NSString* fullPath = [_baseDirectory stringByAppendingPathComponent:filePath];
        LogDebug(@"Full path to delete is: %@", fullPath);
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
        if (error) {
            LogDebug(@"User info: %@", [error userInfo]);
            [NSException raise:NSInternalInconsistencyException format:@"Error deleting file at filePath: %@",
                                                                       filePath];
        }
    }
    [_filesToDelete removeAllObjects];
}


@end