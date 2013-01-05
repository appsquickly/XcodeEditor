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
#import "XCSourceFile.h"
#import "XCTarget.h"
#import "XCGroup.h"

@interface ProjectTests : SenTestCase

@end

@implementation ProjectTests
{
    __block XCProject* project;
}

/* ====================================================================================================================================== */
- (void)setUp
{
    project = [[XCProject alloc] initWithFilePath:@"/tmp"];
}

/* ====================================================================================================================================== */
#pragma mark - Listing files

- (void)test_able_to_list_all_the_header_files_in_a_project
{

    NSArray* headerFiles = [project headerFiles];
    LogDebug(@"Headers: %@", headerFiles);

    assertThat(headerFiles, hasCountOf(18));
    for (XCSourceFile* file in headerFiles)
    {
        LogDebug(@"File: %@", [file description]);
    }

}

- (void)test_able_to_list_all_the_obj_c_files_in_a_project
{

    NSArray* objcFiles = [project objectiveCFiles];
    LogDebug(@"Implementation Files: %@", objcFiles);

    assertThat(objcFiles, hasCountOf(21));
}

- (void)test_able_to_list_all_the_obj_cPlusPlus_files_in_a_project
{
    NSArray* objcPlusPlusFiles = [project objectiveCPlusPlusFiles];
    LogDebug(@"Implementation Files: %@", objcPlusPlusFiles);

    //TODO: Put an obj-c++ file in the test project.
    assertThat(objcPlusPlusFiles, hasCountOf(0));
}

- (void)test_be_able_to_list_all_the_xib_files_in_a_project
{

    NSArray* xibFiles = [project xibFiles];
    LogDebug(@"Xib Files: %@", xibFiles);
    assertThat(xibFiles, hasCountOf(2));
}


/* ====================================================================================================================================== */
#pragma mark - Groups

- (void)test_able_to_list_all_of_the_groups_in_a_project
{
    NSArray* groups = [project groups];

    for (XCGroup* group in groups)
    {
        LogDebug(@"Name: %@, full path: %@", [group displayName], [group pathRelativeToProjectRoot]);
        for (id <XcodeGroupMember> member  in [group members])
        {
            LogDebug(@"\t%@", [member displayName]);
        }
    }

    assertThat(groups, notNilValue());
    assertThat(groups, isNot(empty()));
}

- (void)test_provides_access_to_the_root_top_level_group
{

    XCGroup* rootGroup = [project rootGroup];
    LogDebug(@"Here the group: %@", rootGroup);
    assertThat(rootGroup.members, isNot(empty()));



}

- (void)test_provides_a_way_to_locate_a_group_from_its_path_to_the_root_group
{

    XCGroup* group = [project groupWithPathFromRoot:@"Source/Main/Assembly"];
    assertThat(group, notNilValue());
    LogDebug(@"Group: %@", group);

}




/* ====================================================================================================================================== */
#pragma mark - Targets

- (void)test_able_to_list_the_targets_in_an_xcode_project
{

    NSArray* targets = [project targets];
    for (XCTarget* target in [project targets])
    {
        LogDebug(@"%@", target);
    }
    assertThat(targets, notNilValue());
    assertThat(targets, isNot(empty()));

    for (XCTarget* target in targets)
    {
        NSArray* members = [target members];
        LogDebug(@"Members: %@", members);
    }

}


@end