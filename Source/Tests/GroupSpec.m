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

#import "xcode_FrameworkDefinition.h"
#import "xcode_XibDefinition.h"
#import "xcode_Group.h"
#import "xcode_Project.h"
#import "xcode_ClassDefinition.h"
#import "xcode_SourceFile.h"
#import "xcode_Target.h"

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

        __block Project* project;
        __block Group* group;

        beforeEach(^{
            project = [[Project alloc] initWithFilePath:@"/tmp/expanz-iOS-SDK/expanz-iOS-SDK.xcodeproj"];
            group = [project groupWithPathRelativeToParent:@"Source/Main"];
            [group shouldNotBeNil];
        });

        describe(@"Object creation", ^{

            it(@"should allow initialization with ", ^{
                xcode_Group* group = [[xcode_Group alloc]
									  initWithProject:project key:@"abcd1234" alias:@"Main" path:@"Source/Main" tree:@"" children:nil];
                [group shouldNotBeNil];
                [[[group key] should] equal:@"abcd1234"];
                [[[group alias] should] equal:@"Main"];
                [[[group pathRelativeToParent] should] equal:@"Source/Main"];
                [[[group members] should] beEmpty];
            });


        });

        describe(@"Properties", ^{

            it(@"should be able to describe itself", ^{
                [[[group description] should] equal:@"Group: displayName = Main, key=6B469FE914EF875900ED659C"];
            });

            it(@"should be able to return its full path relative to the project base directory", ^{

                LogDebug(@"############Path: %@", [group pathRelativeToProjectRoot]);

            });

        });

        describe(@"Adding members.", ^{

            it(@"should allow adding a source file.", ^{

                ClassDefinition* classDefinition = [[ClassDefinition alloc] initWithName:@"MyViewController"];

                [classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
                [classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];

                LogDebug(@"Class definition: %@", classDefinition);

                [group addClass:classDefinition];
                [project save];

                SourceFile* fileResource = [project fileWithName:@"MyViewController.m"];
                [fileResource shouldNotBeNil];
                [[[fileResource pathRelativeToProjectRoot] should] equal:@"Source/Main/MyViewController.m"];

                Target* examples = [project targetWithName:@"Examples"];
                [examples shouldNotBeNil];
                [examples addMember:fileResource];

                fileResource = [project fileWithName:@"MyViewController.m"];
                [[theValue([fileResource isBuildFile]) should] beYes];

                [project save];
                LogDebug(@"Done adding source file.");
            });

            it(@"should provide a convenience method to add a source file, and specify targets", ^{

                ClassDefinition* classDefinition = [[ClassDefinition alloc] initWithName:@"AnotherClassAdded"];

                [classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
                [classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];

                [group addClass:classDefinition toTargets:[project targets]];
                [project save];

            });

            it(@"should return a warning if an existing class is overwritten", ^{

                ClassDefinition* classDefinition = [[ClassDefinition alloc] initWithName:@"AddedTwice"];
                [classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
                [classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];
                [group addClass:classDefinition toTargets:[project targets]];
                [project save];

                classDefinition = [[ClassDefinition alloc] initWithName:@"AddedTwice"];
                [classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
                [classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];
                [group addClass:classDefinition toTargets:[project targets]];
                [project save];


            });

            it(@"should allow adding a xib file.", ^{

                NSString* xibText = [NSString stringWithTestResource:@"ESA.Sales.Foobar.xib"];
                XibDefinition* xibDefinition = [[XibDefinition alloc] initWithName:@"AddedXibFile" content:xibText];

                [group addXib:xibDefinition];
                [project save];

                SourceFile* xibFile = [project fileWithName:@"AddedXibFile.xib"];
                [xibFile shouldNotBeNil];

                Target* examples = [project targetWithName:@"Examples"];
                [examples shouldNotBeNil];
                [examples addMember:xibFile];

                xibFile = [project fileWithName:@"AddedXibFile.xib"];
                [[theValue([xibFile isBuildFile]) should] beYes];

                [project save];
                LogDebug(@"Done adding xib file.");

            });

            it(@"should provide a convenience method to add a xib file, and specify targets", ^{

                NSString* xibText = [NSString stringWithTestResource:@"ESA.Sales.Foobar.xib"];
                XibDefinition
                        * xibDefinition = [[XibDefinition alloc] initWithName:@"AnotherAddedXibFile" content:xibText];

                [group addXib:xibDefinition toTargets:[project targets]];
                [project save];

            });

            it(@"should allow adding a framework on the system volume", ^{

                FrameworkDefinition* frameworkDefinition = [[FrameworkDefinition alloc]
                        initWithFilePath:[FrameworkPathFactory eventKitUIPath] copyToDestination:NO];
                [group addFramework:frameworkDefinition toTargets:[project targets]];
                [project save];

            });

            it(@"should allow adding a framework, copying it to the destination folder", ^{
                FrameworkDefinition* frameworkDefinition = [[FrameworkDefinition alloc]
                        initWithFilePath:[FrameworkPathFactory coreMidiPath] copyToDestination:YES];
                [group addFramework:frameworkDefinition toTargets:[project targets]];
                [project save];
            });

            it(@"should allow adding a group", ^{

                [group addGroupWithPath:@"TestGroup"];
                [project save];
            });

        });


        describe(@"Listing members", ^{
            it(@"should be able to provide a sorted list of it's children", ^{

                NSArray* children = [group members];
                LogDebug(@"Group children: %@", children);
                [[children should] haveCountOf:14];
                [[[[children objectAtIndex:0] displayName] should] equal:@"AddedTwice.h"];
                [[[[children objectAtIndex:13] displayName] should] equal:@"UserInterface"];

            });


            it(@"should be able to return a member by its name", ^{

                SourceFile* member = [group memberWithDisplayName:@"AnotherClassAdded.m"];
                [member shouldNotBeNil];

            });

        });


        describe(@"Deleting", ^{

            it(@"should allow deleting a group, optionally removing also the contents.", ^{

                Group* group = [project groupWithPathRelativeToParent:@"Tests"];
                [group shouldNotBeNil];

                [group removeFromSuperGroup:YES];
                [project save];

                Group* deleted = [project groupWithPathRelativeToParent:@"Tests"];
                [deleted shouldBeNil];

            });

        });


        SPEC_END