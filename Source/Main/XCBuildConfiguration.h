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



@class XCProject;

@interface XCBuildConfiguration : NSObject
{
@private
    NSMutableDictionary* _buildSettings;
    NSMutableDictionary* _xcconfigSettings;
}

+ (NSDictionary*)buildConfigurationsFromArray:(NSArray*)array inProject:(XCProject*)project;

@property(nonatomic, readonly) NSDictionary* specifiedBuildSettings;

- (void)addBuildSettings:(NSDictionary*)buildSettings;

- (void)addOrReplaceBuildSetting:(id <NSCopying>)setting forKey:(NSString*)key;

- (id<NSCopying>)valueForKey:(NSString*)key;

@end
