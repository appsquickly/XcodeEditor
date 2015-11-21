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

#import <Foundation/Foundation.h>

typedef enum
{
    PBXNilType,
    PBXBuildFileType,
    PBXContainerItemProxyType,
    PBXCopyFilesBuildPhaseType,
    PBXFileReferenceType,
    PBXFrameworksBuildPhaseType,
    PBXGroupType,
    PBXNativeTargetType,
    PBXProjectType,
    PBXReferenceProxyType,
    PBXResourcesBuildPhaseType,
    PBXSourcesBuildPhaseType,
    PBXTargetDependencyType,
    PBXVariantGroupType,
    XCBuildConfigurationType,
    XCConfigurationListType
} XcodeMemberType;

@interface NSString (XcodeMemberTypeExtensions)

+ (NSString*)xce_stringFromMemberType:(XcodeMemberType)nodeType;

- (XcodeMemberType)xce_asMemberType;

- (BOOL)xce_hasFileReferenceType;
- (BOOL)xce_hasFileReferenceOrReferenceProxyType;
- (BOOL)xce_hasReferenceProxyType;
- (BOOL)xce_hasGroupType;
- (BOOL)xce_hasProjectType;
- (BOOL)xce_hasNativeTargetType;
- (BOOL)xce_hasBuildFileType;
- (BOOL)xce_hasBuildConfigurationType;
- (BOOL)xce_hasContainerItemProxyType;
- (BOOL)xce_hasResourcesBuildPhaseType;
- (BOOL)xce_hasSourcesOrFrameworksBuildPhaseType;

@end


