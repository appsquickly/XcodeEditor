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


#import "xcode_ClassDefinition.h"

SPEC_BEGIN(ClassDefinitionSpec)

    __block ClassDefinition* classDefinition;

    describe(@"Object creation", ^{

        it(@"should allow initialization with a fileName attribute", ^{
            classDefinition = [[ClassDefinition alloc] initWithName:@"ESA_Sales_Browse_ViewController"];

            [classDefinition.className shouldNotBeNil];
            [[classDefinition.className should] equal:@"ESA_Sales_Browse_ViewController"];
            [[[NSNumber numberWithBool:[classDefinition isObjectiveC]] should] beYes];
        });

        it(@"should allow initialization with a filename and language attribute", ^{
            classDefinition =
                [[ClassDefinition alloc] initWithName:@"ESA_Sales_Browse_ViewController" language:ObjectiveCPlusPlus];
            [[[NSNumber numberWithBool:[classDefinition isObjectiveCPlusPlus]] should] beYes];
        });

        it(@"should throw an exception if one of the above languages is not specified", ^{
            @try {
                classDefinition =
                    [[ClassDefinition alloc] initWithName:@"ESA_Sales_Browse_ViewController" language:999];
                [NSException raise:@"Test fails." format:@"Expected exception to be thrown"];
            }
            @catch (NSException* e) {
                [[e.reason should] equal:@"Language must be one of ObjectiveC, ObjectiveCPlusPlus"];
            }
        });

    });

    describe(@"filenames", ^{

        it(@"should return the conventional file names for objective-c classes.", ^{
            classDefinition = [[ClassDefinition alloc] initWithName:@"MyClass" language:ObjectiveC];
            [[[classDefinition headerFileName] should] equal:@"MyClass.h"];
            [[[classDefinition sourceFileName] should] equal:@"MyClass.m"];
        });

        it(@"should return the conventional file names for objective-c++ classes", ^{
            classDefinition = [[ClassDefinition alloc] initWithName:@"MyClass" language:ObjectiveCPlusPlus];
            [[[classDefinition headerFileName] should] equal:@"MyClass.h"];
            [[[classDefinition sourceFileName] should] equal:@"MyClass.mm"];
        });

    });


    describe(@"Setting content", ^{

        beforeEach(^{
            classDefinition = [[ClassDefinition alloc] initWithName:@"ESA_Sales_Browse_ViewController"];
        });


        it(@"should allow setting language to Objective-C", ^{
            [classDefinition setHeader:@"@interface ESA_Sales_Browse_ViewController @end"];
            [[[classDefinition header] should] equal:@"@interface ESA_Sales_Browse_ViewController @end"];
        });

        it(@"should allow setting language to Objective-C", ^{
            [classDefinition setSource:@"@implementation ESA_Sales_Browse_ViewController @end"];
            [[[classDefinition source] should] equal:@"@implementation ESA_Sales_Browse_ViewController @end"];
        });

    });



    SPEC_END