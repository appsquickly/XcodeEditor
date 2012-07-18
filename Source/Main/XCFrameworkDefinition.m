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
#import "XCFrameworkDefinition.h"


@implementation XCFrameworkDefinition

@synthesize filePath = _filePath;
@synthesize copyToDestination = _copyToDestination;

/* ================================================= Class Methods ================================================== */
+ (XCFrameworkDefinition*) frameworkDefinitionWithFilePath:(NSString*)filePath
        copyToDestination:(BOOL)copyToDestination {

    return [[XCFrameworkDefinition alloc] initWithFilePath:filePath copyToDestination:copyToDestination];
}


/* ================================================== Initializers ================================================== */
- (id) initWithFilePath:(NSString*)filePath copyToDestination:(BOOL)copyToDestination {
    self = [super init];
    if (self) {
        _filePath = [filePath copy];
        _copyToDestination = copyToDestination;
    }
    return self;
}

/* ================================================ Interface Methods =============================================== */
- (NSString*) name {
    return [_filePath lastPathComponent];
}



@end