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
#import <Foundation/Foundation.h>


@interface xcode_FileOperationQueue : NSObject {

@private
    NSString* _baseDirectory;
    NSMutableDictionary* _filesToWrite;
    NSMutableDictionary* _frameworksToCopy;
    NSMutableArray* _filesToDelete;
}


- (id) initWithBaseDirectory:(NSString*)baseDirectory;

- (void) queueWrite:(NSString*)fileName inDirectory:(NSString*)directory withContents:(NSString*)contents;

- (void) queueFrameworkWithFilePath:(NSString*)filePath inDirectory:(NSString*)directory;

- (void) queueDeletion:(NSString*)filePath;

- (void) commitFileOperations;

@end

/* ================================================================================================================== */
@compatibility_alias FileOperationQueue xcode_FileOperationQueue;