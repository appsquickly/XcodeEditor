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
#import "XCSubProjectDefinition.h"

SPEC_BEGIN(SubProjectDefinitionSpec)


        __block XCProject* project;


        beforeEach(^{
            project = [[XCProject alloc] initWithFilePath:@"/tmp/expanz-iOS-SDK/expanz-iOS-SDK.xcodeproj"];
        });

/* ================================================================================================================== */
        describe(@"object creation", ^{

            it(@"should allow initialization with name, path, ", ^{

                XCSubProjectDefinition* subProjectDefinition = [[XCSubProjectDefinition alloc]
                        initWithName:@"HelloBoxy" path:@"/tmp/HelloBoxy" parentProject:project];

                [subProjectDefinition shouldNotBeNil];
                [[[subProjectDefinition projectFileName] should] equal:@"HelloBoxy.xcodeproj"];

            });


        });


        SPEC_END