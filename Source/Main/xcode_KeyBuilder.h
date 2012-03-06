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
#import <CommonCrypto/CommonDigest.h>

#define HASH_VALUE_STORAGE_SIZE 48

typedef struct {
    char value[CC_MD5_DIGEST_LENGTH];
} HashValueMD5Hash;


@interface xcode_KeyBuilder : NSObject {
    unsigned char _value[HASH_VALUE_STORAGE_SIZE];
}

+ (xcode_KeyBuilder*) forItemNamed:(NSString*)name;

- (id) initHashValueMD5HashWithBytes:(const void*)bytes length:(NSUInteger)length;

- (NSString*) build;

@end

/* ================================================================================================================== */
@compatibility_alias KeyBuilder xcode_KeyBuilder;
