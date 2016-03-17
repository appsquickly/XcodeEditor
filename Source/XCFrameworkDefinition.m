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



#import "XCFrameworkDefinition.h"
#import "XCProject.h"

@implementation XCFrameworkDefinition

@synthesize filePath = _filePath;
@synthesize copyToDestination = _copyToDestination;
@synthesize sourceTree = _sourceTree;

//-------------------------------------------------------------------------------------------
#pragma mark - Class Methods
//-------------------------------------------------------------------------------------------

+ (XCFrameworkDefinition *)frameworkDefinitionWithFilePath:(NSString *)filePath
                                         copyToDestination:(BOOL)copyToDestination
{
    return [XCFrameworkDefinition frameworkDefinitionWithFilePath:filePath copyToDestination:copyToDestination sourceTree:SourceTreeGroup];
}

+ (XCFrameworkDefinition *)frameworkDefinitionWithFilePath:(NSString *)filePath
                                         copyToDestination:(BOOL)copyToDestination
                                                sourceTree:(XcodeSourceTreeType)sourceTree
{
    
    return [[XCFrameworkDefinition alloc] initWithFilePath:filePath copyToDestination:copyToDestination sourceTree:sourceTree];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Initialization & Destruction
//-------------------------------------------------------------------------------------------

- (id)initWithFilePath:(NSString *)filePath copyToDestination:(BOOL)copyToDestination
{
    return [self initWithFilePath:filePath copyToDestination:copyToDestination sourceTree:SourceTreeGroup];
}

- (id)initWithFilePath:(NSString *)filePath copyToDestination:(BOOL)copyToDestination sourceTree:(XcodeSourceTreeType)sourceTree
{
    self = [super init];
    if (self) {
        _filePath = [filePath copy];
        _copyToDestination = copyToDestination;
        _sourceTree = sourceTree;
    }
    return self;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Interface Methods
//-------------------------------------------------------------------------------------------

- (NSString *)fileName
{
    return [[_filePath lastPathComponent] stringByReplacingOccurrencesOfString:@"/" withString:@""];
}



@end