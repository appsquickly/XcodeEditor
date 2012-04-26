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

#import <Foundation/Foundation.h>

@interface xcode_utils_AbstractDictionaryBuilder : NSObject {

NSMutableDictionary* _dictionary;

}

- (NSDictionary*) build;

@end

/* ================================================================================================================== */
@compatibility_alias AbstractDictionaryBuilder xcode_utils_AbstractDictionaryBuilder;