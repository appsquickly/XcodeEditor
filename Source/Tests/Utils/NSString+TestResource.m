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
#import "NSString+TestResource.h"


@implementation NSString (TestResource)

+ (NSString*) stringWithTestResource:(NSString*)resourceName {
    NSString* filePath = [@"/tmp" stringByAppendingPathComponent:resourceName];
    NSError* error;
    NSString* contents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        [NSException raise:NSInvalidArgumentException format:@"No test resource named '%@'", filePath];
    }
    return contents;
}


@end