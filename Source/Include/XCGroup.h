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
#import <XcodeEditor/XcodeGroupMember.h>
#import <XcodeEditor/XcodeSourceFileType.h>
#import <XcodeEditor/XCBuildFile.h>

@class XCProject;
@class XCClassDefinition;
@class XCSourceFile;
@class XCXibDefinition;
@class XCFileOperationQueue;
@class XCFrameworkDefinition;
@class XCSourceFileDefinition;
@class XCSubProjectDefinition;
@class XCTarget;
@class XCVersionGroup;

/**
* Represents a _group container in an Xcode project. A group can contain members of type `XCSourceFile` or other
* groups.
*/
@interface XCGroup : NSObject <XcodeGroupMember, XCBuildFile>
{

    NSString* _pathRelativeToParent;
    NSString* _key;
    NSString* _alias;


@private
    NSString* _pathRelativeToProjectRoot;
    NSMutableArray* _children;
    NSMutableArray* _members;

    NSNumber *_isBuildFile;
    NSString *_buildFileKey;

    XCFileOperationQueue* _fileOperationQueue;
    XCProject* _project;
    XcodeMemberType _memberType;

}


/**
 * The alias of the group, which can be used to give the group a name other than the last path component.
 *
 * See: [XcodeGroupMember displayName]
 */
@property(nonatomic, strong, readonly) NSString* alias;

/**
 * The path of the group relative to the group's parent.
 *
 * See: [XcodeGroupMember displayName]
*/
@property(nonatomic, strong, readonly) NSString* pathRelativeToParent;

/**
 * The group's unique key.
*/
@property(nonatomic, strong, readonly) NSString* key;

/**
 * An array containing the groups members as `XcodeGroupMember` types.
*/
@property(nonatomic, strong, readonly) NSMutableArray<id<XcodeGroupMember>>* children;


#pragma mark Initializers

+ (XCGroup*)groupWithProject:(XCProject*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path children:(NSArray<id<XcodeGroupMember>>*)children;

+ (XCGroup*)groupWithProject:(XCProject*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path children:(NSArray<id<XcodeGroupMember>>*)children memberType:(XcodeMemberType)groupType;

- (id)initWithProject:(XCProject*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path children:(NSArray<id<XcodeGroupMember>>*)children;

- (id)initWithProject:(XCProject*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path children:(NSArray<id<XcodeGroupMember>>*)children memberType:(XcodeMemberType)groupType;

#pragma mark Parent group

- (void)removeFromParentGroup;

- (void)removeFromParentDeletingChildren:(BOOL)deleteChildren;

- (XCGroup*)parentGroup;

- (BOOL)isRootGroup;

- (BOOL)isEmpty;

#pragma mark Adding children
/**
 * Adds a class to the _group, as specified by the ClassDefinition. If the _group already contains a class by the same
 * name, the contents will be updated.
*/
- (void)addClass:(XCClassDefinition*)classDefinition;

/**
 * Adds a class to the _group, making it a member of the specified [targets](XCTarget).
*/
- (void)addClass:(XCClassDefinition*)classDefinition toTargets:(NSArray<XCTarget*>*)targets;

/**
 * Removes a class from the _group
*/
- (void)removeClass:(XCClassDefinition*)classDefinition fromTargets:(NSArray*)targets;

/** 
 * Removes a header from the _group
*/
- (void)removeHeader:(XCClassDefinition*)classDefinition;

/**
* Adds a framework to the _group. If the _group already contains the framework, the contents will be updated if the
* framework definition's copyToDestination flag is yes, otherwise it will be ignored.
*/
- (void)addFramework:(XCFrameworkDefinition*)frameworkDefinition;

/**
* Removes a framework from the _group
*/
- (void) removeFramework:(XCFrameworkDefinition *)frameworkDefinition fromTargets:(NSArray *)targets;

/**
* Adds a _group with a path relative to this _group.
*/
- (XCGroup*)addGroupWithPath:(NSString*)path;

/**
 * Adds a _group with an alias to this _group.
 */
- (XCGroup*)addGroupWithAlias:(NSString *)alias;

/**
 * Adds a _group with an alias to this _group and a particular type (only PBXGroupType and PBXVariantGroupType are valid)
 */
- (XCGroup*)addGroupWithAlias:(NSString *)alias groupType:(XcodeMemberType)type;

/**
 * Adds a version group with a path relative to this group.
 */
- (XCVersionGroup*)addVersionGroupWithPath:(NSString*)path;

/**
* Adds a reference to a folder
*/
- (void)addFolderReference:(NSString*)sourceFolder;

- (void)addFileReference:(NSString *)filePath withType:(XcodeSourceFileType)type;

/**
* Adds a framework to the _group, making it a member of the specified targets.
*/
- (XCSourceFile*)addFramework:(XCFrameworkDefinition*)framework toTargets:(NSArray<XCTarget*>*)targets;

/**
* Adds a source file of arbitrary type - image resource, header, etc.
*/
- (void)addSourceFile:(XCSourceFileDefinition*)sourceFileDefinition;


/**
 * Adds a xib file to the _group. If the _group already contains a class by the same name, the contents will be updated.
*/
- (void)addXib:(XCXibDefinition*)xibDefinition;

/**
 * Adds a xib to the _group, making it a member of the specified [targets](XCTarget).
*/
- (void)addXib:(XCXibDefinition*)xibDefinition toTargets:(NSArray<XCTarget*>*)targets;

/**
 * Adds a sub-project to the _group. If the _group already contains a sub-project by the same name, the contents will be
 * updated.
 * Returns boolean success/fail; if method fails, caller should assume that project file is corrupt (or file format has
 * changed).
*/
- (void)addSubProject:(XCSubProjectDefinition*)projectDefinition;

/**
* Adds a sub-project to the _group, making it a member of the specified [targets](XCTarget).
*/
- (void)addSubProject:(XCSubProjectDefinition*)projectDefinition toTargets:(NSArray<XCTarget*>*)targets;

- (void)removeSubProject:(XCSubProjectDefinition*)projectDefinition;

- (void)removeSubProject:(XCSubProjectDefinition*)projectDefinition fromTargets:(NSArray<XCTarget*>*)targets;


#pragma mark Locating children
/**
 * Instances of `XCSourceFile` and `XCGroup` returned as the type `XcodeGroupMember`.
*/
- (NSArray<id<XcodeGroupMember>>*)members;

/**
* Keys of members from this group and any child groups.
*/
- (NSArray<NSString*>*)recursiveMembers;

/**
 * Keys of members from this group
 */
- (NSArray<NSString*>*)buildFileKeys;

/**
 * Returns the child with the specified key, or nil.
*/
- (id <XcodeGroupMember>)memberWithKey:(NSString*)key;

/**
* Returns the child with the specified name, or nil.
*/
- (id <XcodeGroupMember>)memberWithDisplayName:(NSString*)name;

/**
 *  Remove the member with the specified key
 */
- (void)removeMemberWithKey:(NSString*)key;

@end
