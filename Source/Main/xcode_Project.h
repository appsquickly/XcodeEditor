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

- (id) initWithString:(NSString*)string;

/**
* Raw project data.
*/
- (NSMutableDictionary*) objects;

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

/**
* Lists the groups in an xcode project, returning an array of `xcode_Group` objects.
*/
- (NSArray*) groups;

/**
* Lists the targets in an xcode project, returning an array of `xcode_Target` objects.
*/
- (NSArray*) targets;

/**
* Returns the target with the specified name, or nil. 
*/
- (xcode_Target*) targetWithName:(NSString*)name;

/**
* Returns the group with the specified path.
*/
- (xcode_Group*) groupWithPath:(NSString*)path;

/**
* Returns the group for the file with the given key;
*/
- (xcode_Group*) groupForFileWithKey:(NSString*)key;

/**
* Saves a project after editing.
*/
- (void) save;

@end

/* ================================================================================================================== */
@compatibility_alias Project xcode_Project;