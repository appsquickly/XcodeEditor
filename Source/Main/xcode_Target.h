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
@class xcode_FileResource;

/**
* Represents a target in an xcode project.
*/
@interface xcode_Target : NSObject

@property (nonatomic, weak, readonly) xcode_Project* project;
@property (nonatomic, strong, readonly) NSString* key;
@property (nonatomic, strong, readonly) NSString* name;
@property (nonatomic, strong, readonly) NSArray* members;

- (id) initWithProject:(xcode_Project*)project key:(NSString*)key name:(NSString*)name members:(NSArray*)members;

- (void) addMember:(xcode_FileResource*)member;


@end

/* ================================================================================================================== */
@compatibility_alias Target xcode_Target;