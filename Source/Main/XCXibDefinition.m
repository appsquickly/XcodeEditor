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


#import "XCXibDefinition.h"
#import "Utils/XCMemoryUtils.h"

@implementation XCXibDefinition

@synthesize name = _name;
@synthesize content = _content;

/* ================================================= Class Methods ================================================== */
+ (XCXibDefinition*) xibDefinitionWithName:(NSString*)name {
    return XCAutorelease([[XCXibDefinition alloc] initWithName:name])
}

+ (XCXibDefinition*) xibDefinitionWithName:(NSString*)name content:(NSString*)content {
    return XCAutorelease([[XCXibDefinition alloc] initWithName:name content:content])
}


/* ================================================== Initializers ================================================== */
- (id) initWithName:(NSString*)name {
    return [self initWithName:name content:nil];
}


- (id) initWithName:(NSString*)name content:(NSString*)content {
    self = [super init];
    if (self) {
        _name = [name copy];
        _content = [content copy];
    }
    return self;
}

/* ================================================== Deallocation ================================================== */
- (void) dealloc {
	XCRelease(_name)
	XCRelease(_content)

	XCSuperDealloc
}

/* ================================================ Interface Methods =============================================== */
- (NSString*) xibFileName {
    return [_name stringByAppendingString:@".xib"];
}

@end