////////////////////////////////////////////////////////////////////////////////
//
//  Synapticats, LLC
//  Copyright 2012 Synapticats, LLC
//  All Rights Reserved.
//
//  NOTICE: Expanz and Synapticats, LLC permit you to use, modify, and distribute 
//  this file in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import <Foundation/Foundation.h>
#import <XcodeEditor/xcode_AbstractDefinition.h>
#import <XcodeEditor/XcodeSourceFileType.h>

@class xcode_Project;


@interface xcode_SubProjectDefinition : xcode_AbstractDefinition {

    NSString* _name;
    NSString* _path;
    XcodeSourceFileType _type;
    xcode_Project* _subProject;
    NSString* _key;
    NSString* _fullProjectPath;
}


@property(nonatomic, strong, readonly) NSString* name;
@property(nonatomic, strong, readonly) NSString* path;
@property(nonatomic, readonly) XcodeSourceFileType type;
@property(nonatomic, strong, readonly) xcode_Project* subProject;
@property(nonatomic, strong, readonly) xcode_Project* parentProject;
@property(nonatomic, strong, readonly) NSString* key;
@property(nonatomic, strong, readwrite) NSString* fullProjectPath;

+ (xcode_SubProjectDefinition*) subProjectDefinitionWithName:(NSString*)name path:(NSString*)path
        parentProject:(xcode_Project*)parentProject;

- (id) initWithName:(NSString*)name path:(NSString*)path parentProject:(xcode_Project*)parentProject;

- (NSString*) xcodeprojFileName;

- (NSString*) xcodeprojFullPathName;

- (NSArray*) buildProductNames;

- (NSString*) xcodeprojKeyForProject:(xcode_Project*)project;

- (NSString*) pathRelativeToProjectRoot;

- (NSString*) description;

- (void) initFullProjectPath:(NSString*)fullProjectPath groupPath:(NSString*)groupPath;

@end
/* ================================================================================================================== */

@compatibility_alias SubProjectDefinition xcode_SubProjectDefinition;
