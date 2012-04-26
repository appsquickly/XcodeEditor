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
#import "XcodeSourceFileType.h"
#import "xcode_utils_AbstractDictionaryBuilder.h"


@interface xcode_utils_DictionaryBuilder : NSObject {

@private
    xcode_utils_AbstractDictionaryBuilder* _delegate;

}

+ (xcode_utils_DictionaryBuilder*) forFileReferenceWithPath:(NSString*)path name:(NSString*)name
        type:(XcodeSourceFileType)type;

+ (xcode_utils_DictionaryBuilder*) forGroupWithPathRelativeToParent:(NSString*)path alias:(NSString*)alias
        children:(NSArray*)children;

- (id) initWithDelegate:(xcode_utils_AbstractDictionaryBuilder*)delegate;

- (NSDictionary*) build;

@end
/* ================================================================================================================== */
@compatibility_alias DictionaryBuilder xcode_utils_DictionaryBuilder;