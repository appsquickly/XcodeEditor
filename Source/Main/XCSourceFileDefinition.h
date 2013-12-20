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
#import "XcodeSourceFileType.h"

@interface XCSourceFileDefinition : XCAbstractDefinition
{

    NSString* _sourceFileName;
    XcodeSourceFileType _type;
    NSData* _data;

}

@property(nonatomic, strong, readonly) NSString* sourceFileName;
@property(nonatomic, strong, readonly) NSData* data;
@property(nonatomic, readonly) XcodeSourceFileType type;

+ (XCSourceFileDefinition*)sourceDefinitionWithName:(NSString*)name text:(NSString*)text type:(XcodeSourceFileType)type;

+ (XCSourceFileDefinition*)sourceDefinitionWithName:(NSString*)name data:(NSData*)data type:(XcodeSourceFileType)type;

- (id)initWithName:(NSString*)name text:(NSString*)text type:(XcodeSourceFileType)type;

- (id)initWithName:(NSString*)name data:(NSData*)data type:(XcodeSourceFileType)type;


@end
