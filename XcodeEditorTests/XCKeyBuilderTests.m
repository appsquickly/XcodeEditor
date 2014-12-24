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


#import <XCTest/XCTest.h>
#import "XCKeyBuilder.h"

@interface XCKeyBuilderTests : XCTestCase

@end

@implementation XCKeyBuilderTests

/* ====================================================================================================================================== */
#pragma mark - md5sum hash

- (void)test_returns_an_md5_hash_for_an_NSData_instance
{

    NSString* requiresKey = @"ESA_Sales_Customer_Browse_ViewController.h";

    XCKeyBuilder* builtKey = [XCKeyBuilder forItemNamed:requiresKey];
    NSString* key = [builtKey build];
    NSLog(@"Key: %@", key);
    XCTAssertNotNil(key);
    XCTAssertEqual(key.length, 24);
}


@end