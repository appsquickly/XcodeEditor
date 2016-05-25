////////////////////////////////////////////////////////////////////////////////
//
//  JASPER BLUES
//  Copyright 2012 Jasper Blues
//  All Rights Reserved.
//
//  NOTICE: Jasper Blues permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "XcodeSourceTreeType.h"

static NSString* const kPBXSourceTreeSKRoot= @"SDKROOT";
static NSString* const kPBXSourceTreeGroup = @"<group>";

static NSDictionary* DictionaryWithProjectSourceTreeTypesAsStrings() {
    // This is the most vital operation on adding 500+ files
    // So, we caching this dictionary
    static NSDictionary* _projectNodeTypesAsStrings;
    if (_projectNodeTypesAsStrings) {
        return _projectNodeTypesAsStrings;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _projectNodeTypesAsStrings = @{
                                       kPBXSourceTreeSKRoot              : @(SourceTreeSDKRoot),
                                       kPBXSourceTreeGroup            : @(SourceTreeGroup),
                                       };
    });
    return _projectNodeTypesAsStrings;
}

@implementation NSString (XcodeSourceTreeTypeExtensions)

+ (NSString*)xce_stringFromSourceTreeType:(XcodeSourceTreeType)nodeType {
    NSDictionary* nodeTypesToString = DictionaryWithProjectSourceTreeTypesAsStrings();
    return [[nodeTypesToString allKeysForObject:@(nodeType)] firstObject];
}


- (XcodeSourceTreeType)xce_asSourceTreeType {
    NSDictionary* nodeTypesToString = DictionaryWithProjectSourceTreeTypesAsStrings();
    return (XcodeSourceTreeType) [[nodeTypesToString objectForKey:self] intValue];
}

@end