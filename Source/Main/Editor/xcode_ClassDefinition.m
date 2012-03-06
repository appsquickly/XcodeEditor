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

#import "xcode_ClassDefinition.h"
#import "xcode_KeyBuilder.h"

@implementation xcode_ClassDefinition


@synthesize className = _className;
@synthesize header = _header;
@synthesize source = _source;

/* ================================================== Initializers ================================================== */
- (id) initWithName:(NSString*)className {
    return [self initWithName:className language:ObjectiveC];
}

- (id) initWithName:(NSString*)className language:(ClassDefinitionLanguage)language {
    self = [super init];
    if (self) {
        _className = [className copy];
        if (!(language == ObjectiveC || language == ObjectiveCPlusPlus)) {
            [NSException
                raise:NSInvalidArgumentException format:@"Language must be one of ObjectiveC, ObjectiveCPlusPlus"];
        }
        _language = language;
    }
    return self;
}


/* ================================================ Interface Methods =============================================== */
- (BOOL) isObjectiveC {
    return _language == ObjectiveC;
}

- (BOOL) isObjectiveCPlusPlus {
    return _language == ObjectiveCPlusPlus;
}

- (NSString*) headerFileName {
    return [_className stringByAppendingString:@".h"];

}

- (NSString*) sourceFileName {
    NSString* sourceFileName; 
    if ([self isObjectiveC]) {
        sourceFileName = [_className stringByAppendingString:@".m"];
    }
    else if ([self isObjectiveCPlusPlus]) {
        sourceFileName = [_className stringByAppendingString:@".mm"];
    }
    return sourceFileName;
}


@end
