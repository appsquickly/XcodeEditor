////////////////////////////////////////////////////////////////////////////////
//
//  EXPANZ
//  Copyright 2008-2011 EXPANZ
//  All Rights Reserved.
//
//  NOTICE: Expanz permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

#import "XCProject.h"
#import "XCGroup.h"
#import "XCSubProjectDefinition.h"
#import "XCClassDefinition.h"
#import "XCSourceFile.h"
#import "XCXibDefinition.h"
#import "XCTarget.h"
#import "XCFrameworkDefinition.h"
#import "XCSourceFileDefinition.h"

@interface FrameworkPathFactory
@end

@implementation FrameworkPathFactory

static const NSString* SDK_PATH =
        @"/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.1.sdk";

+ (NSString*) eventKitUIPath {
    return [SDK_PATH stringByAppendingPathComponent:@"/System/Library/Frameworks/EventKitUI.framework"];
}

+ (NSString*) coreMidiPath {
    return [SDK_PATH stringByAppendingPathComponent:@"/System/Library/Frameworks/CoreMIDI.framework"];
}

@end


SPEC_BEGIN(GroupSpec)

        __block XCProject* project;
        __block XCGroup* group;

        beforeEach(^{
            project = [[XCProject alloc] initWithFilePath:@"/tmp/expanz-iOS-SDK/expanz-iOS-SDK.xcodeproj"];
            group = [project groupWithPathFromRoot:@"Source/Main"];
            [group shouldNotBeNil];
        });

/* ================================================================================================================== */
        describe(@"Object creation", ^{

            it(@"should allow initialization with ", ^{
                XCGroup* group =
                        [XCGroup groupWithProject:project key:@"abcd1234" alias:@"Main" path:@"Source/Main" children:nil];

                [group shouldNotBeNil];
                [[[group key] should] equal:@"abcd1234"];
                [[[group alias] should] equal:@"Main"];
                [[[group pathRelativeToParent] should] equal:@"Source/Main"];
                [[[group members] should] beEmpty];
            });


        });

/* ================================================================================================================== */
        describe(@"Properties", ^{

            it(@"should be able to describe itself", ^{
                [[[group description] should] equal:@"Group: displayName = Main, key=6B469FE914EF875900ED659C"];
            });

            it(@"should be able to return its full path relative to the project base directory", ^{

                LogDebug(@"############Path: %@", [group pathRelativeToProjectRoot]);

            });

        });

/* ================================================================================================================== */
        describe(@"Adding obj-c source files.", ^{

            it(@"should allow adding a source file.", ^{

                XCClassDefinition* classDefinition = [XCClassDefinition classDefinitionWithName:@"MyViewController"];

                [classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
                [classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];

                LogDebug(@"Class definition: %@", classDefinition);

                [group addClass:classDefinition];
                [project save];

                XCSourceFile* fileResource = [project fileWithName:@"MyViewController.m"];
                [fileResource shouldNotBeNil];
                [[[fileResource pathRelativeToProjectRoot] should] equal:@"Source/Main/MyViewController.m"];

                XCTarget* examples = [project targetWithName:@"Examples"];
                [examples shouldNotBeNil];
                [examples addMember:fileResource];

                fileResource = [project fileWithName:@"MyViewController.m"];
                [[theValue([fileResource isBuildFile]) should] beYes];

                [project save];
                LogDebug(@"Done adding source file.");
            });

            it(@"should provide a convenience method to add a source file, and specify targets", ^{

                XCClassDefinition* classDefinition = [XCClassDefinition classDefinitionWithName:@"AnotherClassAdded"];

                [classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
                [classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];

                [group addClass:classDefinition toTargets:[project targets]];
                [project save];

            });

            it(@"should return a warning if an existing class is overwritten", ^{

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

            });

            it(@"should allow creating a reference only, without writing to disk", ^{

                XCClassDefinition
                        * classDefinition = [XCClassDefinition classDefinitionWithName:@"ClassWithoutSourceFileYet"];
                [classDefinition setFileOperationStyle:FileOperationStyleReferenceOnly];
                [group addClass:classDefinition toTargets:[project targets]];
                [project save];

            });


        });

/* ================================================================================================================== */
        describe(@"adding objective-c++ files", ^{


            it(@"should allow adding files of type obc-c++", ^{

                XCProject* anotherProject = [XCProject projectWithFilePath:@"/tmp/HelloBoxy/HelloBoxy.xcodeproj"];
                XCGroup* anotherGroup = [anotherProject groupWithPathFromRoot:@"Source"];

                XCClassDefinition* classDefinition =
                        [XCClassDefinition classDefinitionWithName:@"HelloWorldLayer" language:ObjectiveCPlusPlus];

                [classDefinition setHeader:[NSString stringWithTestResource:@"HelloWorldLayer.header"]];
                [classDefinition setSource:[NSString stringWithTestResource:@"HelloWorldLayer.impl"]];

                [anotherGroup addClass:classDefinition toTargets:[anotherProject targets]];
                [anotherProject save];

            });

        });


/* ================================================================================================================== */
        describe(@"Adding CPP files", ^{

            it(@"should allow using a class definition to add cpp files", ^{

                XCProject* anotherProject = [XCProject projectWithFilePath:@"/tmp/HelloBoxy/HelloBoxy.xcodeproj"];
                XCGroup* anotherGroup = [anotherProject groupWithPathFromRoot:@"Source"];

                XCClassDefinition* definition = [XCClassDefinition classDefinitionWithName:@"Person" language:CPlusPlus];
                [definition setSource:[NSString stringWithTestResource:@"Person.impl"]];

                [anotherGroup addClass:definition toTargets:[anotherProject targets]];
                [anotherProject save];

            });


        });

/* ================================================================================================================== */
        describe(@"adding xib files.", ^{
            it(@"should allow adding a xib file.", ^{

                NSString* xibText = [NSString stringWithTestResource:@"ESA.Sales.Foobar.xib"];
                XCXibDefinition* xibDefinition = [XCXibDefinition xibDefinitionWithName:@"AddedXibFile" content:xibText];

                [group addXib:xibDefinition];
                [project save];

                XCSourceFile* xibFile = [project fileWithName:@"AddedXibFile.xib"];
                [xibFile shouldNotBeNil];

                XCTarget* examples = [project targetWithName:@"Examples"];
                [examples shouldNotBeNil];
                [examples addMember:xibFile];

                xibFile = [project fileWithName:@"AddedXibFile.xib"];
                [[theValue([xibFile isBuildFile]) should] beYes];

                [project save];
                LogDebug(@"Done adding xib file.");

            });

            it(@"should provide a convenience method to add a xib file, and specify targets", ^{

                NSString* xibText = [NSString stringWithTestResource:@"ESA.Sales.Foobar.xib"];
                XCXibDefinition
                        * xibDefinition = [XCXibDefinition xibDefinitionWithName:@"AnotherAddedXibFile" content:xibText];

                [group addXib:xibDefinition toTargets:[project targets]];
                [project save];

            });

            it(@"should provide an option to accept the existing file, if it exists.", ^{

                NSString* newXibText = @"Don't blow away my contents if I already exists";
                XCXibDefinition* xibDefinition = [XCXibDefinition xibDefinitionWithName:@"AddedXibFile" content:newXibText];
                [xibDefinition setFileOperationStyle:FileOperationStyleAcceptExisting];

                [group addXib:xibDefinition toTargets:[project targets]];
                [project save];

                NSString* xibContent = [NSString stringWithTestResource:@"expanz-iOS-SDK/Source/Main/AddedXibFile.xib"];
                LogDebug(@"Xib content: %@", xibContent);
                [[xibContent shouldNot] equal:newXibText];

            });

        });

/* ================================================================================================================== */
        describe(@"adding frameworks", ^{
            it(@"should allow adding a framework on the system volume", ^{

                XCFrameworkDefinition* frameworkDefinition =
                        [XCFrameworkDefinition frameworkDefinitionWithFilePath:[FrameworkPathFactory eventKitUIPath]
                                copyToDestination:NO];
                [group addFramework:frameworkDefinition toTargets:[project targets]];
                [project save];

            });

            it(@"should allow adding a framework, copying it to the destination folder", ^{
                XCFrameworkDefinition* frameworkDefinition =
                        [XCFrameworkDefinition frameworkDefinitionWithFilePath:[FrameworkPathFactory coreMidiPath]
                                copyToDestination:YES];
                [group addFramework:frameworkDefinition toTargets:[project targets]];
                [project save];
            });

        });

/* ================================================================================================================== */
        describe(@"adding xcodeproj files", ^{
            it(@"should allow adding a xcodeproj file", ^{

                XCSubProjectDefinition* projectDefinition =
                        [XCSubProjectDefinition withName:@"HelloBoxy" path:@"/tmp/HelloBoxy"
                                parentProject:project];

                [group addSubProject:projectDefinition];
                [project save];

            });

            it(@"should provide a convenience method to add a xcodeproj file, and specify targets", ^{

                XCSubProjectDefinition* xcodeprojDefinition =
                        [XCSubProjectDefinition withName:@"ArchiveProj" path:@"/tmp/ArchiveProj"
                                parentProject:project];

                [group addSubProject:xcodeprojDefinition toTargets:[project targets]];
                [project save];

            });

        });

        describe(@"removing xcodeproj files", ^{

            it(@"should allow removing a xcodeproj file", ^{

                XCSubProjectDefinition* xcodeprojDefinition =
                        [XCSubProjectDefinition withName:@"HelloBoxy" path:@"/tmp/HelloBoxy"
                                parentProject:project];

                [group removeSubProject:xcodeprojDefinition];
                [project save];

            });


            it(@"should allow removing a xcodeproj file, and specify targets", ^{

                XCSubProjectDefinition* xcodeprojDefinition =
                        [XCSubProjectDefinition withName:@"ArchiveProj" path:@"/tmp/ArchiveProj"
                                parentProject:project];

                [group removeSubProject:xcodeprojDefinition fromTargets:[project targets]];

                [project save];

            });

        });



/* ================================================================================================================== */
        describe(@"Adding other types", ^{

            it(@"should allow adding a group", ^{

                [group addGroupWithPath:@"TestGroup"];
                [project save];
            });

            it(@"should allow adding a header", ^{

                XCSourceFileDefinition* header = [[XCSourceFileDefinition alloc]
                        initWithName:@"SomeHeader.h" text:@"@protocol Foobar<NSObject> @end" type:SourceCodeHeader];
                [group addSourceFile:header];
                [project save];

            });

            it(@"should allow adding an image file", ^{

                XCSourceFileDefinition* sourceFileDefinition = [[XCSourceFileDefinition alloc]
                        initWithName:@"MyImageFile.png" data:[NSData dataWithContentsOfFile:@"/tmp/goat-funny.png"]
                        type:ImageResourcePNG];
                [group addSourceFile:sourceFileDefinition];
                [project save];

            });


        });

/* ================================================================================================================== */
        describe(@"Listing members", ^{
            it(@"should be able to provide a sorted list of it's children", ^{

                NSArray* children = [group members];
                LogDebug(@"Group children: %@", children);
                [[children should] haveCountOf:18];
                [[[[children objectAtIndex:0] displayName] should] equal:@"AddedTwice.h"];
                [[[[children objectAtIndex:17] displayName] should] equal:@"UserInterface"];

            });


            it(@"should be able to return a member by its name", ^{

                XCSourceFile* member = [group memberWithDisplayName:@"AnotherClassAdded.m"];
                [member shouldNotBeNil];

            });

            it(@"should be able to list all of it's members recursively.", ^{

                LogDebug(@"Let's get recursive members!!!!");
                NSArray* recursiveMembers = [group recursiveMembers];
                LogDebug(@"$$$$$$$$$$$$$$$**********$*$*$*$*$*$* recursive members: %@", recursiveMembers);

            });


        });

/* ================================================================================================================== */
        describe(@"Deleting", ^{

            it(@"should allow deleting a group, optionally removing also the contents.", ^{

                XCGroup* group = [project groupWithPathFromRoot:@"Tests"];
                [group shouldNotBeNil];

                [group removeFromParentGroup:YES];
                [project save];

                XCGroup* deleted = [project groupWithPathFromRoot:@"Tests"];
                [deleted shouldBeNil];

            });

        });


        SPEC_END