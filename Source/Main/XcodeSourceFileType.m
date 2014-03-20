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


@implementation NSDictionary (XcodeFileType)

+ (NSDictionary*)dictionaryWithFileReferenceTypesAsStrings
{
    return [NSDictionary dictionaryWithObjectsAndKeys:@(SourceCodeHeader),       @"sourcecode.c.h",
                                                      @(SourceCodeObjC),         @"sourcecode.c.objc",
                                                      @(Framework),              @"wrapper.framework",
                                                      @(PropertyList),           @"text.plist.strings",
                                                      @(SourceCodeObjCPlusPlus), @"sourcecode.cpp.objcpp",
                                                      @(SourceCodeCPlusPlus),    @"sourcecode.cpp.cpp", @(XibFile), @"file.xib",
                                                      @(ImageResourcePNG),       @"image.png", @(Bundle), @"wrapper.cfbundle",
                                                      @(Archive),                @"archive.ar", @(HTML), @"text.html",
                                                      @(TEXT),                   @"text",
                                                      @(XcodeProject),           @"wrapper.pb-project", nil];
}

@end

@implementation NSString (XcodeFileType)

+ (NSString*)stringFromSourceFileType:(XcodeSourceFileType)type
{
    return [[[NSDictionary dictionaryWithFileReferenceTypesAsStrings] allKeysForObject:@(type)] objectAtIndex:0];
}


- (XcodeSourceFileType)asSourceFileType
{
    NSDictionary* typeStrings = [NSDictionary dictionaryWithFileReferenceTypesAsStrings];

    if ([typeStrings objectForKey:self])
    {
        return (XcodeSourceFileType) [[typeStrings objectForKey:self] intValue];
    }
    else
    {
        return FileTypeNil;
    }
}


@end