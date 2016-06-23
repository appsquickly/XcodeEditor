//
//  XCBuildShellScriptTests.m
//  XcodeEditor
//
//  Created by Edward Poot on 23-06-16.
//  Copyright © 2016 appsquickly. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "XCTestResourceUtils.h"
#import "XCBuildShellScript.h"
#import "XCProject.h"

@interface XCBuildShellScriptTests : XCTestCase

@end

@implementation XCBuildShellScriptTests
{
    XCProject *_project;
}


- (void)setUp
{
       _project = [[XCProject alloc] initWithFilePath:XCTestResourcePath()];
}

- (void)test_emoji_in_name_is_correctly_removed_in_shell_scirpt
{
    NSString *stringWithEmoji = @"📦 Test";
    XCBuildShellScript *testBuildShellScriptDefinition =[XCBuildShellScript shellScriptWithProject:_project key:@"" name:stringWithEmoji files:@[] inputPaths:@[] outputPaths:@[] runOnlyForDeploymentPostprocessing:FALSE shellPath:@"" shellScript:@""];
    
    XCTAssertTrue([testBuildShellScriptDefinition.name isEqualToString:@" Test"]);
}

- (void)test_ordinary_name_not_altered_in_shell_script
{
    NSString *ordinaryName = @"Test build script";
    XCBuildShellScript *testBuildShellScriptDefinition =[XCBuildShellScript shellScriptWithProject:_project key:@"" name:ordinaryName files:@[] inputPaths:@[] outputPaths:@[] runOnlyForDeploymentPostprocessing:FALSE shellPath:@"" shellScript:@""];
    
    XCTAssertTrue([testBuildShellScriptDefinition.name isEqualToString:ordinaryName]);
}



@end
