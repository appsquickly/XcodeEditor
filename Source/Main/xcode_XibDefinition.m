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
#import "xcode_XibDefinition.h"


@implementation xcode_XibDefinition

@synthesize name = _name;
@synthesize content = _content;

/* ================================================== Initializers ================================================== */
- (id) initWithName:(NSString*)name content:(NSString*)content {
    self = [super init];
    if (self) {
        _name = name;
        _content = content;
    }
    return self;
}

- (NSString*) xibFileName {
    return [_name stringByAppendingString:@".xib"];
}


@end