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
#import "XcodeSourceFileType.h"

@class XCProject;

/**
* Represents a file resource in an xcode project.
*/
@interface XCSourceFile : NSObject <XcodeGroupMember>
{

@private
    XCProject* _project;

    NSNumber* _isBuildFile;
    NSString* _buildFileKey;
    NSString* _name;
    NSString* _sourceTree;
    NSString* _key;
    NSString* _path;
    XcodeSourceFileType _type;
}

@property(nonatomic, readonly) XcodeSourceFileType type;
@property(nonatomic, strong, readonly) NSString* key;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong, readonly) NSString* sourceTree;
@property(nonatomic, strong) NSString* path;

+ (XCSourceFile*)sourceFileWithProject:(XCProject*)project key:(NSString*)key type:(XcodeSourceFileType)type name:(NSString*)name
    sourceTree:(NSString*)tree path:(NSString*)path;

- (id)initWithProject:(XCProject*)project key:(NSString*)key type:(XcodeSourceFileType)type name:(NSString*)name sourceTree:(NSString*)tree
    path:(NSString*)path;

/**
* If yes, indicates the file is able to be included for compilation in an `XCTarget`.
*/
- (BOOL)isBuildFile;

- (BOOL)canBecomeBuildFile;

- (XcodeMemberType)buildPhase;

- (NSString*)buildFileKey;

/**
* Adds this file to the project as an `xcode_BuildFile`, ready to be included in targets.
*/
- (void)becomeBuildFile;

@end
