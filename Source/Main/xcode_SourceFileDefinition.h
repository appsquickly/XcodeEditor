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
#import "XcodeSourceFileType.h"

@interface xcode_SourceFileDefinition : xcode_AbstractDefinition {

    NSString* _sourceFileName;
    XcodeSourceFileType _type;
    NSData* _data;

}

@property(nonatomic, strong, readonly) NSString* sourceFileName;
@property(nonatomic, strong, readonly) NSData* data;
@property(nonatomic, readonly) XcodeSourceFileType type;

+ (xcode_SourceFileDefinition*) sourceDefinitionWithName:(NSString*)name text:(NSString*)text
        type:(XcodeSourceFileType)type;

+ (xcode_SourceFileDefinition*) sourceDefinitionWithName:(NSString*)name data:(NSData*)data
        type:(XcodeSourceFileType)type;

- (id) initWithName:(NSString*)name text:(NSString*)text type:(XcodeSourceFileType)type;

- (id) initWithName:(NSString*)name data:(NSData*)data type:(XcodeSourceFileType)type;


@end
/* ================================================================================================================== */
@compatibility_alias SourceFileDefinition xcode_SourceFileDefinition;