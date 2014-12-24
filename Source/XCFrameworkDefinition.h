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


@interface XCFrameworkDefinition : XCAbstractDefinition
{
    NSString* _filePath;
    BOOL _copyToDestination;
}

@property(nonatomic, strong, readonly) NSString* filePath;
@property(nonatomic, readonly) BOOL copyToDestination;

+ (XCFrameworkDefinition*)frameworkDefinitionWithFilePath:(NSString*)filePath copyToDestination:(BOOL)copyToDestination;

- (id)initWithFilePath:(NSString*)filePath copyToDestination:(BOOL)copyToDestination;

- (NSString*)name;


@end