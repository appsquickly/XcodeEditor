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


@interface xcode_XibDefinition : NSObject

@property(nonatomic, strong, readonly) NSString* name;
@property(nonatomic, strong, readonly) NSString* content;

- (id) initWithName:(NSString*)name content:(NSString*)content;


@end
/* ================================================================================================================== */
@compatibility_alias XibDefinition xcode_XibDefinition;