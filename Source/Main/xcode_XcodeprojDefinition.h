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

@interface xcode_XcodeprojDefinition : xcode_AbstractDefinition {
    
    NSString* _sourceFileName;
    NSString* _path;
    XcodeSourceFileType _type;
    Project* _subproject;
    NSString* _pathRelativeToProjectRoot;
    NSString* _key;
}

@property(nonatomic, strong, readonly) NSString* sourceFileName;
@property(nonatomic, strong, readonly) NSString* path;
@property(nonatomic, readonly) XcodeSourceFileType type;
@property(nonatomic, strong, readonly) Project* subproject;
@property(nonatomic, strong, readwrite) NSString* pathRelativeToProjectRoot;
@property(nonatomic, strong, readonly) NSString* key;

+ (xcode_XcodeprojDefinition*) xcodeprojDefinitionWithName:(NSString*)name projPath:(NSString*)path;

- (id) initWithName:(NSString*)name projPath:(NSString*)path type:(XcodeSourceFileType)type;

- (NSString*) xcodeprojFileName;

- (NSString*) xcodeprojFullPathName;

- (NSArray *) buildProductNames;

- (NSString*) xcodeprojKey:(Project *)project;

@end
/* ================================================================================================================== */

@compatibility_alias XcodeprojDefinition xcode_XcodeprojDefinition;