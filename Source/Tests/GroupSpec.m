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
#import "NSString+TestResource.h"
#import "xcode_FileResource.h"
#import "xcode_Target.h"
#import "NSString+TestResource.h"

SPEC_BEGIN(GroupSpec)

    __block Project* project;
    __block Group* group;

    beforeEach(^{
        project = [[Project alloc] initWithFilePath:@"/tmp"];
        group = [project groupWithPath:@"Main"];
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
            [[[group description] should] equal:@"Group: name = (null), key=6B783BCF14AD8D190087E522, path=Main"];
        });

    });


    describe(@"Source files.", ^{

        it(@"should allow adding a source file.", ^{

            ClassDefinition
                * classDefinition = [[ClassDefinition alloc] initWithName:@"ESA_Sales_Foobar_ViewController"];

            [classDefinition setHeader:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.header"]];
            [classDefinition setSource:[NSString stringWithTestResource:@"ESA_Sales_Foobar_ViewController.impl"]];

            LogDebug(@"Class definition: %@", classDefinition);

            [group addClass:classDefinition];
            [project save];

            LogDebug(@"Files: %@", [project files]);

            FileResource* fileResource = [project projectFileWithPath:@"ESA_Sales_Foobar_ViewController.m"];
            [fileResource shouldNotBeNil];

            Target* examples = [project targetWithName:@"Model-Object-Explorer"];
            [examples shouldNotBeNil];
            [examples addMember:fileResource];

            fileResource = [project projectFileWithPath:@"ESA_Sales_Foobar_ViewController.m"];
            [[[NSNumber numberWithBool:[fileResource isBuildFile]] should] beYes];

            [project save];
            LogDebug(@"Done");

        });
    });


    SPEC_END