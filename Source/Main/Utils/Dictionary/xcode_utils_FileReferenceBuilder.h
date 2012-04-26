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

@interface xcode_utils_FileReferenceBuilder : xcode_utils_AbstractDictionaryBuilder


@property(nonatomic, strong, readonly) NSString* path;
@property(nonatomic, strong, readonly) NSString* name;
@property(nonatomic, readonly) XcodeSourceFileType type;

- (id) initWithPath:(NSString*)path name:(NSString*)name type:(XcodeSourceFileType)type;


@end
/* ================================================================================================================== */
@compatibility_alias FileReferenceBuilder xcode_utils_FileReferenceBuilder;