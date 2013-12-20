////////////////////////////////////////////////////////////////////////////////
//
//  JASPER BLUES
//  Copyright 2012 - 2013 Jasper Blues
//  All Rights Reserved.
//
//  NOTICE: Jasper Blues permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////


#import <Foundation/Foundation.h>
#import "XCAbstractDefinition.h"

typedef enum
{
    ObjectiveC,
    ObjectiveCPlusPlus,
    CPlusPlus,
} ClassDefinitionLanguage;

@interface XCClassDefinition : XCAbstractDefinition
{

    NSString* _className;
    NSString* _header;
    NSString* _source;

@private
    ClassDefinitionLanguage _language;
}

@property(strong, nonatomic, readonly) NSString* className;
@property(nonatomic, strong) NSString* header;
@property(nonatomic, strong) NSString* source;

+ (XCClassDefinition*)classDefinitionWithName:(NSString*)fileName;

+ (XCClassDefinition*)classDefinitionWithName:(NSString*)className language:(ClassDefinitionLanguage)language;

/**
* Initializes a new objective-c class definition.
*/
- (id)initWithName:(NSString*)fileName;

/**
* Initializes a new class definition with the specified language.
*/
- (id)initWithName:(NSString*)className language:(ClassDefinitionLanguage)language;

- (BOOL)isObjectiveC;

- (BOOL)isObjectiveCPlusPlus;

- (BOOL)isCPlusPlus;

- (NSString*)headerFileName;

- (NSString*)sourceFileName;

@end
