//
//  XCBuildShellScriptDefinition.m
//  xcode-editor
//
//  Created by joel on 03/02/16.
//
//

#import "XCBuildShellScriptDefinition.h"

#import "NSString+RemoveEmoji.h"

@implementation XCBuildShellScriptDefinition
//-------------------------------------------------------------------------------------------
#pragma mark - Class Methods
//-------------------------------------------------------------------------------------------


+ (XCBuildShellScriptDefinition*_Nonnull)shellScriptDefinitionWithName:(NSString *)name
                                             files: (NSArray<NSString*>* _Nullable)files
                                        inputPaths:(NSArray<NSString*>* _Nullable)inputPaths
                                       outputPaths:(NSArray<NSString*>* _Nullable)outputPaths
                runOnlyForDeploymentPostprocessing:(BOOL)runOnlyForDeploymentPostprocessing
                                         shellPath:(NSString*_Nullable)shellPath
                                       shellScript:(NSString*_Nonnull)shellScript
{
    return [[XCBuildShellScriptDefinition alloc]initWithName:name
                                             files:files
                                        inputPaths:inputPaths
                                       outputPaths:outputPaths
                runOnlyForDeploymentPostprocessing:runOnlyForDeploymentPostprocessing
                                         shellPath:shellPath
                                       shellScript:shellScript];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Initialization & Destruction
//-------------------------------------------------------------------------------------------


- (instancetype _Nonnull)initWithName:( NSString* _Nullable )name
                                files: (NSArray<NSString*>* _Nullable)files
                           inputPaths:(NSArray<NSString*>* _Nullable)inputPaths
                          outputPaths:(NSArray<NSString*>* _Nullable)outputPaths
   runOnlyForDeploymentPostprocessing:(BOOL)runOnlyForDeploymentPostprocessing
                            shellPath:(NSString*_Nullable)shellPath
                          shellScript:(NSString*_Nonnull)shellScript
{
    self = [super init];
    if (self) {
        _name = [name stringByRemovingEmoji];
        
        _files =files!=nil?files:@[];
        _inputPaths = inputPaths!=nil?inputPaths:@[];
        _outputPaths = outputPaths!=nil?outputPaths:@[];
        
        _runOnlyForDeploymentPostprocessing = runOnlyForDeploymentPostprocessing;
        _shellPath = _shellPath!=nil?_shellPath:@"/bin/sh";
        _shellScript = shellScript;
        
    }
    return self;
}

@end
