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
#import "xcode_utils_AbstractDictionaryBuilder.h"

@interface xcode_utils_GroupBuilder : xcode_utils_AbstractDictionaryBuilder;

@property(nonatomic, strong, readonly) NSString* pathRelativeToParent;
@property(nonatomic, strong, readonly) NSString* alias;
@property(nonatomic, strong, readonly) NSArray* children;

- (id) initWithPathRelativeToParent:(NSString*)pathRelativeToParent alias:(NSString*)alias children:(NSArray*)children;


@end
/* ================================================================================================================== */
@compatibility_alias GroupBuilder xcode_utils_GroupBuilder;