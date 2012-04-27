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
#import "XcodeSourceFileType.h"

@class xcode_Project;

/**
* Represents a file resource in an xcode project.
*/
@interface xcode_SourceFile : NSObject<XcodeGroupMember> {

@private
    __weak xcode_Project* _project;

    NSNumber* _isBuildFile;
    NSString* _buildFileKey;
    NSString* _name;
    NSString* _sourceTree;
    NSString* _key;
    XcodeSourceFileType _type;
}

@property(nonatomic, readonly) XcodeSourceFileType type;
@property(nonatomic, strong, readonly) NSString* key;
@property(nonatomic, strong, readonly) NSString* name;
@property(nonatomic, strong, readonly) NSString* sourceTree;

+ (xcode_SourceFile*) sourceFileWithProject:(xcode_Project*)project
        key:(NSString*)key
        type:(XcodeSourceFileType)type
        name:(NSString*)name
        sourceTree:(NSString*)tree;

- (id) initWithProject:(xcode_Project*)project
        key:(NSString*)key
        type:(XcodeSourceFileType)type
        name:(NSString*)name
        sourceTree:(NSString*)tree;

/**
* If yes, indicates the file is able to be included for compilation in an `xcode_Target`.
*/
- (BOOL) isBuildFile;

- (BOOL) canBecomeBuildFile;

- (NSString*) buildFileKey;

/**
* Adds this file to the project as an `xcode_BuildFile`, ready to be included in targets.
*/
- (void) becomeBuildFile;

@end

/* ================================================================================================================== */
@compatibility_alias SourceFile xcode_SourceFile;