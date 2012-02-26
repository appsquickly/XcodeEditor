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
@interface xcode_File : NSObject {

@private
    __weak xcode_Project* _project;
    __strong NSString* _key;
}

@property(nonatomic, readonly) XcodeProjectFileType type;
@property(nonatomic, strong, readonly) NSString* name;

- (id) initWithProject:(xcode_Project*)project key:(NSString*)key type:(XcodeProjectFileType)type name:(NSString*)name;

/**
* If yes, indicates the file is able to be included for compilation in an `xcode_Target`.
*/
- (BOOL) isBuildFile;

- (NSString*) buildFileKey;

- (NSString*) fullPath;

/**
* Adds this file to the project as an `xcode_BuildFile`, ready to be included in targets.
*/
- (void) becomeBuildFile;

@end

/* ================================================================================================================== */
@compatibility_alias File xcode_File;