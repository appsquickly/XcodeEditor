//
//  XCBuildShellScript.h
//  xcode-editor
//
//  Created by joel on 03/02/16.
//
//

#import <Foundation/Foundation.h>
#import "XcodeGroupMember.h"
#import "XcodeSourceFileType.h"

@class XCProject;

@interface XCBuildShellScript : NSObject
{
    NSString* _key;

@private
    XCProject*_project;
    BOOL _runOnlyForDeploymentPostprocessing;
    NSArray*_files;
    NSArray*_inputPaths;
    NSArray*_outputPaths;
    NSString*_name;
    NSString*_shellPath;
    NSString*_shellScript;
}

@property(nonatomic, strong, readonly,nonnull) NSString* key;
@property(nonatomic, strong, readonly,nonnull) NSString* name;
@property(nonatomic,readonly) BOOL runOnlyForDeploymentPostprocessing;
@property(nonatomic,nonnull,strong,readonly) NSString*shellScript;
@property(nonatomic,nonnull,strong,readonly) NSString*shellPath;
@property(nonatomic,nonnull,strong,readonly) NSArray<NSString*>*files;
@property(nonatomic,nonnull,strong,readonly) NSArray<NSString*>*inputPaths;
@property(nonatomic,nonnull,strong,readonly) NSArray<NSString*>*outputPaths;

//-------------------------------------------------------------------------------------------
#pragma mark - Initialization & Destruction
//-------------------------------------------------------------------------------------------

+ (XCBuildShellScript*_Nonnull)shellScriptWithProject:(XCProject*_Nonnull)project
                                                  key:(NSString *_Nonnull)key
                                                 name:( NSString* _Nullable )name
                         files: (NSArray<NSString*>* _Nullable)files
                    inputPaths:(NSArray<NSString*>* _Nullable)inputPaths
                   outputPaths:(NSArray<NSString*>* _Nullable)outputPaths
runOnlyForDeploymentPostprocessing:(BOOL)runOnlyForDeploymentPostprocessing
                     shellPath:(NSString*_Nullable)shellPath
                   shellScript:(NSString*_Nonnull)shellScript;

- (instancetype _Nonnull)initWithProject:(XCProject*_Nonnull)project
                                    key:(NSString *_Nonnull)key
                                    name:( NSString* _Nullable )name
                       files: (NSArray<NSString*>* _Nullable)files
                  inputPaths:(NSArray<NSString*>* _Nullable)inputPaths
                 outputPaths:(NSArray<NSString*>* _Nullable)outputPaths
runOnlyForDeploymentPostprocessing:(BOOL)runOnlyForDeploymentPostprocessing
                   shellPath:(NSString*_Nullable)shellPath
                 shellScript:(NSString*_Nonnull)shellScript;



@end
