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
#import <SenTestingKit/SenTestingKit.h>

@interface XcodeFileReferenceTypeTests : SenTestCase
@end

@implementation XcodeFileReferenceTypeTests

- (void)test_return_a_file_reference_type_from_a_string
{

    assertThatInt(XCSourceFileTypeFromStringRepresentation(@"sourcecode.c.h"), equalTo(@(SourceCodeHeader)));
    assertThatInt(XCSourceFileTypeFromStringRepresentation(@"sourcecode.c.objc"), equalTo(@(SourceCodeObjC)));
}

- (void)test_creates_a_string_from_a_file_reference_type
{
    assertThat(NSStringFromXCSourceFileType(SourceCodeHeader), equalTo(@"sourcecode.c.h"));
    assertThat(NSStringFromXCSourceFileType(SourceCodeObjC), equalTo(@"sourcecode.c.objc"));
}

- (void)test_returns_file_type_from_file_name
{
    assertThatInt(XCSourceFileTypeFromFileName(@"foobar.c"), equalToInt(SourceCodeObjC));
    assertThatInt(XCSourceFileTypeFromFileName(@"foobar.m"), equalToInt(SourceCodeObjC));
    assertThatInt(XCSourceFileTypeFromFileName(@"foobar.mm"), equalToInt(SourceCodeObjCPlusPlus));
    assertThatInt(XCSourceFileTypeFromFileName(@"foobar.cpp"), equalToInt(SourceCodeCPlusPlus));
}

@end