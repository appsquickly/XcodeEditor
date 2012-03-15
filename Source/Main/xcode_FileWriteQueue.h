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


@interface xcode_FileWriteQueue : NSObject {

@private
    NSString* _baseDirectory;
    NSMutableDictionary* _data;
    NSMutableDictionary* _frameworks;
}


- (id) initWithBaseDirectory:(NSString*)baseDirectory;

- (void) queueFile:(NSString*)fileName inDirectory:(NSString*)directory withContents:(NSString*)contents;

- (void) queueFrameworkWithFilePath:(NSString*)filePath inDirectory:(NSString*)directory;

- (void) writePendingFilesToDisk;

@end

/* ================================================================================================================== */
@compatibility_alias FileWriteQueue xcode_FileWriteQueue;