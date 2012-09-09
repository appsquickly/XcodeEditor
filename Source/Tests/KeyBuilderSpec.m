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


#import "XCKeyBuilder.h"

SPEC_BEGIN(KeyBuilderSpec)


    describe(@"md5sum hash", ^{

        it(@"Should return an md5 hash for an NSData instnace.", ^{

            NSString* requiresKey = @"ESA_Sales_Customer_Browse_ViewController.h";

            XCKeyBuilder* builtKey = [XCKeyBuilder forItemNamed:requiresKey];
            NSString* key = [builtKey build];
            LogDebug(@"Key: %@", key);
            [key shouldNotBeNil];
            [[theValue(key.length) should] equal:[NSNumber numberWithInt:24]];
        });


    });


    SPEC_END