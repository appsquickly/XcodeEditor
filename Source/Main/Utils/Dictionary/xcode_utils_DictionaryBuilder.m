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

#import "xcode_utils_DictionaryBuilder.h"
#import "xcode_utils_FileReferenceBuilder.h"
#import "xcode_utils_GroupBuilder.h"

@implementation xcode_utils_DictionaryBuilder

/* ================================================= Class Methods ================================================== */
+ (xcode_utils_DictionaryBuilder*) forFileReferenceWithPath:(NSString*)path name:(NSString*)name
        type:(XcodeSourceFileType)type {

    AbstractDictionaryBuilder* delegate = [[FileReferenceBuilder alloc] initWithPath:path name:name type:type];
    DictionaryBuilder* builder = [[[DictionaryBuilder alloc] initWithDelegate:delegate] autorelease];
    [delegate release];
    return builder;
}

+ (xcode_utils_DictionaryBuilder*) forGroupWithPathRelativeToParent:(NSString*)pathRelativeToParent
        alias:(NSString*)alias
        children:(NSArray*)children {

    AbstractDictionaryBuilder* delegate =
            [[GroupBuilder alloc] initWithPathRelativeToParent:pathRelativeToParent alias:alias children:children];
    DictionaryBuilder* builder = [[[DictionaryBuilder alloc] initWithDelegate:delegate] autorelease];
    [delegate release];
    return builder;

}

/* ================================================== Initializers ================================================== */
- (id) initWithDelegate:(xcode_utils_AbstractDictionaryBuilder*)delegate {
    self = [super init];
    if (self) {
        _delegate = [delegate retain];
    }
    return self;
}

/* ================================================ Interface Methods =============================================== */
- (NSDictionary*) build {
    return [_delegate build];
}


/* ================================================== Utility Methods =============================================== */
- (void) dealloc {
    [_delegate release];
    [super dealloc];
}

@end

