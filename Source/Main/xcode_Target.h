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

@private
    NSMutableArray* _members;
}

@property (nonatomic, weak, readonly) xcode_Project* project;
@property (nonatomic, strong, readonly) NSString* key;
@property (nonatomic, strong, readonly) NSString* name;

- (id) initWithProject:(xcode_Project*)project key:(NSString*)key name:(NSString*)name;

- (NSArray*) members;

- (void) addMember:(xcode_SourceFile*)member;


@end

/* ================================================================================================================== */
@compatibility_alias Target xcode_Target;