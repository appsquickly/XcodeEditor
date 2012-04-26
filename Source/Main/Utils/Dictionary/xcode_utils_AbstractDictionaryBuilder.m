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

#import "xcode_utils_AbstractDictionaryBuilder.h"


@implementation xcode_utils_AbstractDictionaryBuilder

/* ================================================== Initializers ================================================== */
- (id) init {
    self = [super init];
    if (self) {
        _dictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}


/* ================================================= Abstract Methods =============================================== */
- (NSDictionary*) build {
    return nil;
}

/* ================================================== Utility Methods =============================================== */
- (void) dealloc {
    [_dictionary release];
    [super dealloc];
}

@end