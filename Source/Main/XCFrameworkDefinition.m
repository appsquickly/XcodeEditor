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
#import "Utils/XCMemoryUtils.h"

@implementation XCFrameworkDefinition

@synthesize filePath = _filePath;
@synthesize copyToDestination = _copyToDestination;

/* ================================================= Class Methods ================================================== */
+ (XCFrameworkDefinition*) frameworkDefinitionWithFilePath:(NSString*)filePath
        copyToDestination:(BOOL)copyToDestination {

    return XCAutorelease([[XCFrameworkDefinition alloc] initWithFilePath:filePath copyToDestination:copyToDestination])
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


/* ================================================== Deallocation ================================================== */
- (void) dealloc {
	XCRelease(_filePath)

	XCSuperDealloc
}
@end