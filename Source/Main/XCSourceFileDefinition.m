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

#import "XCSourceFileDefinition.h"
#import "Utils/XCMemoryUtils.h"

@implementation XCSourceFileDefinition

@synthesize sourceFileName = _sourceFileName;
@synthesize type = _type;
@synthesize data = _data;

/* ================================================= Class Methods ================================================== */
+ (XCSourceFileDefinition*) sourceDefinitionWithName:(NSString*)name text:(NSString*)text
        type:(XcodeSourceFileType)type {

    return XCAutorelease([[XCSourceFileDefinition alloc] initWithName:name text:text type:type])
}

+ (XCSourceFileDefinition*) sourceDefinitionWithName:(NSString*)name data:(NSData*)data
        type:(XcodeSourceFileType)type {

    return XCAutorelease([[XCSourceFileDefinition alloc] initWithName:name data:data type:type])
}


/* ================================================== Initializers ================================================== */
- (id) initWithName:(NSString*)name text:(NSString*)text type:(XcodeSourceFileType)type {
    self = [super init];
    if (self) {
        _sourceFileName = [name copy];
        _data = [[text dataUsingEncoding:NSUTF8StringEncoding] copy];
        _type = type;
    }
    return self;
}

- (id) initWithName:(NSString*)name data:(NSData*)data type:(XcodeSourceFileType)type {
    self = [super init];
    if (self) {
        _sourceFileName = [name copy];
        _data = [data copy];
        _type = type;
    }
    return self;

}


/* ================================================== Deallocation ================================================== */
- (void) dealloc {
	XCRelease(_sourceFileName)
	XCRelease(_data)

	XCSuperDealloc
}
@end