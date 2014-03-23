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
#import "XcodeGroupMember.h"

@class XCProject;
@class XCClassDefinition;
@class XCSourceFile;
@class XCXibDefinition;
@class XCFileOperationQueue;
@class XCFrameworkDefinition;
@class XCSourceFileDefinition;
@class XCSubProjectDefinition;


/**
* Represents a group container in an Xcode project. A group can contain members of type `XCSourceFile` or other
* groups.
*/
@interface XCGroup : NSObject <XcodeGroupMember>
{

    NSString* _pathRelativeToParent;
    NSString* _key;
    NSString* _alias;


@private
    NSString* _pathRelativeToProjectRoot;
    NSMutableArray* _children;
    NSMutableArray* _members;

    XCFileOperationQueue* _fileOperationQueue; // weak
    XCProject* _project;

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
@property(nonatomic, strong, readonly) NSMutableArray* children;


#pragma mark Initializers

+ (XCGroup*)groupWithProject:(XCProject*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path children:(NSArray*)children;

- (id)initWithProject:(XCProject*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path children:(NSArray*)children;

#pragma mark Parent group

- (void)removeFromParentGroup;

- (void)removeFromParentDeletingChildren:(BOOL)deleteChildren;

- (XCGroup*)parentGroup;

- (BOOL)isRootGroup;

#pragma mark Adding children
/**
 * Adds a class to the group, as specified by the ClassDefinition. If the group already contains a class by the same
 * name, the contents will be updated.
*/
- (void)addClass:(XCClassDefinition*)classDefinition;

/**
 * Adds a class to the group, making it a member of the specified [targets](XCTarget).
*/
- (void)addClass:(XCClassDefinition*)classDefinition toTargets:(NSArray*)targets;

/**
* Adds a framework to the group. If the group already contains the framework, the contents will be updated if the
* framework definition's copyToDestination flag is yes, otherwise it will be ignored.
*/
- (void)addFramework:(XCFrameworkDefinition*)frameworkDefinition;

/**
* Adds a group with a path relative to this group.
*/
- (XCGroup*)addGroupWithPath:(NSString*)path;

/**
* Adds a framework to the group, making it a member of the specified targets.
*/
- (void)addFramework:(XCFrameworkDefinition*)framework toTargets:(NSArray*)targets;

/**
* Adds a source file of arbitrary type - image resource, header, etc.
*/
- (void)addSourceFile:(XCSourceFileDefinition*)sourceFileDefinition;


/**
 * Adds a xib file to the group. If the group already contains a class by the same name, the contents will be updated.
*/
- (void)addXib:(XCXibDefinition*)xibDefinition;

/**
 * Adds a xib to the group, making it a member of the specified [targets](XCTarget).
*/
- (void)addXib:(XCXibDefinition*)xibDefinition toTargets:(NSArray*)targets;

/**
 * Adds a sub-project to the group. If the group already contains a sub-project by the same name, the contents will be
 * updated.
 * Returns boolean success/fail; if method fails, caller should assume that project file is corrupt (or file format has
 * changed).
*/
- (void)addSubProject:(XCSubProjectDefinition*)projectDefinition;

/**
* Adds a sub-project to the group, making it a member of the specified [targets](XCTarget).
*/
- (void)addSubProject:(XCSubProjectDefinition*)projectDefinition toTargets:(NSArray*)targets;

- (void)removeSubProject:(XCSubProjectDefinition*)projectDefinition;

- (void)removeSubProject:(XCSubProjectDefinition*)projectDefinition fromTargets:(NSArray*)targets;


#pragma mark Locating children
/**
 * Instances of `XCSourceFile` and `XCGroup` returned as the type `XcodeGroupMember`.
*/
- (NSArray*)members;

/**
* Instances of `XCSourceFile` from this group and any child groups.
*/
- (NSArray*)recursiveMembers;


- (NSArray*)buildFileKeys;

/**
 * Returns the child with the specified key, or nil.
*/
- (id <XcodeGroupMember>)memberWithKey:(NSString*)key;

/**
* Returns the child with the specified name, or nil.
*/
- (id <XcodeGroupMember>)memberWithDisplayName:(NSString*)name;


@end
