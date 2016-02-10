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

static NSString* const kPBXNilType = @"PBXNilType";
static NSString* const kPBXBuildFile = @"PBXBuildFile";
static NSString* const kPBXContainerItemProxy = @"PBXContainerItemProxy";
static NSString* const kPBXCopyFilesBuildPhase = @"PBXCopyFilesBuildPhase";
static NSString* const kPBXFileReference = @"PBXFileReference";
static NSString* const kPBXFrameworksBuildPhase = @"PBXFrameworksBuildPhase";
static NSString* const kPBXGroup = @"PBXGroup";
static NSString* const kPBXNativeTarget = @"PBXNativeTarget";
static NSString* const kPBXProject = @"PBXProject";
static NSString* const kPBXReferenceProxy = @"PBXReferenceProxy";
static NSString* const kPBXResourcesBuildPhase = @"PBXResourcesBuildPhase";
static NSString* const kPBXShellScriptBuildPhase = @"PBXShellScriptBuildPhase";
static NSString* const kPBXSourcesBuildPhase = @"PBXSourcesBuildPhase";
static NSString* const kPBXTargetDependency = @"PBXTargetDependency";
static NSString* const kPBXVariantGroup = @"PBXVariantGroup";
static NSString* const kXCBuildConfiguration = @"XCBuildConfiguration";
static NSString* const kXCConfigurationList = @"XCConfigurationList";
static NSString* const kXCVersionGroup = @"XCVersionGroup";

static NSDictionary* DictionaryWithProjectNodeTypesAsStrings() {
    // This is the most vital operation on adding 500+ files
    // So, we caching this dictionary
    static NSDictionary* _projectNodeTypesAsStrings;
    if (_projectNodeTypesAsStrings) {
        return _projectNodeTypesAsStrings;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _projectNodeTypesAsStrings = @{
                                       kPBXNilType              : @(PBXNilType),
                                       kPBXBuildFile            : @(PBXBuildFileType),
                                       kPBXContainerItemProxy   : @(PBXContainerItemProxyType),
                                       kPBXCopyFilesBuildPhase  : @(PBXCopyFilesBuildPhaseType),
                                       kPBXFileReference        : @(PBXFileReferenceType),
                                       kPBXFrameworksBuildPhase : @(PBXFrameworksBuildPhaseType),
                                       kPBXGroup                : @(PBXGroupType),
                                       kPBXNativeTarget         : @(PBXNativeTargetType),
                                       kPBXProject              : @(PBXProjectType),
                                       kPBXReferenceProxy       : @(PBXReferenceProxyType),
                                       kPBXResourcesBuildPhase  : @(PBXResourcesBuildPhaseType),
                                       kPBXSourcesBuildPhase    : @(PBXSourcesBuildPhaseType),
                                       kPBXTargetDependency     : @(PBXTargetDependencyType),
                                       kPBXVariantGroup         : @(PBXVariantGroupType),
                                       kXCBuildConfiguration    : @(XCBuildConfigurationType),
                                       kXCConfigurationList     : @(XCConfigurationListType),
                                       kPBXShellScriptBuildPhase : @(PBXShellScriptBuildPhase),
                                       kXCVersionGroup          : @(XCVersionGroupType)
                                       };
    });
    return _projectNodeTypesAsStrings;
}

@implementation NSString (XcodeMemberTypeExtensions)

+ (NSString*)xce_stringFromMemberType:(XcodeMemberType)nodeType {
    NSDictionary* nodeTypesToString = DictionaryWithProjectNodeTypesAsStrings();
    return [[nodeTypesToString allKeysForObject:@(nodeType)] firstObject];
}


- (XcodeMemberType)xce_asMemberType {
    NSDictionary* nodeTypesToString = DictionaryWithProjectNodeTypesAsStrings();
    return (XcodeMemberType) [[nodeTypesToString objectForKey:self] intValue];
}

- (BOOL)xce_hasFileReferenceType {
    return [self isEqualToString:kPBXFileReference];
}

- (BOOL)xce_hasFileReferenceOrReferenceProxyType {
    return [self isEqualToString:kPBXFileReference] || [self isEqualToString:kPBXReferenceProxy];
}

- (BOOL)xce_hasReferenceProxyType {
    return [self isEqualToString:kPBXReferenceProxy];
}

- (BOOL)xce_hasGroupType {
    return [self isEqualToString:kPBXGroup] || [self isEqualToString:kPBXVariantGroup];
}

- (BOOL)xce_hasProjectType {
    return [self isEqualToString:kPBXProject];
}

- (BOOL)xce_hasNativeTargetType {
    return [self isEqualToString:kPBXNativeTarget];
}

- (BOOL)xce_hasBuildFileType {
    return [self isEqualToString:kPBXBuildFile];
}

- (BOOL)xce_hasBuildConfigurationType {
    return [self isEqualToString:kXCBuildConfiguration];
}

- (BOOL)xce_hasShellScriptBuildPhase {
    return [self isEqualToString:kPBXShellScriptBuildPhase];
}

- (BOOL)xce_hasContainerItemProxyType {
    return [self isEqualToString:kPBXContainerItemProxy];
}

- (BOOL)xce_hasResourcesBuildPhaseType {
    return [self isEqualToString:kPBXResourcesBuildPhase];
}

- (BOOL)xce_hasSourcesOrFrameworksBuildPhaseType {
    return [self isEqualToString:kPBXSourcesBuildPhase] || [self isEqualToString:kPBXFrameworksBuildPhase];
}

- (BOOL)xce_hasVersionedGroupType {
    return [self isEqualToString:kXCVersionGroup];
}

@end