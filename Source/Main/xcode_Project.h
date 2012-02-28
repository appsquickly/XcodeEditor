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
#import "XcodeProjectNodeType.h"

@class xcode_ClassDefinition;
@class xcode_Group;
@class xcode_FileWriteQueue;
@class xcode_File;
@class xcode_Target;


@interface xcode_Project : NSObject {

@private
    NSString* _filePath;
    NSMutableDictionary* _project;
}

@property(nonatomic, strong, readonly) xcode_FileWriteQueue* fileWriteQueue;

/**
* Creates a new project editor instance with the specified project.pbxproj file.
*/
- (id) initWithFilePath:(NSString*)filePath;

/**
* Raw project data.
*/
- (NSMutableDictionary*) objects;

#pragma mark Files
/**
* Returns all file resources in the project, as an array of `xcode_ProjectFile` objects.
*/
- (NSArray*) files;

/**
* Returns the project file with the specified key, or nil.
*/
- (xcode_File*) fileWithKey:(NSString*)key;

/**
* Returns the project file with the specified name, or nil.
*/
- (xcode_File*) fileWithName:(NSString*)name;

/**
* Returns all header files in the project, as an array of `xcode_ProjectFile` objects.
*/
- (NSArray*) headerFiles;

/**
* Returns all implementation (source) files in the project, as an array of `xcode_ProjectFile` objects.
*/
- (NSArray*) implementationFiles;

#pragma mark Groups
/**
* Lists the groups in an xcode project, returning an array of `xcode_Group` objects.
*/
- (NSArray*) groups;

/**
* Returns the group with the given key, or nil.
*/
- (xcode_Group*) groupWithKey:(NSString*)key;

/**
* Returns the group with the specified path - the directory relative to the group's parent. Eg Source/Main
*/
- (xcode_Group*) groupWithPathRelativeToParent:(NSString*)path;

/**
* Returns the parent group for the group or file with the given key;
*/
- (xcode_Group*) groupForGroupMemberWithKey:(NSString*)key;


#pragma mark Targets
/**
* Lists the targets in an xcode project, returning an array of `xcode_Target` objects.
*/
- (NSArray*) targets;

/**
* Returns the target with the specified name, or nil. 
*/
- (xcode_Target*) targetWithName:(NSString*)name;

#pragma mark Saving
/**
* Saves a project after editing.
*/
- (void) save;

@end

/* ================================================================================================================== */
@compatibility_alias Project xcode_Project;