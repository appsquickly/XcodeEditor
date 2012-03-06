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

typedef enum {
    ObjectiveC,
    ObjectiveCPlusPlus
} ClassDefinitionLanguage;

@interface xcode_ClassDefinition : NSObject {

@private
    ClassDefinitionLanguage _language;
}

@property(strong, nonatomic, readonly) NSString* className;
@property(nonatomic, strong) NSString* header;
@property(nonatomic, strong) NSString* source;

/**
* Initializes a new objective-c class definition.
*/
- (id) initWithName:(NSString*)fileName;

/**
* Initializes a new class definition with the specified language.
*/
- (id) initWithName:(NSString*)className language:(ClassDefinitionLanguage)language;

- (BOOL) isObjectiveC;

- (BOOL) isObjectiveCPlusPlus;

- (NSString*) headerFileName;

- (NSString*) sourceFileName;

@end

/* ================================================================================================================== */
@compatibility_alias ClassDefinition xcode_ClassDefinition;
