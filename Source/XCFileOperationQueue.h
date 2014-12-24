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


#import <Foundation/Foundation.h>


@interface XCFileOperationQueue : NSObject
{

@private
    NSString* _baseDirectory;
    NSMutableDictionary* _filesToWrite;
    NSMutableDictionary* _frameworksToCopy;
    NSMutableArray* _filesToDelete;
    NSMutableArray* _directoriesToCreate;
}


- (id)initWithBaseDirectory:(NSString*)baseDirectory;

- (BOOL)fileWithName:(NSString*)name existsInProjectDirectory:(NSString*)directory;

- (void)queueTextFile:(NSString*)fileName inDirectory:(NSString*)directory withContents:(NSString*)contents;

- (void)queueDataFile:(NSString*)fileName inDirectory:(NSString*)directory withContents:(NSData*)contents;

- (void)queueFrameworkWithFilePath:(NSString*)filePath inDirectory:(NSString*)directory;

- (void)queueDeletion:(NSString*)filePath;

- (void)queueDirectory:(NSString*)withName inDirectory:(NSString*)parentDirectory;

- (void)commitFileOperations;

@end

