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

NSDictionary* NSDictionaryWithXCFileReferenceTypes()
{
    static NSDictionary* dictionary;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        dictionary = @{
            @"sourcecode.c.h"        : @(SourceCodeHeader),
            @"sourcecode.c.objc"     : @(SourceCodeObjC),
            @"wrapper.framework"     : @(Framework),
            @"text.plist.strings"    : @(PropertyList),
            @"sourcecode.cpp.objcpp" : @(SourceCodeObjCPlusPlus),
            @"sourcecode.cpp.cpp"    : @(SourceCodeCPlusPlus),
            @"file.xib"              : @(XibFile),
            @"image.png"             : @(ImageResourcePNG),
            @"wrapper.cfbundle"      : @(Bundle),
            @"archive.ar"            : @(Archive),
            @"text.html"             : @(HTML),
            @"text"                  : @(TEXT),
            @"wrapper.pb-project"    : @(XcodeProject)
        };
    });

    return dictionary;
}

NSString* NSStringFromXCSourceFileType(XcodeSourceFileType type)
{
    return [[NSDictionaryWithXCFileReferenceTypes() allKeysForObject:@(type)] objectAtIndex:0];
}

XcodeSourceFileType XCSourceFileTypeFromStringRepresentation(NSString* string)
{
    NSDictionary* typeStrings = NSDictionaryWithXCFileReferenceTypes();

    if ([typeStrings objectForKey:string])
    {
        return (XcodeSourceFileType) [[typeStrings objectForKey:string] intValue];
    }
    else
    {
        return FileTypeNil;
    }
}


XcodeSourceFileType XCSourceFileTypeFromFileName(NSString* fileName)
{
    if ([fileName hasSuffix:@".h"] || [fileName hasSuffix:@".hh"] || [fileName hasSuffix:@".hpp"] || [fileName hasSuffix:@".hxx"])
    {
        return SourceCodeHeader;
    }
    if ([fileName hasSuffix:@".c"] || [fileName hasSuffix:@".m"])
    {
        return SourceCodeObjC;
    }
    if ([fileName hasSuffix:@".mm"])
    {
        return SourceCodeObjCPlusPlus;
    }
    if ([fileName hasSuffix:@".cpp"])
    {
        return SourceCodeCPlusPlus;
    }
    return FileTypeNil;
}

