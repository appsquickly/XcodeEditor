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

@class XCProject;

@interface XCProjectBuildConfig : NSObject
{
@private
    __weak XCProject* _project;
    NSString* _key;

    NSMutableDictionary* _buildSettings;
    NSMutableDictionary* _xcconfigSettings;
}
@property(nonatomic, strong, readonly) NSString* key;
@property(nonatomic, readonly) NSDictionary* specifiedBuildSettings;

+ (NSDictionary<NSString*,NSString*>*)buildConfigurationsFromArray:(NSArray<XCProjectBuildConfig*>*)array inProject:(XCProject*)project;

- (instancetype)initWithProject:(XCProject*)project key:(NSString*)key;

- (void)addBuildSettings:(NSDictionary*)buildSettings;

- (void)addOrReplaceSetting:(id <NSCopying>)setting forKey:(NSString*)key;

- (id <NSCopying>)valueForKey:(NSString*)key;

-(void)removeSettingByKey:(NSString*)key;

+ (NSString*)duplicatedBuildConfigurationListWithKey:(NSString*)buildConfigurationListKey inProject:(XCProject*)project
    withBuildConfigurationVisitor:(void (^)(NSMutableDictionary*))buildConfigurationVisitor;

@end
