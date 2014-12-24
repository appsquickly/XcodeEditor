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
#import "XCAbstractDefinition.h"
#import "XcodeSourceFileType.h"

@class XCProject;


@interface XCSubProjectDefinition : XCAbstractDefinition
{

    NSString* _name;
    NSString* _path;
    XcodeSourceFileType _type;
    XCProject* _subProject;
    XCProject* _parentProject;
    NSString* _key;
    NSString* _fullProjectPath;
    NSString* _relativePath;
}


@property(nonatomic, strong, readonly) NSString* name;
@property(nonatomic, strong, readonly) NSString* path;
@property(nonatomic, readonly) XcodeSourceFileType type;
@property(nonatomic, strong, readonly) XCProject* subProject;
@property(nonatomic, strong, readonly) XCProject* parentProject;
@property(nonatomic, strong, readonly) NSString* key;
@property(nonatomic, strong, readwrite) NSString* fullProjectPath;

+ (XCSubProjectDefinition*)withName:(NSString*)name path:(NSString*)path parentProject:(XCProject*)parentProject;

- (id)initWithName:(NSString*)name path:(NSString*)path parentProject:(XCProject*)parentProject;

- (NSString*)projectFileName;

- (NSString*)fullPathName;

- (NSArray*)buildProductNames;

- (NSString*)projectKey;

- (NSString*)pathRelativeToProjectRoot;

- (NSString*)description;

- (void)initFullProjectPath:(NSString*)fullProjectPath groupPath:(NSString*)groupPath;

@end
