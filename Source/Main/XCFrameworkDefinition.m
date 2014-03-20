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

@implementation XCFrameworkDefinition

@synthesize filePath = _filePath;
@synthesize copyToDestination = _copyToDestination;

/* ====================================================================================================================================== */
#pragma mark - Class Methods

+ (XCFrameworkDefinition*)frameworkDefinitionWithFilePath:(NSString*)filePath copyToDestination:(BOOL)copyToDestination
{

    return [[XCFrameworkDefinition alloc] initWithFilePath:filePath copyToDestination:copyToDestination];
}

/* ====================================================================================================================================== */
#pragma mark - Initialization & Destruction

- (id)initWithFilePath:(NSString*)filePath copyToDestination:(BOOL)copyToDestination
{
    self = [super init];
    if (self)
    {
        _filePath = [filePath copy];
        _copyToDestination = copyToDestination;
    }
    return self;
}

/* ====================================================================================================================================== */
#pragma mark - Interface Methods

- (NSString*)name
{
    return [_filePath lastPathComponent];
}


@end