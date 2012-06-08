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
#import "XcodeMemberType.h"
#import "XcodeSourceFileType.h"

@class xcode_ClassDefinition;
@class xcode_Group;
@class xcode_FileOperationQueue;
@class xcode_SourceFile;
@class xcode_Target;
@class xcode_XcodeprojDefinition;


@interface xcode_Project : NSObject {

@private
    xcode_FileOperationQueue* _fileOperationQueue;

    NSString* _filePath;
    NSMutableDictionary* _dataStore;
    NSMutableArray* _targets;
}

@property(nonatomic, strong, readonly) xcode_FileOperationQueue* fileOperationQueue;

/* ================================================== Initializers ================================================== */

+ (xcode_Project*) projectWithFilePath:(NSString*)filePath;

/**
* Creates a new project editor instance with the specified Project.xcodeproj file.
*/
- (id) initWithFilePath:(NSString*)filePath;

/* ================================================================================================================== */

#pragma mark Files
/**
* Returns all file resources in the project, as an array of `xcode_SourceFile` objects.
*/
- (NSArray*) files;

/**
* Returns the project file with the specified key, or nil.
*/
- (xcode_SourceFile*) fileWithKey:(NSString*)key;

/**
* Returns the project file with the specified name, or nil. If more than one project file matches the specified name,
* which one is returned is undefined.
*/
- (xcode_SourceFile*) fileWithName:(NSString*)name;



/**
* Returns all header files in the project, as an array of `xcode_SourceFile` objects.
*/
- (NSArray*) headerFiles;

/**
* Returns all implementation obj-c implementation files in the project, as an array of `xcode_SourceFile` objects.
*/
- (NSArray*) objectiveCFiles;

/**
* Returns all implementation obj-c++ implementation files in the project, as an array of `xcode_SourceFile` objects.
*/
- (NSArray*) objectiveCPlusPlusFiles;

/**
* Returns all the xib files in the project, as an array of `xcode_SourceFile` objects.
*/
- (NSArray*) xibFiles;

- (NSArray*) imagePNGFiles;

#pragma mark xcodeproj methods

- (NSString*) referenceProxyKeyForName:(NSString*)name;

- (NSArray*) buildProductsForTargets;

- (void) addAsTargetDependency:(xcode_XcodeprojDefinition*)xcodeprojDefinition toTargets:(NSArray*)targets;

- (NSString*) makePathRelativeToProjectRoot:(NSString*)fullPath;

- (xcode_XcodeprojDefinition*) xcodeprojDefinitionWithName:(NSString*)name projPath:(NSString*)projPath type:(XcodeSourceFileType)type;

- (NSArray*) keysForProjectObjectsOfType:(XcodeMemberType)memberType withIdentifier:(NSString*)identifier;

- (NSMutableDictionary*) PBXProjectDict;

- (void) removeProxies:(NSString*)xcodeprojKey;

- (void) addProxies:(xcode_XcodeprojDefinition *)xcodeproj;

- (NSString*) removeFromProjectReferences:(NSString*)key;

- (void) removeTargetDependencies:(NSString*)name;

/* ================================================================================================================== */
#pragma mark Groups
/**
* Lists the groups in an xcode project, returning an array of `xcode_Group` objects.
*/
- (NSArray*) groups;

/**
 * Returns the root (top-level) group.
 */
- (xcode_Group*) rootGroup;

/**
* Returns the group with the given key, or nil.
*/
- (xcode_Group*) groupWithKey:(NSString*)key;

/**
 * Returns the group with the specified display name path - the directory relative to the root group. Eg Source/Main
 */
- (xcode_Group*) groupWithPathFromRoot:(NSString*)path;

/**
* Returns the parent group for the group or file with the given key;
*/
- (xcode_Group*) groupForGroupMemberWithKey:(NSString*)key;

/* ================================================================================================================== */
#pragma mark Targets
/**
* Lists the targets in an xcode project, returning an array of `xcode_Target` objects.
*/
- (NSArray*) targets;

/**
* Returns the target with the specified name, or nil. 
*/
- (xcode_Target*) targetWithName:(NSString*)name;

/* ================================================================================================================== */
#pragma mark Saving
/**
* Saves a project after editing.
*/
- (void) save;


/* ================================================================================================================== */
/**
* Raw project data.
*/
- (NSMutableDictionary*) objects;

@end

/* ================================================================================================================== */
@compatibility_alias Project xcode_Project;