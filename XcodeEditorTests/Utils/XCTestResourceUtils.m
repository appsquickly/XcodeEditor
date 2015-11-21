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

#import "XCTestResourceUtils.h"

NSString *XCTestResourcePath(void)
{
    NSString *home = NSHomeDirectory();
    NSString *path = [home stringByAppendingString:@"/xcode-editor-test-results"];
    return path;
}

NSString *XCSample1FolderPath(void)
{
    return [XCTestResourcePath() stringByAppendingString:@"/expanz-iOS-SDK"];
}

NSString *XCSample1XcodeProjectPath(void)
{
    return [XCSample1FolderPath() stringByAppendingString:@"/expanz-iOS-SDK.xcodeproj"];
}

NSString *XCBox2dSampleContainingFolderPath(void)
{
    return [XCTestResourcePath() stringByAppendingString:@"/HelloBoxy"];
}

NSString *XCBox2dSampleProjectPath(void)
{
    return [XCBox2dSampleContainingFolderPath() stringByAppendingString:@"/HelloBoxy.xcodeproj"];
}


NSString *XCMasterDetailContainerFolderPath(void)
{
    return [XCTestResourcePath() stringByAppendingString:@"/ProjectToEdit"];
}

NSString *XCMasterDetailProjectPath(void)
{
    return [XCMasterDetailContainerFolderPath() stringByAppendingString:@"/ProjectToEdit.xcodeproj"];
}

NSString *NSStringWithXCTestResource(NSString *resourceName)
{
    NSString *filePath = [XCTestResourcePath() stringByAppendingPathComponent:resourceName];
    NSError *error = nil;
    NSString *contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (!contents) {
        [NSException raise:NSInvalidArgumentException format:@"No test resource named '%@'", filePath];
    }
    return contents;
}


NSData *NSDataWithXCTestResource(NSString *resourceName)
{
    NSString *filePath = [XCTestResourcePath() stringByAppendingPathComponent:resourceName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (!data) {
        [NSException raise:NSInvalidArgumentException format:@"Expected data at path '%@'", filePath];
    }
    return data;
}
