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

@interface xcode_XcodeprojDefinition : xcode_AbstractDefinition {
    
    NSString* _sourceFileName;
    NSString* _path;
    XcodeSourceFileType _type;
}

@property(nonatomic, strong, readonly) NSString* sourceFileName;
@property(nonatomic, strong, readonly) NSString* path;
@property(nonatomic, readonly) XcodeSourceFileType type;

+ (xcode_XcodeprojDefinition*) sourceDefinitionWithName:(NSString*)name projPath:(NSString*)path type:(XcodeSourceFileType)type;

- (id) initWithName:(NSString*)name projPath:(NSString*)path type:(XcodeSourceFileType)type;

- (NSString*) xcodeprojFileName;

- (NSString*) xcodeprojFullPathName;

@end
/* ================================================================================================================== */
@compatibility_alias XcodeprojDefinition xcode_XcodeprojDefinition;