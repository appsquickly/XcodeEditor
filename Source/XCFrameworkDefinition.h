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
#import "XcodeSourceTreeType.h"

@interface XCFrameworkDefinition : XCAbstractDefinition
{
    NSString* _filePath;
    BOOL _copyToDestination;
    XcodeSourceTreeType _sourceTree;
}

@property(nonatomic, strong, readonly) NSString* filePath;
@property(nonatomic, readonly) BOOL copyToDestination;
@property(nonatomic, readonly) XcodeSourceTreeType sourceTree;

+ (XCFrameworkDefinition*)frameworkDefinitionWithFilePath:(NSString*)filePath copyToDestination:(BOOL)copyToDestination;
+ (XCFrameworkDefinition*)frameworkDefinitionWithFilePath:(NSString*)filePath copyToDestination:(BOOL)copyToDestination sourceTree:(XcodeSourceTreeType)sourceTree;

- (id)initWithFilePath:(NSString*)filePath copyToDestination:(BOOL)copyToDestination;
- (id)initWithFilePath:(NSString*)filePath copyToDestination:(BOOL)copyToDestination
            sourceTree:(XcodeSourceTreeType)sourceTree;

- (NSString*)fileName;



@end