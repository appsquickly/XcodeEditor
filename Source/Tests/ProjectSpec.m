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

#import "xcode_Project.h"
#import "xcode_Target.h"
#import "xcode_Group.h"
#import "xcode_SourceFile.h"

SPEC_BEGIN(ProjectSpec)

        __block Project* project;

        beforeEach(^{
            project = [[Project alloc] initWithFilePath:@"/tmp"];
        });


        describe(@"Listing files files", ^{

            it(@"should be able to list all the header files in a project.", ^{

                NSArray* headerFiles = [project headerFiles];
                LogDebug(@"Headers: %@", headerFiles);

                [[theValue([headerFiles count]) should] equal:[NSNumber numberWithInt:18]];
                for (SourceFile* file in headerFiles) {
                    LogDebug(@"File: %@", [file description]);
                }

            });

            it(@"should be able to list all the obj-c files in a project", ^{

                NSArray* objcFiles = [project objectiveCFiles];
                LogDebug(@"Implementation Files: %@", objcFiles);

                [[theValue([objcFiles count]) should] equal:[NSNumber numberWithInt:21]];
            });

            it(@"should be able to list all the obj-c++ files in a project", ^{
                NSArray* objcPlusPlusFiles = [project objectiveCPlusPlusFiles];
                LogDebug(@"Implementation Files: %@", objcPlusPlusFiles);

                //TODO: Put an obj-c++ file in the test project.
                [[theValue([objcPlusPlusFiles count]) should] equal:[NSNumber numberWithInt:0]];
            });

            it(@"should be able to list all the xib files in a project", ^{

                NSArray* xibFiles = [project xibFiles];
                LogDebug(@"Xib Files: %@", xibFiles);

                [[theValue([xibFiles count]) should] equal:[NSNumber numberWithInt:2]];

            });
        });

        describe(@"Groups", ^{

            it(@"should be able to list all of the groups in a project", ^{
                NSArray* groups = [project groups];

                for (Group* group in groups) {
                    LogDebug(@"Name: %@, full path: %@", [group displayName], [group pathRelativeToProjectRoot]);
                    for (id<XcodeGroupMember> member  in [group members]) {
                        LogDebug(@"\t%@", [member displayName]);
                    }
                }

                [groups shouldNotBeNil];
                [[groups shouldNot] beEmpty];
            });

        });

        describe(@"Targets", ^{

            it(@"should be able to list the targets in an xcode project", ^{

                NSArray* targets = [project targets];
                for (Target* target in [project targets]) {
                    LogDebug(@"%@", target);
                }
                [targets shouldNotBeNil];
                [[targets shouldNot] beEmpty];

                for (Target* target in targets) {
                    NSArray* members = [target members];
                    LogDebug(@"Members: %@", members);
                }

            });
        });



        SPEC_END