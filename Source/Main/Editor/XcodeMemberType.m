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


#import "XcodeMemberType.h"
#import "xcode_utils_Enum.h"

@implementation NSDictionary (XcodeMemberType)

+ (NSDictionary*) dictionaryWithProjectNodeTypesAsStrings {
    return [NSDictionary dictionaryWithObjectsAndKeys:boxEnum(PBXNilType), @"PBXNilType",
                                                      boxEnum(PBXBuildFile), @"PBXBuildFile",
                                                      boxEnum(PBXContainerItemProxy), @"PBXContainerItemProxy",
                                                      boxEnum(PBXCopyFilesBuildPhase), @"PBXCopyFilesBuildPhase",
                                                      boxEnum(PBXFileReference), @"PBXFileReference",
                                                      boxEnum(PBXFrameworksBuildPhase), @"PBXFrameworksBuildPhase",
                                                      boxEnum(PBXGroup), @"PBXGroup",
                                                      boxEnum(PBXNativeTarget), @"PBXNativeTarget",
                                                      boxEnum(PBXProject), @"PBXProject",
                                                      boxEnum(PBXResourcesBuildPhase), @"PBXResourcesBuildPhase",
                                                      boxEnum(PBXSourcesBuildPhase), @"PBXSourcesBuildPhase",
                                                      boxEnum(PBXTargetDependency), @"PBXTargetDependency",
                                                      boxEnum(PBXVariantGroup), @"PBXVariantGroup",
                                                      boxEnum(XCBuildConfiguration), @"XCBuildConfiguration",
                                                      boxEnum(XCConfigurationList), @"XCConfigurationList", nil];
}

@end

@implementation NSString (ProjectNodeType)

+ (NSString*) stringFromMemberType:(XcodeMemberType)nodeType {
    NSDictionary* nodeTypesToString = [NSDictionary dictionaryWithProjectNodeTypesAsStrings];
    return [[nodeTypesToString allKeysForObject:boxEnum(nodeType)] objectAtIndex:0];
}


- (XcodeMemberType) asMemberType {
    NSDictionary* nodeTypesToString = [NSDictionary dictionaryWithProjectNodeTypesAsStrings];
    return (XcodeMemberType) [[nodeTypesToString objectForKey:self] intValue];
}


@end