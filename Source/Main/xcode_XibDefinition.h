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
#import "xcode_AbstractDefinition.h"


@interface xcode_XibDefinition : xcode_AbstractDefinition {
    NSString* _name;
    NSString* _content;
}
@property(nonatomic, strong, readonly) NSString* name;
@property(nonatomic, strong) NSString* content;

+ (xcode_XibDefinition*) xibDefinitionWithName:(NSString*)name;

+ (xcode_XibDefinition*) xibDefinitionWithName:(NSString*)name content:(NSString*)content;

- (id) initWithName:(NSString*)name;

- (id) initWithName:(NSString*)name content:(NSString*)content;

- (NSString*) xibFileName;

@end
/* ================================================================================================================== */
@compatibility_alias XibDefinition xcode_XibDefinition;