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

#import "xcode_utils_FileReferenceBuilder.h"
#import "XcodeMemberType.h"


@implementation xcode_utils_FileReferenceBuilder


@synthesize path = _path;
@synthesize name = _name;
@synthesize type = _type;

/* ================================================== Initializers ================================================== */
- (id) initWithPath:(NSString*)path name:(NSString*)name type:(XcodeSourceFileType)type {
    self = [super init];
    if (self) {
        _path = [path copy];
        _name = [name copy];
        _type = type;
    }
    return self;
}

/* ================================================= Protocol Methods =============================================== */
- (NSDictionary*) build {
    [_dictionary setObject:[NSString stringFromMemberType:PBXFileReference] forKey:@"isa"];
    [_dictionary setObject:@"4" forKey:@"FileEncoding"];
    [_dictionary setObject:[NSString stringFromSourceFileType:_type] forKey:@"lastKnownFileType"];
    if (_name != nil) {
        [_dictionary setObject:[_name lastPathComponent] forKey:@"name"];
    }
    if (_path != nil) {
        [_dictionary setObject:_path forKey:@"path"];
    }
    [_dictionary setObject:@"<group>" forKey:@"sourceTree"];

    return [NSDictionary dictionaryWithDictionary:_dictionary];
}



/* ================================================== Utility Methods =============================================== */
- (void) dealloc {
    [_path release];
    [_name release];
    [super dealloc];
}

@end