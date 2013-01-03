////////////////////////////////////////////////////////////////////////////////
//
//  JASPER BLUES
//  Copyright 2012 - 2013 Jasper Blues
//  All Rights Reserved.
//
//  NOTICE: Jasper Blues permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


#import "XCAbstractDefinition.h"


@implementation XCAbstractDefinition

@synthesize fileOperationStyle = _fileOperationStyle;


/* ============================================================ Initializers ============================================================ */
- (id)init
{
    self = [super init];
    if (self)
    {
        _fileOperationStyle = FileOperationStyleOverwrite;
    }
    return self;
}


@end