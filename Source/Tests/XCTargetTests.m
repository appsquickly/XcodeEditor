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
#import "XCProject.h"
#import "XCTarget.h"
#import "XCBuildConfiguration.h"

@interface XCTargetTests : SenTestCase
@end

@implementation XCTargetTests
{
    XCProject* _project;
}


- (void)setUp
{
    _project = [[XCProject alloc] initWithFilePath:@"/tmp/expanz-iOS-SDK/expanz-iOS-SDK.xcodeproj"];
    NSLog(@"Targets: %@", [_project targets]);
}

- (void)test_allows_setting_name_and_product_name_target_properties
{
    XCTarget* target = [_project targetWithName:@"expanzCore"];
    [target setName:@"foobar"];
    [target setProductName:@"foobar"];

    [_project save];
}


/* ====================================================================================================================================== */
#pragma mark - Build configuration. . .


- (void)test_allows_setting_build_configurations
{
    XCProject* project = [[XCProject alloc] initWithFilePath:@"/tmp/HelloBoxy/HelloBoxy.xcodeproj"];
    XCTarget* target = [project targetWithName:@"HelloBoxy"];

    XCBuildConfiguration* configuration = [target configurationWithName:@"Debug"];
    NSLog(@"Here's the configuration: %@", configuration);
    id <NSCopying> ldFlags = [configuration valueForKey:@"OTHER_LDFLAGS"];
    NSLog(@"ldflags: %@, %@", ldFlags, [ldFlags class]);
    [configuration addOrReplaceConfig:@"-lz -lxml2" forKey:@"OTHER_LDFLAGS"];

    configuration = [target configurationWithName:@"Release"];
    NSLog(@"Here's the configuration: %@", configuration);
    ldFlags = [configuration valueForKey:@"OTHER_LDFLAGS"];
    NSLog(@"ldflags: %@, %@", ldFlags, [ldFlags class]);
    [configuration addOrReplaceConfig:@"-lz -lxml2" forKey:@"OTHER_LDFLAGS"];

    [_project save];

}


@end