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
#import "XCGroup.h"
#import "XCSubProjectDefinition.h"
#import "XCClassDefinition.h"
#import "XCSourceFile.h"
#import "XCXibDefinition.h"
#import "XCTarget.h"
#import "XCFrameworkDefinition.h"
#import "XCSourceFileDefinition.h"
#import "XCTestResourceUtils.h"

@interface XCFrameworkPath : NSObject
@end

@implementation XCFrameworkPath

static const NSString *SDK_PATH =
        @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.1.sdk";

+ (NSString *)eventKitUIPath
{
    return [SDK_PATH stringByAppendingPathComponent:@"/System/Library/Frameworks/EventKitUI.framework"];
}

+ (NSString *)coreMidiPath
{
    return [SDK_PATH stringByAppendingPathComponent:@"/System/Library/Frameworks/CoreMIDI.framework"];
}

@end

@interface XCGroupTests : XCTestCase
@end

@implementation XCGroupTests
{
    XCProject *_project;
    XCGroup *_group;
}


- (void)setUp
{
    _project = [[XCProject alloc] initWithFilePath:XCSample1XcodeProjectPath()];
    _group = [_project groupWithPathFromRoot:@"Source/Main"];
    XCTAssertNotNil(_group);
}

//-------------------------------------------------------------------------------------------
#pragma mark - Object creation
//-------------------------------------------------------------------------------------------


- (void)test_allows_initialization_with
{
    XCGroup *aGroup =
            [XCGroup groupWithProject:_project key:@"abcd1234" alias:@"Main" path:@"Source/Main" children:nil];

    XCTAssertNotNil(aGroup);
    XCTAssertEqualObjects([aGroup key], @"abcd1234");
    XCTAssertEqualObjects([aGroup alias], @"Main");
    XCTAssertEqualObjects([aGroup pathRelativeToParent], @"Source/Main");
    XCTAssertTrue([[aGroup members] count] == 0);
}



//-------------------------------------------------------------------------------------------
#pragma mark - Properties . . .
//-------------------------------------------------------------------------------------------


- (void)test_able_to_describe_itself
{
    XCTAssertEqualObjects([_group description], @"Group: displayName = Main, key=6B469FE914EF875900ED659C");
}

- (void)test_able_to_return_its_full_path_relative_to_the_project_base_directory
{
    NSLog(@"############Path: %@", [_group pathRelativeToProjectRoot]);
}

//-------------------------------------------------------------------------------------------
#pragma mark - Adding obj-c source files.
//-------------------------------------------------------------------------------------------

- (void)test_allows_adding_a_source_file
{

    XCClassDefinition *classDefinition = [XCClassDefinition classDefinitionWithName:@"MyViewController"];

    [classDefinition setHeader:NSStringWithXCTestResource(@"ESA_Sales_Foobar_ViewController.header")];
    [classDefinition setSource:NSStringWithXCTestResource(@"ESA_Sales_Foobar_ViewController.impl")];

    NSLog(@"Class definition: %@", classDefinition);

    [_group addClass:classDefinition];
    [_project save];

    XCSourceFile *fileResource = [_project fileWithName:@"MyViewController.m"];
    XCTAssertNotNil(fileResource);
    XCTAssertEqualObjects([fileResource pathRelativeToProjectRoot], @"Source/Main/MyViewController.m");

    XCTarget *examples = [_project targetWithName:@"Examples"];
    XCTAssertNotNil(examples);
    [examples addMember:fileResource];

    fileResource = [_project fileWithName:@"MyViewController.m"];
    XCTAssertTrue([fileResource isBuildFile]);

    [_project save];
    NSLog(@"Done adding source file.");
}

- (void)test_provides_a_convenience_method_to_add_a_source_file_and_specify_targets
{

    XCClassDefinition *classDefinition = [XCClassDefinition classDefinitionWithName:@"AnotherClassAdded"];

    [classDefinition setHeader:NSStringWithXCTestResource(@"ESA_Sales_Foobar_ViewController.header")];
    [classDefinition setSource:NSStringWithXCTestResource(@"ESA_Sales_Foobar_ViewController.impl")];

    [_group addClass:classDefinition toTargets:[_project targets]];
    [_project save];

}

- (void)test_returns_a_warning_if_an_existing_class_is_overwritten
{

    XCClassDefinition *classDefinition = [XCClassDefinition classDefinitionWithName:@"AddedTwice"];
    [classDefinition setHeader:NSStringWithXCTestResource(@"ESA_Sales_Foobar_ViewController.header")];
    [classDefinition setSource:NSStringWithXCTestResource(@"ESA_Sales_Foobar_ViewController.impl")];
    [_group addClass:classDefinition toTargets:[_project targets]];
    [_project save];

    classDefinition = [XCClassDefinition classDefinitionWithName:@"AddedTwice"];
    [classDefinition setHeader:NSStringWithXCTestResource(@"ESA_Sales_Foobar_ViewController.header")];
    [classDefinition setSource:NSStringWithXCTestResource(@"ESA_Sales_Foobar_ViewController.impl")];
    [_group addClass:classDefinition toTargets:[_project targets]];
    [_project save];

}

- (void)test_allows_creating_a_reference_only_without_writing_to_disk
{

    XCClassDefinition *classDefinition = [XCClassDefinition classDefinitionWithName:@"ClassWithoutSourceFileYet"];
    [classDefinition setFileOperationType:XCFileOperationTypeReferenceOnly];
    [_group addClass:classDefinition toTargets:[_project targets]];
    [_project save];

}




//-------------------------------------------------------------------------------------------
#pragma mark - adding objective-c++ files
//-------------------------------------------------------------------------------------------

- (void)test_allows_adding_files_of_type_obc_cPlusPlus
{

    XCProject *anotherProject = [XCProject projectWithFilePath:XCBox2dSampleProjectPath()];
    XCGroup *anotherGroup = [anotherProject groupWithPathFromRoot:@"Source"];

    XCClassDefinition *classDefinition =
            [XCClassDefinition classDefinitionWithName:@"HelloWorldLayer" language:ObjectiveCPlusPlus];

    [classDefinition setHeader:NSStringWithXCTestResource(@"HelloWorldLayer.header")];
    [classDefinition setSource:NSStringWithXCTestResource(@"HelloWorldLayer.impl")];

    [anotherGroup addClass:classDefinition toTargets:[anotherProject targets]];
    [anotherProject save];

}




//-------------------------------------------------------------------------------------------
#pragma mark - Adding CPP files
//-------------------------------------------------------------------------------------------

- (void)test__allows_using_a_class_definition_to_add_cpp_files
{

    XCProject *anotherProject = [XCProject projectWithFilePath:XCBox2dSampleProjectPath()];
    XCGroup *anotherGroup = [anotherProject groupWithPathFromRoot:@"Source"];

    XCClassDefinition *definition = [XCClassDefinition classDefinitionWithName:@"Person" language:CPlusPlus];
    [definition setSource:NSStringWithXCTestResource(@"Person.impl")];

    [anotherGroup addClass:definition toTargets:[anotherProject targets]];
    [anotherProject save];

}



//-------------------------------------------------------------------------------------------
#pragma mark - adding xib files.
//-------------------------------------------------------------------------------------------


- (void)test_should_allow_adding_a_xib_file
{

    NSString *xibText = NSStringWithXCTestResource(@"ESA.Sales.Foobar.xib");
    XCXibDefinition *xibDefinition = [XCXibDefinition xibDefinitionWithName:@"AddedXibFile" content:xibText];

    [_group addXib:xibDefinition];
    [_project save];

    XCSourceFile *xibFile = [_project fileWithName:@"AddedXibFile.xib"];
    XCTAssertNotNil(xibFile);

    XCTarget *examples = [_project targetWithName:@"Examples"];
    XCTAssertNotNil(examples);
    [examples addMember:xibFile];

    xibFile = [_project fileWithName:@"AddedXibFile.xib"];
    XCTAssertTrue([xibFile isBuildFile]);

    [_project save];
    NSLog(@"Done adding xib file.");

}

- (void)test_provides_a_convenience_method_to_add_a_xib_file_and_specify_targets
{

    NSString *xibText = NSStringWithXCTestResource(@"ESA.Sales.Foobar.xib");
    XCXibDefinition *xibDefinition = [XCXibDefinition xibDefinitionWithName:@"AnotherAddedXibFile" content:xibText];

    [_group addXib:xibDefinition toTargets:[_project targets]];
    [_project save];

}

//-------------------------------------------------------------------------------------------
- (void)test_provides_an_option_to_accept_the_existing_file_if_it_exists
//-------------------------------------------------------------------------------------------

{

    //    NSString* newXibText = @"Don't blow away my contents if I already exist";
    //    XCXibDefinition* xibDefinition = [XCXibDefinition xibDefinitionWithName:@"AddedXibFile" content:newXibText];
    //    [xibDefinition setFileOperationType:XCFileOperationTypeAcceptExisting];
    //
    //    [_group addXib:xibDefinition toTargets:[project targets]];
    //    [project save];
    //
    //    NSString* xibContent = NSStringWithXCTestResource(@"expanz-iOS-SDK/Source/Main/AddedXibFile.xib"];
    //    NSLog(@"Xib content: %@", xibContent);
    //    XCTAssertNotEqualObjects(xibContent, newXibText);

}


//-------------------------------------------------------------------------------------------
#pragma mark - adding frameworks
//-------------------------------------------------------------------------------------------

- (void)test_allows_adding_a_framework_on_the_system_volume
{

    XCFrameworkDefinition *frameworkDefinition =
            [XCFrameworkDefinition frameworkDefinitionWithFilePath:[XCFrameworkPath eventKitUIPath]
                                                 copyToDestination:NO];
    [_group addFramework:frameworkDefinition toTargets:[_project targets]];
    [_project save];

}

- (void)test_allows_adding_a_framework_copying_it_to_the_destination_folder
{
    XCFrameworkDefinition *frameworkDefinition =
            [XCFrameworkDefinition frameworkDefinitionWithFilePath:[XCFrameworkPath coreMidiPath]
                                                 copyToDestination:YES];
    [_group addFramework:frameworkDefinition toTargets:[_project targets]];
    [_project save];
}

//-------------------------------------------------------------------------------------------
#pragma mark - adding xcodeproj files
//-------------------------------------------------------------------------------------------

- (void)test_allows_adding_a_xcodeproj_file
{

    XCSubProjectDefinition *projectDefinition =
            [XCSubProjectDefinition withName:@"HelloBoxy" path:XCBox2dSampleContainingFolderPath()
                               parentProject:_project];

    [_group addSubProject:projectDefinition];
    [_project save];

}

- (void)test_provides_a_convenience_method_to_add_a_xcodeproj_file_and_specify_targets
{

    NSString *subProjectPath = [XCTestResourcePath() stringByAppendingString:@"/ArchiveProj"];
    XCSubProjectDefinition *xcodeprojDefinition =
            [XCSubProjectDefinition withName:@"ArchiveProj" path:subProjectPath parentProject:_project];

    [_group addSubProject:xcodeprojDefinition toTargets:[_project targets]];
    [_project save];

}

//-------------------------------------------------------------------------------------------
#pragma mark - removing xcodeproj files
//-------------------------------------------------------------------------------------------

- (void)test_allows_removing_an_xcodeproj_file
{

    //    XCSubProjectDefinition
    //            * xcodeprojDefinition = [XCSubProjectDefinition withName:@"HelloBoxy" path:@"/tmp/HelloBoxy" parentProject:project];
    //
    //    [_group removeSubProject:xcodeprojDefinition];
    //    [project save];

}


- (void)test_allows_removing_an_xcodeproj_file_and_specify_targets
{
    //    XCSubProjectDefinition
    //            * xcodeprojDefinition = [XCSubProjectDefinition withName:@"ArchiveProj" path:@"/tmp/ArchiveProj" parentProject:project];
    //
    //    [_group addSubProject:xcodeprojDefinition toTargets:[project targets]];
    //    [project save];
    //
    //
    //    xcodeprojDefinition = [XCSubProjectDefinition withName:@"ArchiveProj" path:@"/tmp/ArchiveProj" parentProject:project];
    //
    //    [_group removeSubProject:xcodeprojDefinition fromTargets:[project targets]];
    //
    //    [project save];

}



//-------------------------------------------------------------------------------------------
#pragma mark - Adding other types
//-------------------------------------------------------------------------------------------

- (void)test_allows_adding_a_group
{

    [_group addGroupWithPath:@"TestGroup"];
    [_project save];
}

- (void)test_should_allows_adding_a_header
{

    XCSourceFileDefinition *header = [[XCSourceFileDefinition alloc]
            initWithName:@"SomeHeader.h" text:@"@protocol Foobar<NSObject> @end" type:SourceCodeHeader];
    [_group addSourceFile:header];
    [_project save];

}

- (void)test_allows_adding_an_image_file
{

    NSData *resourceData = NSDataWithXCTestResource(@"goat-funny.png");
    XCSourceFileDefinition *sourceFileDefinition =
            [[XCSourceFileDefinition alloc] initWithName:@"MyImageFile.png" data:resourceData type:ImageResourcePNG];
    [_group addSourceFile:sourceFileDefinition];
    [_project save];

}


//-------------------------------------------------------------------------------------------
#pragma mark - Listing members
//-------------------------------------------------------------------------------------------


- (void)test_able_to_provide_a_sorted_list_of_its_children
{

    NSArray *children = [_group members];
    NSLog(@"Group children: %@", children);
    XCTAssertFalse([children count] == 0);

}


- (void)test_able_to_return_a_member_by_its_name
{
    XCGroup *anotherGroup = [_project groupWithPathFromRoot:@"Source/Main/Core/Model"];
    XCSourceFile *member = [anotherGroup memberWithDisplayName:@"expanz_model_AppSite.m"];
    XCTAssertNotNil(member);

}

- (void)test_able_to_list_all_of_its_members_recursively
{

    NSLog(@"Let's get recursive members!!!!");
    NSArray *recursiveMembers = [_group recursiveMembers];
    NSLog(@"$$$$$$$$$$$$$$$**********$*$*$*$*$*$* recursive members: %@", recursiveMembers);

}




//-------------------------------------------------------------------------------------------
#pragma mark - Deleting
//-------------------------------------------------------------------------------------------

- (void)test_allows_deleting_a_filesystem_group_optionally_deleting_also_the_contents
{

    XCGroup *aGroup = [_project groupWithPathFromRoot:@"Source/Main/UserInterface/Components"];

    NSArray *groups = [_project groups];
    NSLog(@"Groups now: %@", groups);

    [aGroup removeFromParentDeletingChildren:YES];
    [_project save];

    groups = [_project groups];
    NSLog(@"Groups now: %@", groups);

    XCGroup *deleted = [_project groupWithPathFromRoot:@"Source/Main/UserInterface/Components"];
    XCTAssertNil(deleted);

}

/**
 * It should not leave stale build phase files, etc.
 */
- (void)test_allows_deleting_a_group_after_adding_contents
{
    XCProject *project = [[XCProject alloc] initWithFilePath:XCMasterDetailProjectPath()];
    for (XCGroup *group in project.groups) {
        NSLog(@"Group: %@", group.pathRelativeToProjectRoot);
    }
    XCGroup *group = [project groupWithPathFromRoot:@"ProjectToEdit/GroupToDelete"];

    XCClassDefinition *classDefinition = [XCClassDefinition classDefinitionWithName:@"ClassCalledJanine"];

    [classDefinition setHeader:NSStringWithXCTestResource(@"ClassCalledJanine.h")];
    [classDefinition setSource:NSStringWithXCTestResource(@"ClassCalledJanine.m")];

    NSLog(@"Class definition: %@", classDefinition);

    [group addClass:classDefinition];
    [project save];

    XCSourceFile *fileResource = [project fileWithName:@"ClassCalledJanine.m"];
    XCTAssertNotNil(fileResource);

    XCTarget *target = [project targetWithName:@"ProjectToEdit"];
    XCTAssertNotNil(target);
    [target addMember:fileResource];

    fileResource = [project fileWithName:@"ClassCalledJanine.m"];
    XCTAssertTrue([fileResource isBuildFile]);

    [project save];
    NSLog(@"Done adding source file.");

    [group removeFromParentDeletingChildren:YES];
    [project save];
}


@end