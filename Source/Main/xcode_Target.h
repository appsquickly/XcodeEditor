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

@class xcode_Project;
@class xcode_SourceFile;

/**
* Represents a target in an xcode project.
*/
@interface xcode_Target : NSObject {

    __weak xcode_Project* _project;
    NSString* _key;
    NSString* _name;

@private
    NSMutableArray* _members;
}

@property(nonatomic, strong, readonly) NSString* key;
@property(nonatomic, strong, readonly) NSString* name;

+ (xcode_Target*) targetWithProject:(xcode_Project*)project key:(NSString*)key name:(NSString*)name;

- (id) initWithProject:(xcode_Project*)project key:(NSString*)key name:(NSString*)name;

- (NSArray*) members;

- (void) addMember:(xcode_SourceFile*)member;

- (void) removeMemberWithKey:(NSString*)key;

- (void) removeMembersWithKeys:(NSArray*)keys;

@end

/* ================================================================================================================== */
@compatibility_alias Target xcode_Target;