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
    [_frameworks setObject:filePath forKey:[_baseDirectory stringByAppendingPathComponent:directory]];
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

    [_frameworks enumerateKeysAndObjectsUsingBlock:^(id frameworkPath, id destinationPath, BOOL* stop) {
        NSError* error;

        if ([[NSFileManager defaultManager] isReadableFileAtPath:frameworkPath]) {
            [[NSFileManager defaultManager] copyItemAtURL:frameworkPath toURL:destinationPath error:&error];
        }
        else {
            [NSException raise:NSInternalInconsistencyException
                    format:@"The file at path %@ is not readable. Does the file exist?", frameworkPath];
        }

        if (error) {
            [NSException raise:NSInternalInconsistencyException format:@"Error writing file at filePath: %@",
                                                                       frameworkPath];
        }
    }];
    [_frameworks removeAllObjects];

}


/* ================================================== Private Methods =============================================== */
- (NSString*) destinationPathFor:(NSString*)fileName inProjectDirectory:(NSString*)directory {
    return [[_baseDirectory stringByAppendingPathComponent:directory] stringByAppendingPathComponent:fileName];
}


@end