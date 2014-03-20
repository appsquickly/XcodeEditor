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
#import "XCGroup.h"
#import "XCSubProjectDefinition.h"
#import "XCClassDefinition.h"
#import "XCSourceFile.h"
#import "XCXibDefinition.h"
#import "XCTarget.h"
#import "XCFrameworkDefinition.h"
#import "XCSourceFileDefinition.h"

@interface XCFrameworkPath : NSObject
@end

@implementation XCFrameworkPath

static const NSString* SDK_PATH = @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS7.1.sdk";

+ (NSString*)eventKitUIPath
{
    return [SDK_PATH stringByAppendingPathComponent:@"/System/Library/Frameworks/EventKitUI.framework"];
}

+ (NSString*)coreMidiPath
{
    return [SDK_PATH stringByAppendingPathComponent:@"/System/Library/Frameworks/CoreMIDI.framework"];
}

@end

@interface XCGroupTests : SenTestCase
@end

@implementation XCGroupTests
{
    XCProject* project;
    XCGroup* group;
}


- (void)setUp
{
    project = [[XCProject alloc] initWithFilePath:@"/tmp/expanz-iOS-SDK/expanz-iOS-SDK.xcodeproj"];
    group = [project groupWithPathFromRoot:@"Source/Main"];
    assertThat(group, notNilValue());
}

/* ================================================================================================================== */
#pragma mark - Object creation

- (void)test_allows_initialization_with
{
    XCGroup* aGroup = [XCGroup groupWithProject:project key:@"abcd1234" alias:@"Main" path:@"Source/Main" children:nil];

    assertThat(aGroup, notNilValue());
    assertThat([aGroup key], equalTo(@"abcd1234"));
    assertThat([aGroup alias], equalTo(@"Main"));
    assertThat([aGroup pathRelativeToParent], equalTo(@"Source/Main"));
    assertThat([aGroup members], empty());
}



/* ================================================================================================================== */
#pragma mark - Properties . . . 

- (void)test_able_to_describe_itself
{
    assertThat([group description], equalTo(@"Group: displayName = Main, key=6B469FE914EF875900ED659C"));
}

- (void)test_able_to_return_its_full_path_relative_to_the_project_base_directory
{
    NSLog(@"############Path: %@", [group pathRelativeToProjectRoot]);
}

/* ================================================================================================================== */
#pragma mark - Adding obj-c source files.

- (void)test_allows_adding_a_source_file
{

    XCClassDefinition* classDefinition = [XCClassDefinition classDefinitionWithName:@"MyViewController"];

    [classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
    [classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];

    NSLog(@"Class definition: %@", classDefinition);

    [group addClass:classDefinition];
    [project save];

    XCSourceFile* fileResource = [project fileWithName:@"MyViewController.m"];
    assertThat(fileResource, notNilValue());
    assertThat([fileResource pathRelativeToProjectRoot], equalTo(@"Source/Main/MyViewController.m"));

    XCTarget* examples = [project targetWithName:@"Examples"];
    assertThat(examples, notNilValue());
    [examples addMember:fileResource];

    fileResource = [project fileWithName:@"MyViewController.m"];
    assertThatBool([fileResource isBuildFile], equalToBool(YES));

    [project save];
    NSLog(@"Done adding source file.");
}

- (void)test_provides_a_convenience_method_to_add_a_source_file_and_specify_targets
{

    XCClassDefinition* classDefinition = [XCClassDefinition classDefinitionWithName:@"AnotherClassAdded"];

    [classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
    [classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];

    [group addClass:classDefinition toTargets:[project targets]];
    [project save];

}

- (void)test_returns_a_warning_if_an_existing_class_is_overwritten
{

    XCClassDefinition* classDefinition = [XCClassDefinition classDefinitionWithName:@"AddedTwice"];
    [classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
    [classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];
    [group addClass:classDefinition toTargets:[project targets]];
    [project save];

    classDefinition = [XCClassDefinition classDefinitionWithName:@"AddedTwice"];
    [classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
    [classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];
    [group addClass:classDefinition toTargets:[project targets]];
    [project save];

}

- (void)test_allows_creating_a_reference_only_without_writing_to_disk
{

    XCClassDefinition* classDefinition = [XCClassDefinition classDefinitionWithName:@"ClassWithoutSourceFileYet"];
    [classDefinition setFileOperationType:XCFileOperationTypeReferenceOnly];
    [group addClass:classDefinition toTargets:[project targets]];
    [project save];

}




/* ================================================================================================================== */
#pragma mark - adding objective-c++ files


- (void)test_allows_adding_files_of_type_obc_cPlusPlus
{

    XCProject* anotherProject = [XCProject projectWithFilePath:@"/tmp/HelloBoxy/HelloBoxy.xcodeproj"];
    XCGroup* anotherGroup = [anotherProject groupWithPathFromRoot:@"Source"];

    XCClassDefinition* classDefinition = [XCClassDefinition classDefinitionWithName:@"HelloWorldLayer" language:ObjectiveCPlusPlus];

    [classDefinition setHeader:[NSString stringWithTestResource:@"HelloWorldLayer.header"]];
    [classDefinition setSource:[NSString stringWithTestResource:@"HelloWorldLayer.impl"]];

    [anotherGroup addClass:classDefinition toTargets:[anotherProject targets]];
    [anotherProject save];

}




/* ================================================================================================================== */
#pragma mark - Adding CPP files

- (void)test__allows_using_a_class_definition_to_add_cpp_files
{

    XCProject* anotherProject = [XCProject projectWithFilePath:@"/tmp/HelloBoxy/HelloBoxy.xcodeproj"];
    XCGroup* anotherGroup = [anotherProject groupWithPathFromRoot:@"Source"];

    XCClassDefinition* definition = [XCClassDefinition classDefinitionWithName:@"Person" language:CPlusPlus];
    [definition setSource:[NSString stringWithTestResource:@"Person.impl"]];

    [anotherGroup addClass:definition toTargets:[anotherProject targets]];
    [anotherProject save];

}



/* ================================================================================================================== */
#pragma mark - adding xib files.

- (void)test_should_allow_adding_a_xib_file
{

    NSString* xibText = [NSString stringWithTestResource:@"ESA.Sales.Foobar.xib"];
    XCXibDefinition* xibDefinition = [XCXibDefinition xibDefinitionWithName:@"AddedXibFile" content:xibText];

    [group addXib:xibDefinition];
    [project save];

    XCSourceFile* xibFile = [project fileWithName:@"AddedXibFile.xib"];
    assertThat(xibFile, notNilValue());

    XCTarget* examples = [project targetWithName:@"Examples"];
    assertThat(examples, notNilValue());
    [examples addMember:xibFile];

    xibFile = [project fileWithName:@"AddedXibFile.xib"];
    assertThatBool([xibFile isBuildFile], equalToBool(YES));

    [project save];
    NSLog(@"Done adding xib file.");

}

- (void)test_provides_a_convenience_method_to_add_a_xib_file_and_specify_targets
{

    NSString* xibText = [NSString stringWithTestResource:@"ESA.Sales.Foobar.xib"];
    XCXibDefinition* xibDefinition = [XCXibDefinition xibDefinitionWithName:@"AnotherAddedXibFile" content:xibText];

    [group addXib:xibDefinition toTargets:[project targets]];
    [project save];

}

- (void)test_provides_an_option_to_accept_the_existing_file_if_it_exists
{

    NSString* newXibText = @"Don't blow away my contents if I already exists";
    XCXibDefinition* xibDefinition = [XCXibDefinition xibDefinitionWithName:@"AddedXibFile" content:newXibText];
    [xibDefinition setFileOperationType:XCFileOperationTypeAcceptExisting];

    [group addXib:xibDefinition toTargets:[project targets]];
    [project save];

    NSString* xibContent = [NSString stringWithTestResource:@"expanz-iOS-SDK/Source/Main/AddedXibFile.xib"];
    NSLog(@"Xib content: %@", xibContent);
    assertThat(xibContent, isNot(equalTo(newXibText)));

}


/* ================================================================================================================== */
#pragma mark - adding frameworks

- (void)test_allows_adding_a_framework_on_the_system_volume
{

    XCFrameworkDefinition* frameworkDefinition =
        [XCFrameworkDefinition frameworkDefinitionWithFilePath:[XCFrameworkPath eventKitUIPath] copyToDestination:NO];
    [group addFramework:frameworkDefinition toTargets:[project targets]];
    [project save];

}

- (void)test_allows_adding_a_framework_copying_it_to_the_destination_folder
{
    XCFrameworkDefinition* frameworkDefinition =
        [XCFrameworkDefinition frameworkDefinitionWithFilePath:[XCFrameworkPath coreMidiPath] copyToDestination:YES];
    [group addFramework:frameworkDefinition toTargets:[project targets]];
    [project save];
}

/* ================================================================================================================== */
#pragma mark - adding xcodeproj files

- (void)test_allows_adding_a_xcodeproj_file
{

    XCSubProjectDefinition* projectDefinition = [XCSubProjectDefinition withName:@"HelloBoxy" path:@"/tmp/HelloBoxy" parentProject:project];

    [group addSubProject:projectDefinition];
    [project save];

}

- (void)test_provides_a_convenience_method_to_add_a_xcodeproj_file_and_specify_targets
{

    XCSubProjectDefinition
        * xcodeprojDefinition = [XCSubProjectDefinition withName:@"ArchiveProj" path:@"/tmp/ArchiveProj" parentProject:project];

    [group addSubProject:xcodeprojDefinition toTargets:[project targets]];
    [project save];

}



#pragma mark - removing xcodeproj files

- (void)test_allows_removing_an_xcodeproj_file
{

//    XCSubProjectDefinition
//            * xcodeprojDefinition = [XCSubProjectDefinition withName:@"HelloBoxy" path:@"/tmp/HelloBoxy" parentProject:project];
//
//    [group removeSubProject:xcodeprojDefinition];
//    [project save];

}


- (void)test_allows_removing_an_xcodeproj_file_and_specify_targets
{
//    XCSubProjectDefinition
//            * xcodeprojDefinition = [XCSubProjectDefinition withName:@"ArchiveProj" path:@"/tmp/ArchiveProj" parentProject:project];
//
//    [group addSubProject:xcodeprojDefinition toTargets:[project targets]];
//    [project save];
//
//
//    xcodeprojDefinition = [XCSubProjectDefinition withName:@"ArchiveProj" path:@"/tmp/ArchiveProj" parentProject:project];
//
//    [group removeSubProject:xcodeprojDefinition fromTargets:[project targets]];
//
//    [project save];

}



/* ================================================================================================================== */
#pragma mark - Adding other types

- (void)test_allows_adding_a_group
{

    [group addGroupWithPath:@"TestGroup"];
    [project save];
}

- (void)test_should_allows_adding_a_header
{

    XCSourceFileDefinition* header =
        [[XCSourceFileDefinition alloc] initWithName:@"SomeHeader.h" text:@"@protocol Foobar<NSObject> @end" type:SourceCodeHeader];
    [group addSourceFile:header];
    [project save];

}

- (void)test_allows_adding_an_image_file
{

    XCSourceFileDefinition* sourceFileDefinition = [[XCSourceFileDefinition alloc]
        initWithName:@"MyImageFile.png" data:[NSData dataWithContentsOfFile:@"/tmp/goat-funny.png"] type:ImageResourcePNG];
    [group addSourceFile:sourceFileDefinition];
    [project save];

}


/* ================================================================================================================== */
#pragma mark - Listing members
- (void)test_able_to_provide_a_sorted_list_of_its_children
{

    NSArray* children = [group members];
    NSLog(@"Group children: %@", children);
    assertThat(children, isNot(empty()));

}


- (void)test_able_to_return_a_member_by_its_name
{
    XCGroup* anotherGroup = [project groupWithPathFromRoot:@"Source/Main/Core/Model"];
    XCSourceFile* member = [anotherGroup memberWithDisplayName:@"expanz_model_AppSite.m"];
    assertThat(member, notNilValue());

}

- (void)test_able_to_list_all_of_its_members_recursively
{

    NSLog(@"Let's get recursive members!!!!");
    NSArray* recursiveMembers = [group recursiveMembers];
    NSLog(@"$$$$$$$$$$$$$$$**********$*$*$*$*$*$* recursive members: %@", recursiveMembers);

}




/* ================================================================================================================== */
#pragma mark - Deleting

- (void)test_allows_deleting_a_group_optionally_removing_also_the_contents
{

    XCGroup* aGroup = [project groupWithPathFromRoot:@"Source/Main/UserInterface/Components"];

    NSArray* groups = [project groups];
    NSLog(@"Groups now: %@", groups);

    [aGroup removeFromParentDeletingChildren:YES];
    [project save];

    groups = [project groups];
    NSLog(@"Groups now: %@", groups);

    XCGroup* deleted = [project groupWithPathFromRoot:@"Source/Main/UserInterface/Components"];
    assertThat(deleted, nilValue());

}


@end