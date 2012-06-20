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

#import <Foundation/Foundation.h>
#import <XcodeEditor/xcode_Project.h>

@interface xcode_Project (SubProject)


- (NSString*) referenceProxyKeyForName:(NSString*)name;

- (NSArray*) buildProductsForTargets:(NSString*)xcodeprojKey;

- (void) addAsTargetDependency:(xcode_SubProjectDefinition*)xcodeprojDefinition toTargets:(NSArray*)targets;

- (NSArray*) keysForProjectObjectsOfType:(XcodeMemberType)memberType withIdentifier:(NSString*)identifier
        singleton:(BOOL)singleton required:(BOOL)required;

- (NSMutableDictionary*) PBXProjectDict;

- (void) removeProxies:(NSString*)xcodeprojKey;

- (void) addProxies:(xcode_SubProjectDefinition*)xcodeproj;

- (void) removeFromProjectReferences:(NSString*)key forProductsGroup:(NSString*)productsGroupKey;

- (void) removeTargetDependencies:(NSString*)name;

- (NSString*) containerItemProxyKeyForName:(NSString*)name proxyType:(NSString*)proxyType;

- (NSString*) productsGroupKeyForKey:(NSString*)key;

@end