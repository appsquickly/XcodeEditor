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

#import "XCKeyBuilder.h"
#import <CommonCrypto/CommonDigest.h>

#if MD5_DIGEST_LENGTH != CC_MD5_DIGEST_LENGTH
#error Digest length in XCKeyBuilder.h (MD5_DIGEST_LENGTH) disagress with CommonCrypto value (CC_MD5_DIGEST_LENGTH)
#endif

@implementation XCKeyBuilder

//-------------------------------------------------------------------------------------------
#pragma mark - Class Methods
//-------------------------------------------------------------------------------------------

+ (XCKeyBuilder*)forItemNamed:(NSString*)name
{
    return [self createUnique];
}

+ (XCKeyBuilder*)createUnique
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFUUIDBytes bytes = CFUUIDGetUUIDBytes(theUUID);
    CFRelease(theUUID);

    return [[XCKeyBuilder alloc] initHashValueMD5HashWithBytes:&bytes length:sizeof(bytes)];
}

//-------------------------------------------------------------------------------------------
#pragma mark - Initialization & Destruction
//-------------------------------------------------------------------------------------------

- (id)initHashValueMD5HashWithBytes:(const void*)bytes length:(NSUInteger)length
{
    self = [super init];
    if (self != nil)
    {
        CC_MD5(bytes, (int) length, _value);
    }
    return self;
}

//-------------------------------------------------------------------------------------------
#pragma mark - Interface Methods
//-------------------------------------------------------------------------------------------

- (NSString*)build
{
    NSInteger byteLength = sizeof(HashValueMD5Hash);
    NSMutableString* stringValue = [NSMutableString stringWithCapacity:byteLength * 2];
    NSInteger i;
    for (i = 0; i < byteLength; i++)
    {
        [stringValue appendFormat:@"%02x", _value[i]];
    }
    return [[stringValue substringToIndex:24] uppercaseString];
}


@end
