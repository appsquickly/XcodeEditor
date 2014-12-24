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
#import <CommonCrypto/CommonDigest.h>

#define HASH_VALUE_STORAGE_SIZE 48

typedef struct
{
    char value[CC_MD5_DIGEST_LENGTH];
} HashValueMD5Hash;


@interface XCKeyBuilder : NSObject
{
    unsigned char _value[HASH_VALUE_STORAGE_SIZE];
}

+ (XCKeyBuilder*)forItemNamed:(NSString*)name;

+ (XCKeyBuilder*)createUnique;

- (id)initHashValueMD5HashWithBytes:(const void*)bytes length:(NSUInteger)length;

- (NSString*)build;

@end

