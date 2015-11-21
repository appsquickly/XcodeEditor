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
#import "XCProject.h"
#import "XCTarget.h"
#import "XCProjectBuildConfig.h"
#import "XCTestResourceUtils.h"

@interface XCTargetTests : XCTestCase
@end

@implementation XCTargetTests
{
    XCProject* _project;
}


- (void)setUp
{
    _project = [[XCProject alloc] initWithFilePath:XCSample1XcodeProjectPath()];
    NSLog(@"Targets: %@", [_project targets]);
}

- (void)test_allows_setting_name_and_product_name_target_properties
{
    XCTarget* target = [_project targetWithName:@"expanzCore"];
    [target setName:@"foobar"];
    [target setProductName:@"foobar"];

    [_project save];
}


//-------------------------------------------------------------------------------------------
#pragma mark - Build configuration. . .


- (void)test_allows_setting_build_configurations
{
    XCProject* project = [[XCProject alloc] initWithFilePath:XCBox2dSampleProjectPath()];
    XCTarget* target = [project targetWithName:@"HelloBoxy"];

    XCProjectBuildConfig * configuration = [target configurationWithName:@"Debug"];
    NSLog(@"Here's the configuration: %@", configuration);
    id ldFlags = [configuration valueForKey:@"OTHER_LDFLAGS"];
    NSLog(@"ldflags: %@, %@", ldFlags, [ldFlags class]);
    [configuration addOrReplaceSetting:@"-lz -lxml2" forKey:@"OTHER_LDFLAGS"];
    [configuration addOrReplaceSetting:@[@"foo", @"bar"] forKey:@"HEADER_SEARCH_PATHS"];



    configuration = [target configurationWithName:@"Release"];
    NSLog(@"Here's the configuration: %@", configuration);
    ldFlags = [configuration valueForKey:@"OTHER_LDFLAGS"];
    NSLog(@"ldflags: %@, %@", ldFlags, [ldFlags class]);
    [configuration addOrReplaceSetting:@"-lz -lxml2" forKey:@"OTHER_LDFLAGS"];
    [configuration addOrReplaceSetting:@[@"foo", @"bar"] forKey:@"HEADER_SEARCH_PATHS"];

    [project save];

}

//-------------------------------------------------------------------------------------------
#pragma mark - Duplication

- (void)test_allows_duplicating_a_target
{
    XCProject* project = [[XCProject alloc] initWithFilePath:XCBox2dSampleProjectPath()];
    XCTarget* target = [project targetWithName:@"HelloBoxy"];

    XCTarget* duplicated = [target duplicateWithTargetName:@"DuplicatedTarget" productName:@"NewProduct"];
    [project save];
}


@end