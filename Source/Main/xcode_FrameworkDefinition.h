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
#import "xcode_AbstractDefinition.h"


@interface xcode_FrameworkDefinition : xcode_AbstractDefinition {
    NSString* _filePath;
    BOOL _copyToDestination;
}

@property(nonatomic, strong, readonly) NSString* filePath;
@property(nonatomic, readonly) BOOL copyToDestination;

+ (xcode_FrameworkDefinition*) frameworkDefinitionWithFilePath:(NSString*)filePath
        copyToDestination:(BOOL)copyToDestination;

- (id) initWithFilePath:(NSString*)filePath copyToDestination:(BOOL)copyToDestination;

- (NSString*) name;


@end
/* ================================================================================================================== */
@compatibility_alias FrameworkDefinition xcode_FrameworkDefinition;