//
//  XCBuildShellScriptDefinition.h
//  xcode-editor
//
//  Created by joel on 03/02/16.
//
//

#import <Foundation/Foundation.h>
#import "XCAbstractDefinition.h"

@interface XCBuildShellScriptDefinition : XCAbstractDefinition
{
    NSString* _key;
    
@private
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

+ (XCBuildShellScriptDefinition*_Nonnull)shellScriptDefinitionWithName:( NSString* _Nullable )name
                                             files: (NSArray<NSString*>* _Nullable)files
                                        inputPaths:(NSArray<NSString*>* _Nullable)inputPaths
                                       outputPaths:(NSArray<NSString*>* _Nullable)outputPaths
                runOnlyForDeploymentPostprocessing:(BOOL)runOnlyForDeploymentPostprocessing
                                         shellPath:(NSString*_Nullable)shellPath
                                       shellScript:(NSString*_Nonnull)shellScript;

- (instancetype _Nonnull)initWithName:( NSString* _Nullable )name
                                files: (NSArray<NSString*>* _Nullable)files
                           inputPaths:(NSArray<NSString*>* _Nullable)inputPaths
                          outputPaths:(NSArray<NSString*>* _Nullable)outputPaths
   runOnlyForDeploymentPostprocessing:(BOOL)runOnlyForDeploymentPostprocessing
                            shellPath:(NSString*_Nullable)shellPath
                          shellScript:(NSString*_Nonnull)shellScript;

@end
