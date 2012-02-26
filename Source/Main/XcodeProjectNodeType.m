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


#import "XcodeProjectNodeType.h"

@implementation NSDictionary (ProjectNodeType)

+ (NSDictionary*) dictionaryWithProjectNodeTypesAsStrings {
    return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:PBXNilType], @"PBXNilType",
                                                      [NSNumber numberWithInteger:PBXBuildFile], @"PBXBuildFile",
                                                      [NSNumber numberWithInteger:PBXContainerItemProxy],
                                                      @"PBXContainerItemProxy",
                                                      [NSNumber numberWithInteger:PBXCopyFilesBuildPhase],
                                                      @"PBXCopyFilesBuildPhase",
                                                      [NSNumber numberWithInteger:PBXFileReference],
                                                      @"PBXFileReference",
                                                      [NSNumber numberWithInteger:PBXFrameworksBuildPhase],
                                                      @"PBXFrameworksBuildPhase", [NSNumber numberWithInteger:PBXGroup],
                                                      @"PBXGroup", [NSNumber numberWithInteger:PBXNativeTarget],
                                                      @"PBXNativeTarget", [NSNumber numberWithInteger:PBXProject],
                                                      @"PBXProject",
                                                      [NSNumber numberWithInteger:PBXResourcesBuildPhase],
                                                      @"PBXResourcesBuildPhase",
                                                      [NSNumber numberWithInteger:PBXSourcesBuildPhase],
                                                      @"PBXSourcesBuildPhase",
                                                      [NSNumber numberWithInteger:PBXTargetDependency],
                                                      @"PBXTargetDependency",
                                                      [NSNumber numberWithInteger:PBXVariantGroup], @"PBXVariantGroup",
                                                      [NSNumber numberWithInteger:XCBuildConfiguration],
                                                      @"XCBuildConfiguration",
                                                      [NSNumber numberWithInteger:XCConfigurationList],
                                                      @"XCConfigurationList", nil];
}

@end

@implementation NSString (ProjectNodeType)

+ (NSString*) stringFromProjectNodeType:(XcodeProjectNodeType)nodeType {
    NSDictionary* nodeTypesToString = [NSDictionary dictionaryWithProjectNodeTypesAsStrings];
    return [[nodeTypesToString allKeysForObject:[NSNumber numberWithInt:nodeType]] objectAtIndex:0];
}


- (XcodeProjectNodeType) asProjectNodeType {
    NSDictionary* nodeTypesToString = [NSDictionary dictionaryWithProjectNodeTypesAsStrings];
    return (XcodeProjectNodeType) [[nodeTypesToString objectForKey:self] intValue];
}


@end