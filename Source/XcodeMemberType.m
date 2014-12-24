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




#import "XcodeMemberType.h"


@implementation NSDictionary (XcodeMemberType)


+ (NSDictionary*)dictionaryWithProjectNodeTypesAsStrings
{
    // This is the most vital operation on adding 500+ files
    // So, we caching this dictionary
    static NSDictionary* _projectNodeTypesAsStrings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        _projectNodeTypesAsStrings =
            [[NSDictionary alloc] initWithObjectsAndKeys:@(PBXNilType),                  @"PBXNilType",
                                                         @(PBXBuildFileType),            @"PBXBuildFile",
                                                         @(PBXContainerItemProxyType),   @"PBXContainerItemProxy",
                                                         @(PBXCopyFilesBuildPhaseType),  @"PBXCopyFilesBuildPhase",
                                                         @(PBXFileReferenceType),        @"PBXFileReference",
                                                         @(PBXFrameworksBuildPhaseType), @"PBXFrameworksBuildPhase",
                                                         @(PBXGroupType),                @"PBXGroup",
                                                         @(PBXNativeTargetType),         @"PBXNativeTarget",
                                                         @(PBXProjectType),              @"PBXProject",
                                                         @(PBXReferenceProxyType),       @"PBXReferenceProxy",
                                                         @(PBXResourcesBuildPhaseType),  @"PBXResourcesBuildPhase",
                                                         @(PBXSourcesBuildPhaseType),    @"PBXSourcesBuildPhase",
                                                         @(PBXTargetDependencyType),     @"PBXTargetDependency",
                                                         @(PBXVariantGroupType),         @"PBXVariantGroup",
                                                         @(XCBuildConfigurationType),    @"XCBuildConfiguration",
                                                         @(XCConfigurationListType),     @"XCConfigurationList", nil];
    });
    return _projectNodeTypesAsStrings;
}

@end

@implementation NSString (XcodeMemberTypeExtensions)

+ (NSString*)stringFromMemberType:(XcodeMemberType)nodeType
{
    NSDictionary* nodeTypesToString = [NSDictionary dictionaryWithProjectNodeTypesAsStrings];
    return [[nodeTypesToString allKeysForObject:@(nodeType)] objectAtIndex:0];
}


- (XcodeMemberType)asMemberType
{
    NSDictionary* nodeTypesToString = [NSDictionary dictionaryWithProjectNodeTypesAsStrings];
    return (XcodeMemberType) [[nodeTypesToString objectForKey:self] intValue];
}


@end