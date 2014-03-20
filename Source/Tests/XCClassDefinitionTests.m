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

#import <SenTestingKit/SenTestingKit.h>
#import "XCClassDefinition.h"

@interface XCClassDefinitionTests : SenTestCase
@end

@implementation XCClassDefinitionTests
{
    XCClassDefinition* classDefinition;
}

/* ====================================================================================================================================== */
#pragma mark - Object creation



- (void)test_allows_initialization_with_a_fileName_attribute
{
    classDefinition = [[XCClassDefinition alloc] initWithName:@"ESA_Sales_Browse_ViewController"];

    assertThat(classDefinition.className, notNilValue());
    assertThat(classDefinition.className, equalTo(@"ESA_Sales_Browse_ViewController"));
    assertThatBool([classDefinition isObjectiveC], equalToBool(YES));
}

- (void)test_allow_initialization_with_a_filename_and_language_attribute
{
    classDefinition = [[XCClassDefinition alloc] initWithName:@"ESA_Sales_Browse_ViewController" language:ObjectiveCPlusPlus];
    assertThatBool([classDefinition isObjectiveCPlusPlus], equalToBool(YES));
}

- (void)test_it_throws_an_exception_if_one_of_the_above_languages_is_not_specified
{
    @try
    {
        classDefinition = [[XCClassDefinition alloc] initWithName:@"ESA_Sales_Browse_ViewController" language:999];
        [NSException raise:@"Test fails." format:@"Expected exception to be thrown"];
    }
    @catch (NSException* e)
    {
        assertThat([e reason], equalTo(@"Language must be one of ObjectiveC, ObjectiveCPlusPlus"));
    }
}


/* ====================================================================================================================================== */
#pragma mark - File-names


- (void)test_it_returns_the_conventional_file_names_for_objective_c_classes
{
    classDefinition = [[XCClassDefinition alloc] initWithName:@"MyClass" language:ObjectiveC];
    assertThat([classDefinition headerFileName], equalTo(@"MyClass.h"));
    assertThat([classDefinition sourceFileName], equalTo(@"MyClass.m"));
}

- (void)test_it_returns_the_conventional_file_names_for_objective_cPlusPlus_classes
{
    classDefinition = [[XCClassDefinition alloc] initWithName:@"MyClass" language:ObjectiveCPlusPlus];
    assertThat([classDefinition headerFileName], equalTo(@"MyClass.h"));
    assertThat([classDefinition sourceFileName], equalTo(@"MyClass.mm"));
}


@end