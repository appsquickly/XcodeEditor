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

#import "xcode_utils_GroupBuilder.h"


@implementation xcode_utils_GroupBuilder

@synthesize pathRelativeToParent = _pathRelativeToParent;
@synthesize alias = _alias;
@synthesize children = _children;

/* ================================================== Initializers ================================================== */
- (id) initWithPathRelativeToParent:(NSString*)pathRelativeToParent alias:(NSString*)alias children:(NSArray*)children {
    self = [super init];
    if (self) {
        _pathRelativeToParent = [pathRelativeToParent copy];
        _alias = [alias copy];
        _children = [NSArray arrayWithArray:children];
    }
    return self;
}

- (NSDictionary*) build {
    [_dictionary setObject:@"<group>" forKey:@"sourceTree"];

    if (_alias != nil) {
        [_dictionary setObject:_alias forKey:@"name"];
    }

    if (_pathRelativeToParent) {
        [_dictionary setObject:_pathRelativeToParent forKey:@"path"];
    }
    [_dictionary setObject:_children forKey:@"children"];

    return [NSDictionary dictionaryWithDictionary:_dictionary];
}


/* ================================================== Utility Methods =============================================== */
- (void) dealloc {
    [_pathRelativeToParent release];
    [_alias release];
    [_children release];
    [super dealloc];
}


@end