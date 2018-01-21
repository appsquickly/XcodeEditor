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
#import "XCAbstractDefinition.h"


@interface XCXibDefinition : XCAbstractDefinition
{
    NSString* _name;
    NSString* _content;
}
@property(nonatomic, strong, readonly) NSString* name;
@property(nonatomic, strong) NSString* content;

+ (XCXibDefinition*)xibDefinitionWithName:(NSString*)name;

+ (XCXibDefinition*)xibDefinitionWithName:(NSString*)name content:(NSString*)content;

- (id)initWithName:(NSString*)name;

- (id)initWithName:(NSString*)name content:(NSString*)content;

- (NSString*)xibFileName;

@end
