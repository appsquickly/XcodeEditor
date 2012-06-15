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
#import "xcode_AbstractDefinition.h"
#import "XcodeSourceFileType.h"
#import "xcode_Project.h"

@interface xcode_ProjectDefinition : xcode_AbstractDefinition {
    
    NSString* _sourceFileName;
    NSString* _path;
    XcodeSourceFileType _type;
    Project* _subproject;
    NSString* _key;
}

@property(nonatomic, strong, readonly) NSString* sourceFileName;
@property(nonatomic, strong, readonly) NSString* path;
@property(nonatomic, readonly) XcodeSourceFileType type;
@property(nonatomic, strong, readonly) Project* subproject;
@property(nonatomic, strong, readonly) NSString* key;

+ (xcode_ProjectDefinition*) projectDefinitionWithName:(NSString*)name path:(NSString*)path;

- (id) initWithName:(NSString*)name projPath:(NSString*)path type:(XcodeSourceFileType)type;

- (NSString*) xcodeprojFileName;

- (NSString*) xcodeprojFullPathName;

- (NSArray *) buildProductNames;

- (NSString*) xcodeprojKeyForProject:(Project *)project;

- (NSString*) pathRelativeToProjectRoot:(Project*)project;

- (NSString*) description;

@end
/* ================================================================================================================== */

@compatibility_alias ProjectDefinition xcode_ProjectDefinition;