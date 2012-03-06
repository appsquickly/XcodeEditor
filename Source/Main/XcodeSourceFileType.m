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

#import "XcodeSourceFileType.h"
#import "xcode_utils_Enum.h"


@implementation NSDictionary (XcodeFileType)

+ (NSDictionary*) dictionaryWithFileReferenceTypesAsStrings {
    return [NSDictionary dictionaryWithObjectsAndKeys:boxEnum(SourceCodeHeader), @"sourcecode.c.h",
                                                      boxEnum(SourceCodeObjC), @"sourcecode.c.objc",
                                                      boxEnum(Framework), @"wrapper.framework",
                                                      boxEnum(PropertyList), @"text.plist.strings",
                                                      boxEnum(SourceCodeObjCPlusPlus), @"sourcecode.cpp.objcpp",
                                                      boxEnum(XibFile), @"file.xib", nil];
}

@end

@implementation NSString (XcodeFileType)

+ (NSString*) stringFromSourceFileType:(XcodeSourceFileType)type {
    return [[[NSDictionary dictionaryWithFileReferenceTypesAsStrings] allKeysForObject:boxEnum(type)] objectAtIndex:0];
}


- (XcodeSourceFileType) asSourceFileType {
    NSDictionary* typeStrings = [NSDictionary dictionaryWithFileReferenceTypesAsStrings];

    if ([typeStrings objectForKey:self]) {
        return (XcodeSourceFileType) [[typeStrings objectForKey:self] intValue];
    }
    else {
        return FileTypeNil;
    }
}

/* ================================================== Private Methods =============================================== */



@end