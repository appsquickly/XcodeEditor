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

    assertThatInt([@"sourcecode.c.h" asSourceFileType], equalTo(@(SourceCodeHeader)));
    assertThatInt([@"sourcecode.c.objc" asSourceFileType], equalTo(@(SourceCodeObjC)));
}

- (void)test_creates_a_string_from_a_file_reference_type
{
    assertThat([NSString stringFromSourceFileType:SourceCodeHeader], equalTo(@"sourcecode.c.h"));
    assertThat([NSString stringFromSourceFileType:SourceCodeObjC], equalTo(@"sourcecode.c.objc"));
}


@end