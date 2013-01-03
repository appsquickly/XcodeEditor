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




#import "XCProject.h"
#import "XCGroup.h"
#import "XCSubProjectDefinition.h"
#import "XCClassDefinition.h"
#import "XCSourceFile.h"
#import "XCTarget.h"
#import "XCBuildConfiguration.h"

SPEC_BEGIN(TargetSpec)

        __block XCProject* project;
        __block XCTarget* target;

        beforeEach(^
        {
            project = [[XCProject alloc] initWithFilePath:@"/tmp/expanz-iOS-SDK/expanz-iOS-SDK.xcodeproj"];
            LogDebug(@"Targets: %@", [project targets]);
            target = [project targetWithName:@"Spring-OC"];
            LogDebug(@"Target: %@", target);
        });


        describe(@"Build configuraiton. . .", ^
        {

            it(@"should allow listing the build configuration.", ^
            {
               XCBuildConfiguration* configuration = [target configurationWithName:@"Debug"];
               LogDebug(@"Here's the configuration: %@", configuration);
               id<NSCopying> ldFlags = [configuration valueForKey:@"OTHER_LDFLAGS"];
               LogDebug(@"ldflags: %@, %@", ldFlags, [ldFlags class]);
               [configuration addOrReplaceBuildSetting:@"-lz -lxml2" forKey:@"OTHER_LDFLAGS"];

                configuration = [target configurationWithName:@"Release"];
                LogDebug(@"Here's the configuration: %@", configuration);
                ldFlags = [configuration valueForKey:@"OTHER_LDFLAGS"];
                LogDebug(@"ldflags: %@, %@", ldFlags, [ldFlags class]);
                [configuration addOrReplaceBuildSetting:@"-lz -lxml2" forKey:@"OTHER_LDFLAGS"];

                [project save];

            });


        });



        SPEC_END