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
    NSString *path = [home stringByAppendingString:@"/xcode-editor-tests"];
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

NSString *XCSample2FolderPath(void)
{
    return [XCTestResourcePath() stringByAppendingString:@"/HelloBoxy"];
}

NSString *XCSample2XcodeProjectPath(void)
{
    return [XCSample2FolderPath() stringByAppendingString:@"/HelloBoxy.xcodeproj"];
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
