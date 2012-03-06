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
#import "XcodeGroupMember.h"

@class xcode_Project;
@class xcode_ClassDefinition;
@class xcode_SourceFile;
@class xcode_XibDefinition;
@class xcode_FileWriteQueue;

/**
* Represents a group container in an Xcode project. A group can contain members of type `xcode_SourceFile` or other
* groups.
*/
@interface xcode_Group : NSObject<XcodeGroupMember> {

@private
    NSString* _pathRelativeToProjectRoot;
    NSMutableArray* _children;
    __weak xcode_FileWriteQueue* _writeQueue;
}

/* =================================================== Properties =================================================== */

/**
 * The [Xcode project](xcode_Project) that this group belongs to.
*/
@property(nonatomic, weak, readonly) xcode_Project* project;

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
@property(nonatomic, strong, readonly) NSArray* children;

/* ================================================== Initializers ================================================== */
- (id) initWithProject:(xcode_Project*)project key:(NSString*)key alias:(NSString*)alias path:(NSString*)path
        children:(NSArray*)children;

/* ================================================ Interface Methods =============================================== */
#pragma mark Adding children
/**
 * Adds a class to the group.
*/
- (void) addClass:(xcode_ClassDefinition*)classDefinition;

/**
 * Adds a class to the group, making it a member of the specified [targets](xcode_Target).
*/
- (void) addClass:(xcode_ClassDefinition*)classDefinition toTargets:(NSArray*)targets;

/**
 * Adds a xib file to the group.
*/
- (void) addXib:(xcode_XibDefinition*)xibDefinition;

/**
 * Adds a xib to the group, making it a member of the specified [targets](xcode_Target).
*/
- (void) addXib:(xcode_XibDefinition*)xibDefinition toTargets:(NSArray*)targets;

/* ================================================================================================================== */
#pragma mark Locating children
/**
 * Instances of `xcode_SourceFile` and `xcode_Group` returned as the type `XcodeGroupMember`.
*/
- (NSArray*) members;

/**
 * Returns the child with the specified key.
*/
- (id<XcodeGroupMember>) memberWithKey:(NSString*)key;

/* ================================================================================================================== */
#pragma mark File paths
/**
 * Returns the full path of the group relative to the base of the project.
*/
- (NSString*) pathRelativeToProjectRoot;

@end

/* ================================================================================================================== */
@compatibility_alias Group xcode_Group;