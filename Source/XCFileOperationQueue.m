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



#import "XCFileOperationQueue.h"

@interface XCFileOperationQueue ()

- (NSString*)destinationPathFor:(NSString*)fileName inProjectDirectory:(NSString*)directory;

- (void)performFileWrites;

- (void)performCopyFrameworks;

- (void)performFileDeletions;

- (void)performCreateDirectories;

@end


@implementation XCFileOperationQueue

/* ====================================================================================================================================== */
#pragma mark - Initialization & Destruction

- (id)initWithBaseDirectory:(NSString*)baseDirectory
{
    self = [super init];
    if (self)
    {
        _baseDirectory = [baseDirectory copy];
        _filesToWrite = [[NSMutableDictionary alloc] init];
        _frameworksToCopy = [[NSMutableDictionary alloc] init];
        _filesToDelete = [[NSMutableArray alloc] init];
        _directoriesToCreate = [[NSMutableArray alloc] init];
    }
    return self;
}

/* ====================================================================================================================================== */
#pragma mark - Interface Methods

- (BOOL)fileWithName:(NSString*)name existsInProjectDirectory:(NSString*)directory
{
    NSString* filePath = [self destinationPathFor:name inProjectDirectory:directory];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}


- (void)queueTextFile:(NSString*)fileName inDirectory:(NSString*)directory withContents:(NSString*)contents
{
    [_filesToWrite setObject:[contents dataUsingEncoding:NSUTF8StringEncoding]
        forKey:[self destinationPathFor:fileName inProjectDirectory:directory]];
}

- (void)queueDataFile:(NSString*)fileName inDirectory:(NSString*)directory withContents:(NSData*)contents
{
    [_filesToWrite setObject:contents forKey:[self destinationPathFor:fileName inProjectDirectory:directory]];
}


- (void)queueFrameworkWithFilePath:(NSString*)filePath inDirectory:(NSString*)directory
{

    NSURL* sourceUrl = [NSURL fileURLWithPath:filePath isDirectory:YES];
    NSString* destinationPath =
        [[_baseDirectory stringByAppendingPathComponent:directory] stringByAppendingPathComponent:[filePath lastPathComponent]];
    NSURL* destinationUrl = [NSURL fileURLWithPath:destinationPath isDirectory:YES];
    [_frameworksToCopy setObject:sourceUrl forKey:destinationUrl];
}

- (void)queueDeletion:(NSString*)filePath
{
    if ( DEBUG ) printf("Queue deletion at: %s\n", filePath.UTF8String);
    [_filesToDelete addObject:filePath];
}

- (void)queueDirectory:(NSString*)withName inDirectory:(NSString*)parentDirectory
{
    [_directoriesToCreate addObject:[self destinationPathFor:withName inProjectDirectory:parentDirectory]];
}

- (void)commitFileOperations
{
    [self performFileWrites];
    [self performCopyFrameworks];
    [self performFileDeletions];
    [self performCreateDirectories];
}


/* ====================================================================================================================================== */
#pragma mark - Private Methods

- (NSString*)destinationPathFor:(NSString*)fileName inProjectDirectory:(NSString*)directory
{
    return [[_baseDirectory stringByAppendingPathComponent:directory] stringByAppendingPathComponent:fileName];
}

- (void)performFileWrites
{
    [_filesToWrite enumerateKeysAndObjectsUsingBlock:^(NSString* filePath, NSData* data, BOOL* stop)
    {
        NSError* error = nil;
        if (![data writeToFile:filePath options:NSDataWritingAtomic error:&error])
        {
            [NSException raise:NSInternalInconsistencyException format:@"Error writing file at filePath: %@, error: %@", filePath, error];
        }
    }];
    [_filesToWrite removeAllObjects];
}

- (void)performCopyFrameworks
{
    [_frameworksToCopy enumerateKeysAndObjectsUsingBlock:^(NSURL* destinationUrl, NSURL* frameworkPath, BOOL* stop)
    {

        if ( DEBUG ) printf("$$$$$$$$$$$$$$ destination url: %s\n", destinationUrl.fileSystemRepresentation);
        NSFileManager* fileManager = [NSFileManager defaultManager];

        if ([fileManager fileExistsAtPath:[destinationUrl path]])
        {
            [fileManager removeItemAtURL:destinationUrl error:nil];
        }
        NSError* error = nil;
        if (![fileManager copyItemAtURL:frameworkPath toURL:destinationUrl error:&error])
        {
            [NSException raise:NSInternalInconsistencyException format:@"%@", error.localizedDescription];
        }
    }];
    [_frameworksToCopy removeAllObjects];
}

- (void)performFileDeletions
{
    for (NSString* filePath in [_filesToDelete reverseObjectEnumerator])
    {
        NSString* fullPath = [_baseDirectory stringByAppendingPathComponent:filePath];
        NSError* error = nil;

        if (![[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error])
        {
            if ( DEBUG ) fprintf(stderr, "failed to remove item at path; error == %s\n", error.description.UTF8String);
            [NSException raise:NSInternalInconsistencyException format:@"Error deleting file at filePath: %@", filePath];
        }
        else
        {
            if ( DEBUG ) printf("Deleted: %s\n", fullPath.UTF8String);
        }
    }
    [_filesToDelete removeAllObjects];
}

- (void)performCreateDirectories
{
    for (NSString* filePath in _directoriesToCreate)
    {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:filePath])
        {
            if (![fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil])
            {
                [NSException raise:NSInvalidArgumentException format:@"Error: Create folder failed %@", filePath];
            }
        }
    }
}


@end
