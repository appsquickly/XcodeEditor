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
    if ( DEBUG ) printf("Headers: %s\n", headerFiles.description.UTF8String);

    XCTAssertTrue([headerFiles count] == 18);
    for (XCSourceFile *file in headerFiles)
    {
        if ( DEBUG ) printf("File: %s\n", [file description].UTF8String);
    }

}

- (void)test_able_to_list_all_the_obj_c_files_in_a_project
{

    NSArray *objcFiles = [_project objectiveCFiles];
    if ( DEBUG ) printf("Implementation Files: %s\n", objcFiles.description.UTF8String);

    XCTAssertTrue([objcFiles count] == 21);
}

- (void)test_able_to_list_all_the_obj_cPlusPlus_files_in_a_project
{
    NSArray *objcPlusPlusFiles = [_project objectiveCPlusPlusFiles];
    if ( DEBUG ) printf("Implementation Files: %s\n", objcPlusPlusFiles.description.UTF8String);

    //TODO: Put an obj-c++ file in the test project.
    XCTAssertTrue([objcPlusPlusFiles count] == 0);
}

- (void)test_be_able_to_list_all_the_xib_files_in_a_project
{

    NSArray *xibFiles = [_project xibFiles];
    if ( DEBUG ) printf("Xib Files: %s\n", xibFiles.description.UTF8String);
    XCTAssertTrue([xibFiles count] == 2);
}


//-------------------------------------------------------------------------------------------
#pragma mark - Groups
//-------------------------------------------------------------------------------------------

- (void)test_able_to_list_all_of_the_groups_in_a_project
{
    NSArray *groups = [_project groups];

    for (XCGroup *group in groups)
    {
        if ( DEBUG ) printf("Name: %s, full path: %s\n", [group displayName].UTF8String, [group pathRelativeToProjectRoot].UTF8String);
        for (id <XcodeGroupMember> member  in [group members])
        {
            if ( DEBUG ) printf("\t%s\n", [member displayName].UTF8String);
        }
    }

    XCTAssertNotNil(groups);
    XCTAssertFalse([groups count] == 0);
}

- (void)test_provides_access_to_the_root_top_level_group
{

    XCGroup *rootGroup = [_project rootGroup];
    if ( DEBUG ) printf("Here the _group: %s\n", rootGroup.description.UTF8String);
    XCTAssertFalse([rootGroup.members count] == 0);
}

- (void)test_provides_a_way_to_locate_a_group_from_its_path_to_the_root_group
{

    XCGroup *group = [_project groupWithPathFromRoot:@"Source/Main/Assembly"];
    XCTAssertNotNil(group);
    if ( DEBUG ) printf("Group: %s\n", group.description.UTF8String);

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
    for (XCTarget *target in [_project targets])
    {
        if ( DEBUG ) printf("%s\n", target.description.UTF8String);
    }
    XCTAssertNotNil(targets);
    XCTAssertFalse([targets count] == 0);

    for (XCTarget *target in targets) {
        NSArray *members = [target members];
        if ( DEBUG ) printf("Members: %s\n", members.description.UTF8String);
    }

}


@end
