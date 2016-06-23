//
//  XCBuildShellScript.m
//  xcode-editor
//
//  Created by joel on 03/02/16.
//
//

#import "XCBuildShellScript.h"

#import "NSString+RemoveEmoji.h"

@implementation XCBuildShellScript

//-------------------------------------------------------------------------------------------
#pragma mark - Class Methods
//-------------------------------------------------------------------------------------------


+ (XCBuildShellScript*_Nonnull)shellScriptWithProject:(XCProject *)project
                                                  key:(NSString *)key
                                                 name:(NSString *)name
                                                files:(NSArray<NSString *> *)files
                                           inputPaths:(NSArray<NSString *> *)inputPaths
                                          outputPaths:(NSArray<NSString *> *)outputPaths
                   runOnlyForDeploymentPostprocessing:(BOOL)runOnlyForDeploymentPostprocessing
                                            shellPath:(NSString *)shellPath
                                          shellScript:(NSString *)shellScript
{
    return [[XCBuildShellScript alloc]initWithProject:project
                                                  key:key
                                                 name:name
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


- (instancetype _Nonnull)initWithProject:(XCProject *)project
                                     key:(NSString *)key
                                    name:(NSString *)name
                                   files:(NSArray<NSString *> *)files
                              inputPaths:(NSArray<NSString *> *)inputPaths
                             outputPaths:(NSArray<NSString *> *)outputPaths
      runOnlyForDeploymentPostprocessing:(BOOL)runOnlyForDeploymentPostprocessing
                               shellPath:(NSString *)shellPath
                             shellScript:(NSString *)shellScript
{
    self = [super init];
    if (self) {
        
        _project = project;
        _key =  key;
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
