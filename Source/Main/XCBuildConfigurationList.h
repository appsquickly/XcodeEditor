////////////////////////////////////////////////////////////////////////////////
//
//  EXPANZ
//  Copyright 2012 Zach Drayer
//  All Rights Reserved.
//
//  NOTICE: Zach Drayer permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

@class XCProject;

@interface XCBuildConfigurationList : NSObject {
	@private
	NSMutableDictionary *_buildSettings;
	NSMutableDictionary *_xcconfigSettings;
}

+ (NSDictionary *) buildConfigurationsFromDictionary:(NSDictionary *) dictionary inProject:(XCProject *) project;

@property (nonatomic, readonly) NSDictionary *specifiedBuildSettings;

- (void) addXCConfigAtPath:(NSString *) path;
- (void) addBuildSettings:(NSDictionary *) buildSettings;

- (NSString *) valueForKey:(NSString *) key;
@end
