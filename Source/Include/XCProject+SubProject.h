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
#import <XcodeEditor/XCProject.h>

@interface XCProject (SubProject)


- (NSString *)referenceProxyKeyForName:(NSString *)name;

- (NSArray<XCSourceFile*> *)buildProductsForTargets:(NSString *)xcodeprojKey;

- (void)addAsTargetDependency:(XCSubProjectDefinition *)xcodeprojDefinition toTargets:(NSArray<XCTarget*>*)targets;

- (NSArray<NSString*> *)keysForProjectObjectsOfType:(XcodeMemberType)memberType withIdentifier:(NSString *)identifier
    singleton:(BOOL)singleton required:(BOOL)required;

- (NSMutableDictionary *)PBXProjectDict;

- (void)removeProxies:(NSString *)xcodeprojKey;

- (void)addProxies:(XCSubProjectDefinition *)xcodeproj;

- (void)removeFromProjectReferences:(NSString *)key forProductsGroup:(NSString *)productsGroupKey;

- (void)removeTargetDependencies:(NSString *)name;

- (NSString *)containerItemProxyKeyForName:(NSString *)name proxyType:(NSString *)proxyType;

- (NSString *)productsGroupKeyForKey:(NSString *)key;

@end
