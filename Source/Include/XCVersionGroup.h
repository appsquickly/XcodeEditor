//
//  XCCoreDataModelVersioned.h
//  xcode-editor
//
//  Created by joel on 04/09/15.
//
//

#import <Foundation/Foundation.h>
#import "XcodeGroupMember.h"
#import "XCGroup.h"
#import "XCBuildFile.h"

@class XCProject;
@class XCClassDefinition;
@class XCSourceFile;
@class XCXibDefinition;
@class XCFileOperationQueue;
@class XCFrameworkDefinition;
@class XCSourceFileDefinition;
@class XCSubProjectDefinition;

@interface XCVersionGroup : NSObject <XcodeGroupMember,XCBuildFile>
{
    NSString* _pathRelativeToParent;
    NSString* _key;
    
@private
    NSString* _pathRelativeToProjectRoot;
    NSMutableArray* _children;
    NSMutableArray* _members;
    NSString *_currentVersion;
    NSString *_versionGroupType;
    
    NSNumber *_isBuildFile;
    NSString *_buildFileKey;
    
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
@property(nonatomic, strong, readonly) NSMutableArray* versions;

@property(nonatomic,strong) NSString*currentVersion;


#pragma mark Initializers

+ (XCVersionGroup*)versionGroupWithProject:(XCProject*)project key:(NSString*)key path:(NSString*)path children:(NSArray*)children currentVersion:(NSString*)currentVersion;

- (id)initWithProject:(XCProject*)project key:(NSString*)key path:(NSString*)path children:(NSArray*)children currentVersion:(NSString*)currentVersion;

#pragma mark Parent group

- (void)removeFromParentGroup;

- (void)removeFromParentDeletingChildren:(BOOL)deleteChildren;

- (XCGroup*)parentGroup;

#pragma mark Adding children

/**
 * Adds a source file. The only valid file type is XCDataModel
 */
- (void)addDataModelSource:(XCSourceFileDefinition*)sourceFileDefinition;

#pragma mark Locating children

- (NSArray<XCSourceFile*>*)members;

- (NSArray<NSString*>*)buildFileKeys;

/**
 * Returns the child with the specified key, or nil.
 */
- (XCSourceFile*)memberWithKey:(NSString*)key;

/**
 * Returns the child with the specified name, or nil.
 */
- (XCSourceFile*)memberWithDisplayName:(NSString*)name;

- (NSDictionary*)asDictionary;

@end
