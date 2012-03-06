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


typedef enum {
    PBXNilType,
    PBXBuildFile,
    PBXContainerItemProxy,
    PBXCopyFilesBuildPhase,
    PBXFileReference,
    PBXFrameworksBuildPhase,
    PBXGroup,
    PBXNativeTarget,
    PBXProject,
    PBXResourcesBuildPhase,
    PBXSourcesBuildPhase,
    PBXTargetDependency,
    PBXVariantGroup,
    XCBuildConfiguration,
    XCConfigurationList
} XcodeMemberType;

@interface NSString (XcodeMemberType)

+ (NSString*) stringFromMemberType:(XcodeMemberType)nodeType;

- (XcodeMemberType) asMemberType;

@end


