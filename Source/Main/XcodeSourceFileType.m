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



#import "XcodeSourceFileType.h"
#import "Utils/XCEnumUtils.h"


@implementation NSDictionary (XcodeFileType)

+ (NSDictionary*) dictionaryWithFileReferenceTypesAsStrings {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            boxEnum(SourceCodeHeader), @"sourcecode.c.h",
			boxEnum(SourceCodeObjC), @"sourcecode.c.objc",
			boxEnum(Framework), @"wrapper.framework",
			boxEnum(PropertyList), @"text.plist.strings",
			boxEnum(SourceCodeObjCPlusPlus), @"sourcecode.cpp.objcpp",
            boxEnum(SourceCodeCPlusPlus), @"sourcecode.cpp.cpp",
			boxEnum(XibFile), @"file.xib",
			boxEnum(ImageResourcePNG), @"image.png",
            boxEnum(Bundle), @"wrapper.cfbundle",
            boxEnum(Archive), @"archive.ar",
            boxEnum(HTML), @"text.html",
            boxEnum(TEXT), @"text",
            boxEnum(XcodeProject), @"wrapper.pb-project",
			nil];
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