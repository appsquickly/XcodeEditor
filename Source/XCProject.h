////////////////////////////////////////////////////////////////////////////////
//
//  JASPER BLUES
//  Copyright 2012 - 2013 Jasper Blues
//  All Rights Reserved.
//
//  NOTICE: Jasper Blues permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import "XcodeMemberType.h"
#import "XcodeSourceFileType.h"

@class XCClassDefinition;
@class XCGroup;
@class XCFileOperationQueue;
@class XCSourceFile;
@class XCTarget;
@class XCSubProjectDefinition;
@class XCProjectBuildConfig;

@interface XCProject : NSObject
{
@protected
    XCFileOperationQueue* _fileOperationQueue;

    NSString* _filePath;
    NSMutableDictionary* _dataStore;
    NSMutableArray* _targets;

    NSMutableDictionary* _groups;
    NSMutableDictionary* _configurations;

    NSString* _defaultConfigurationName;
    NSString* _rootObjectKey;
}

@property(nonatomic, strong, readonly) XCFileOperationQueue* fileOperationQueue;

//-------------------------------------------------------------------------------------------
#pragma mark - Initialization & Destruction
//-------------------------------------------------------------------------------------------


+ (XCProject*)projectWithFilePath:(NSString*)filePath;

/**
* Creates a new project editor instance with the specified Project.xcodeproj file.
*/
- (id)initWithFilePath:(NSString*)filePath;

//-------------------------------------------------------------------------------------------
#pragma mark Files
/**
* Returns all file resources in the project, as an array of `XCSourceFile` objects.
*/
- (NSArray<XCSourceFile*>*)files;

/**
* Returns the project file with the specified key, or nil.
*/
- (XCSourceFile*)fileWithKey:(NSString*)key;

/**
* Returns the project file with the specified name, or nil. If more than one project file matches the specified name,
* which one is returned is undefined.
*/
- (XCSourceFile*)fileWithName:(NSString*)name;

/**
* Returns all header files in the project, as an array of `XCSourceFile` objects.
*/
- (NSArray<XCSourceFile*>*)headerFiles;

/**
* Returns all implementation obj-c implementation files in the project, as an array of `XCSourceFile` objects.
*/
- (NSArray<XCSourceFile*>*)objectiveCFiles;

/**
* Returns all implementation obj-c++ implementation files in the project, as an array of `XCSourceFile` objects.
*/
- (NSArray<XCSourceFile*>*)objectiveCPlusPlusFiles;

/**
* Returns all the xib files in the project, as an array of `XCSourceFile` objects.
*/
- (NSArray<XCSourceFile*>*)xibFiles;

- (NSArray<XCSourceFile*>*)imagePNGFiles;

- (NSString*)filePath;


//-------------------------------------------------------------------------------------------
#pragma mark Groups
/**
* Lists the groups in an xcode project, returning an array of `XCGroup` objects.
*/
- (NSArray<XCGroup*>*)groups;

/**
 * Returns the root (top-level) _group.
 */
- (XCGroup*)rootGroup;

/**
 * Returns the root (top-level) groups, if there are multiple. An array of rootGroup if there is only one.
 */
- (NSArray<XCGroup*>*)rootGroups;

/**
* Returns the group with the given key, or nil.
*/
- (XCGroup*)groupWithKey:(NSString*)key;

/**
 * Returns the _first_ group in the project with the given name, or nil.
 */
- (XCGroup*)groupWithDisplayName:(NSString*)name;

/**
 * Returns the _group with the specified display name path - the directory relative to the root _group. Eg Source/Main
 */
- (XCGroup*)groupWithPathFromRoot:(NSString*)path;

/**
* Returns the parent _group for the _group or file with the given key;
*/
- (XCGroup*)groupForGroupMemberWithKey:(NSString*)key;

/**
 * Returns the parent group for the group or file with the source file
 */
- (XCGroup*)groupWithSourceFile:(XCSourceFile*)sourceFile;

/**
 * Removes all empty groups from the project.
 */
- (void)pruneEmptyGroups;

//-------------------------------------------------------------------------------------------
#pragma mark Targets
/**
* Lists the targets in an xcode project, returning an array of `XCTarget` objects.
*/
- (NSArray<XCTarget*>*)targets;

/**
* Returns the target with the specified name, or nil. 
*/
- (XCTarget*)targetWithName:(NSString*)name;

#pragma mark Configurations
/**
 * Lists the configurations in an xcode project.
 */
- (NSDictionary<NSString*,XCProjectBuildConfig*>*)configurations;
/**
 * Returns the configuration with the specified name, or nil.
 */
- (XCProjectBuildConfig*)configurationWithName:(NSString*)name;

- (XCProjectBuildConfig *)defaultConfiguration;

//-------------------------------------------------------------------------------------------
#pragma mark Saving
/**
* Saves a project after editing.
*/
- (void)save;


//-------------------------------------------------------------------------------------------
/**
* Raw project data.
*/
- (NSMutableDictionary*)objects;

- (NSMutableDictionary*)dataStore;

- (void)dropCache;

@end
