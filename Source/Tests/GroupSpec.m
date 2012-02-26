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

#import "xcode_Group.h"
#import "xcode_Project.h"
#import "xcode_ClassDefinition.h"
#import "xcode_File.h"
#import "xcode_Target.h"

SPEC_BEGIN(GroupSpec)

    __block Project* project;
    __block Group* group;

    beforeEach(^{
        project = [[Project alloc] initWithFilePath:@"/tmp/expanz-iOS-SDK/expanz-iOS-SDK.xcodeproj"];
        group = [project groupWithPath:@"Source/Main"];
        [group shouldNotBeNil];
    });

    describe(@"Object creation", ^{

        it(@"should allow initialization with ", ^{
            Group* group =
                [[Group alloc] initWithProject:project key:@"abcd1234" name:@"Main" path:@"Source/Main" children:nil];
            [group shouldNotBeNil];
            [[[group key] should] equal:@"abcd1234"];
            [[[group name] should] equal:@"Main"];
            [[[group path] should] equal:@"Source/Main"];
            [[[group children] should] beEmpty];
        });

        it(@"should be able to describe itself.", ^{
            [[[group description] should] equal:@"Group: name = Main, key=6B469FE914EF875900ED659C, path=Source/Main"];
        });

    });


    describe(@"Source files.", ^{

        it(@"should allow adding a source file.", ^{

            ClassDefinition* classDefinition = [[ClassDefinition alloc] initWithName:@"MyViewController"];

            [classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
            [classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];

            LogDebug(@"Class definition: %@", classDefinition);

            [group addClass:classDefinition];
            [project save];

            File* fileResource = [project fileWithName:@"MyViewController.m"];
            [fileResource shouldNotBeNil];
            [[[fileResource fullPath] should] equal:@"Source/Main/MyViewController.m"];

            Target* examples = [project targetWithName:@"Examples"];
            [examples shouldNotBeNil];
            [examples addMember:fileResource];

            fileResource = [project fileWithName:@"MyViewController.m"];
            [[theValue([fileResource isBuildFile]) should] beYes];

            [project save];
            LogDebug(@"Done");
        });

        it(@"should be able to provide a sorted list of it's children", ^{

            NSArray* children = [group children];
            LogDebug(@"Group children: %@", children);
            [[[[children objectAtIndex:0] name] should] equal:@"Core"];
            [[[[children objectAtIndex:4] name] should] equal:@"UserInterface"];

        });
    });


    SPEC_END