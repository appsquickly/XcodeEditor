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
#import "XcodeProjectFileType.h"

@class xcode_Project;


/**
* Represents a file resource in an xcode project.
*/
@interface xcode_FileResource : NSObject {

@private
    __weak xcode_Project* _project;
    __strong NSString* _key;
}

@property(nonatomic, readonly) XcodeProjectFileType type;
@property(nonatomic, strong, readonly) NSString* path;

- (id) initWithProject:(xcode_Project*)project key:(NSString*)key type:(XcodeProjectFileType)type path:(NSString*)path;

/**
* If yes, indicates the file is able to be included for compilation in an `xcode_Target`.
*/
- (BOOL) isBuildFile;

- (NSString*) buildFileKey;

/**
* Adds this file to the project as an `xcode_BuildFile`, ready to be included in targets.
*/
- (void) becomeBuildFile;

@end

/* ================================================================================================================== */
@compatibility_alias FileResource xcode_FileResource;