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


@implementation NSDictionary (XProjectFileType)

+ (NSDictionary*) dictionaryWithFileReferenceTypesAsStrings {
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:SourceCodeHeader], @"sourcecode.c.h",
        [NSNumber numberWithInteger:SourceCodeObjC], @"sourcecode.c.objc",
        [NSNumber numberWithInteger:Framework], @"wrapper.framework", 
        [NSNumber numberWithInteger:PropertyList], @"text.plist.strings",
        nil];
}

@end

@implementation NSString (XProjectFileType)

+ (NSString*) stringFromProjectFileType:(XcodeProjectFileType)type {
    return [[[NSDictionary dictionaryWithFileReferenceTypesAsStrings]
        allKeysForObject:[NSNumber numberWithInteger:type]]
        objectAtIndex:0];
}


- (XcodeProjectFileType) asProjectFileType {
    NSDictionary* typeStrings = [NSDictionary dictionaryWithFileReferenceTypesAsStrings];

    if ([typeStrings objectForKey:self]) {
        return (XcodeProjectFileType) [[typeStrings objectForKey:self] intValue];
    }
    else {
        return FileReferenceTypeOther;
    }
}

/* ================================================== Private Methods =============================================== */



@end