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

@interface TargetTests : SenTestCase
@end

@implementation TargetTests
{
    XCProject* _project;
    XCTarget* _target;
}


- (void)setUp
{
    _project = [[XCProject alloc] initWithFilePath:@"/tmp/expanz-iOS-SDK/expanz-iOS-SDK.xcodeproj"];
    LogDebug(@"Targets: %@", [_project targets]);
    _target = [_project targetWithName:@"Spring-OC"];
    LogDebug(@"Target: %@", _target);
}

/* ====================================================================================================================================== */
#pragma mark - Build configuraiton. . .


- (void)test_allows_listing_the_build_configuration
{
//    XCBuildConfiguration* configuration = [_target configurationWithName:@"Debug"];
//    LogDebug(@"Here's the configuration: %@", configuration);
//    id <NSCopying> ldFlags = [configuration valueForKey:@"OTHER_LDFLAGS"];
//    LogDebug(@"ldflags: %@, %@", ldFlags, [ldFlags class]);
//    [configuration addOrReplaceBuildSetting:@"-lz -lxml2" forKey:@"OTHER_LDFLAGS"];
//
//    configuration = [_target configurationWithName:@"Release"];
//    LogDebug(@"Here's the configuration: %@", configuration);
//    ldFlags = [configuration valueForKey:@"OTHER_LDFLAGS"];
//    LogDebug(@"ldflags: %@, %@", ldFlags, [ldFlags class]);
//    [configuration addOrReplaceBuildSetting:@"-lz -lxml2" forKey:@"OTHER_LDFLAGS"];
//
//    [_project save];

}


@end