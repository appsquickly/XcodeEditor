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

#import "XcodeProjectFileType.h"

SPEC_BEGIN(XCodeFileReferenceSpec)


    it(@"should return a file reference type from a string", ^{

        [[theValue([@"sourcecode.c.h" asProjectFileType]) should] equal:[NSNumber numberWithInt:SourceCodeHeader]];
        [[theValue([@"sourcecode.c.objc" asProjectFileType]) should] equal:[NSNumber numberWithInt:SourceCodeObjC]];
    });

    it(@"should create a string from a file reference type", ^{
        [[[NSString stringFromProjectFileType:SourceCodeHeader] should] equal:@"sourcecode.c.h"];
        [[[NSString stringFromProjectFileType:SourceCodeObjC] should] equal:@"sourcecode.c.objc"];
    });


SPEC_END