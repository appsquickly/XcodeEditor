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
    PBXReferenceProxy,
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


