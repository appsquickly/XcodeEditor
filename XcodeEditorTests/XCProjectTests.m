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
#import "XCSourceFile.h"
#import "XCTarget.h"
#import "XCGroup.h"
#import "XCTestResourceUtils.h"

@interface XCProjectTests : XCTestCase

@end

@implementation XCProjectTests
{
    __block XCProject *_project;
}

- (void)setUp
{
    _project = [[XCProject alloc] initWithFilePath:XCTestResourcePath()];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Listing files
//-------------------------------------------------------------------------------------------

- (void)test_able_to_list_all_the_header_files_in_a_project
{

    NSArray *headerFiles = [_project headerFiles];
    NSLog(@"Headers: %@", headerFiles);

    XCTAssertTrue([headerFiles count] == 18);
    for (XCSourceFile *file in headerFiles) {
        NSLog(@"File: %@", [file description]);
    }

}

- (void)test_able_to_list_all_the_obj_c_files_in_a_project
{

    NSArray *objcFiles = [_project objectiveCFiles];
    NSLog(@"Implementation Files: %@", objcFiles);

    XCTAssertTrue([objcFiles count] == 21);
}

- (void)test_able_to_list_all_the_obj_cPlusPlus_files_in_a_project
{
    NSArray *objcPlusPlusFiles = [_project objectiveCPlusPlusFiles];
    NSLog(@"Implementation Files: %@", objcPlusPlusFiles);

    //TODO: Put an obj-c++ file in the test project.
    XCTAssertTrue([objcPlusPlusFiles count] == 0);
}

- (void)test_be_able_to_list_all_the_xib_files_in_a_project
{

    NSArray *xibFiles = [_project xibFiles];
    NSLog(@"Xib Files: %@", xibFiles);
    XCTAssertTrue([xibFiles count] == 2);
}


//-------------------------------------------------------------------------------------------
#pragma mark - Groups
//-------------------------------------------------------------------------------------------

- (void)test_able_to_list_all_of_the_groups_in_a_project
{
    NSArray *groups = [_project groups];

    for (XCGroup *group in groups) {
        NSLog(@"Name: %@, full path: %@", [group displayName], [group pathRelativeToProjectRoot]);
        for (id <XcodeGroupMember> member  in [group members]) {
            NSLog(@"\t%@", [member displayName]);
        }
    }

    XCTAssertNotNil(groups);
    XCTAssertFalse([groups count] == 0);
}

- (void)test_provides_access_to_the_root_top_level_group
{

    XCGroup *rootGroup = [_project rootGroup];
    NSLog(@"Here the _group: %@", rootGroup);
    XCTAssertFalse([rootGroup.members count] == 0);
}

- (void)test_provides_a_way_to_locate_a_group_from_its_path_to_the_root_group
{

    XCGroup *group = [_project groupWithPathFromRoot:@"Source/Main/Assembly"];
    XCTAssertNotNil(group);
    NSLog(@"Group: %@", group);

}

- (void)test_allows_pruning_empty_groups
{
    XCProject *project = [XCProject projectWithFilePath:XCMasterDetailProjectPath()];
    XCTAssertNotNil([project groupWithDisplayName:@"AnEmptyGroup"]);
    XCTAssertNotNil([project groupWithDisplayName:@"AnEmptyGroupChild"]);
    XCTAssertNotNil([project groupWithDisplayName:@"AnEmptyGroupChildGroup"]);

    [project pruneEmptyGroups];
    [project save];

    XCTAssertNil([project groupWithDisplayName:@"AnEmptyGroup"]);
    XCTAssertNil([project groupWithDisplayName:@"AnEmptyGroupChild"]);
    XCTAssertNil([project groupWithDisplayName:@"AnEmptyGroupChildGroup"]);
}


//-------------------------------------------------------------------------------------------
#pragma mark - Targets
//-------------------------------------------------------------------------------------------

- (void)test_able_to_list_the_targets_in_an_xcode_project
{

    NSArray *targets = [_project targets];
    for (XCTarget *target in [_project targets]) {
        NSLog(@"%@", target);
    }
    XCTAssertNotNil(targets);
    XCTAssertFalse([targets count] == 0);

    for (XCTarget *target in targets) {
        NSArray *members = [target members];
        NSLog(@"Members: %@", members);
    }

}


@end