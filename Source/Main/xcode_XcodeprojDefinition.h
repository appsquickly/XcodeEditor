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
}

@property(nonatomic, strong, readonly) NSString* sourceFileName;
@property(nonatomic, strong, readonly) NSString* path;
@property(nonatomic, readonly) XcodeSourceFileType type;
@property(nonatomic, strong, readonly) Project* subproject;

+ (xcode_XcodeprojDefinition*) sourceDefinitionWithName:(NSString*)name projPath:(NSString*)path type:(XcodeSourceFileType)type;

- (id) initWithName:(NSString*)name projPath:(NSString*)path type:(XcodeSourceFileType)type;

- (NSString*) xcodeprojFileName;

- (NSString*) xcodeprojFullPathName;

@end
/* ================================================================================================================== */

// TODO write a description method

@compatibility_alias XcodeprojDefinition xcode_XcodeprojDefinition;