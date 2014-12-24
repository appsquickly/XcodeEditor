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
#import <XCTest/XCTest.h>

@interface XcodeFileReferenceTypeTests : XCTestCase
@end

@implementation XcodeFileReferenceTypeTests

- (void)test_return_a_file_reference_type_from_a_string
{

    XCTAssertTrue(XCSourceFileTypeFromStringRepresentation(@"sourcecode.c.h")  == SourceCodeHeader);
    XCTAssertTrue(XCSourceFileTypeFromStringRepresentation(@"sourcecode.c.objc") == SourceCodeObjC);
}

- (void)test_creates_a_string_from_a_file_reference_type
{
    XCTAssertEqualObjects(NSStringFromXCSourceFileType(SourceCodeHeader), @"sourcecode.c.h");
    XCTAssertEqualObjects(NSStringFromXCSourceFileType(SourceCodeObjC), @"sourcecode.c.objc");
}

- (void)test_returns_file_type_from_file_name
{
    XCTAssertEqual(XCSourceFileTypeFromFileName(@"foobar.c"), SourceCodeObjC);
    XCTAssertEqual(XCSourceFileTypeFromFileName(@"foobar.m"), SourceCodeObjC);
    XCTAssertEqual(XCSourceFileTypeFromFileName(@"foobar.mm"), SourceCodeObjCPlusPlus);
    XCTAssertEqual(XCSourceFileTypeFromFileName(@"foobar.cpp"), SourceCodeCPlusPlus);
}

@end