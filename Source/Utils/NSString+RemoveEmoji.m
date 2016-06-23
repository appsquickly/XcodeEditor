#import "NSString+RemoveEmoji.h"

static NSCharacterSet* VariationSelectors = nil;

@implementation NSString (RemoveEmoji)

+ (void)load
{
    VariationSelectors = [NSCharacterSet characterSetWithRange:NSMakeRange(0xFE00, 16)];
}

- (BOOL)isEmoji
{
    if ([self rangeOfCharacterFromSet: VariationSelectors].location != NSNotFound)
    {
        return YES;
    }
        
    const unichar high = [self characterAtIndex: 0];

    // Surrogate pair (U+1D000-1F9FF)
    if (0xD800 <= high && high <= 0xDBFF)
    {
        const unichar low = [self characterAtIndex: 1];
        const int codepoint = ((high - 0xD800) * 0x400) + (low - 0xDC00) + 0x10000;

        return (0x1D000 <= codepoint && codepoint <= 0x1F9FF);

    // Not surrogate pair (U+2100-27BF)
    }
    else
    {
        return (0x2100 <= high && high <= 0x27BF);
    }
}

- (BOOL)isIncludingEmoji {
    BOOL __block result = NO;

    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
        if ([substring isEmoji]) {
            *stop = YES;
            result = YES;
        }
    }];

    return result;
}

- (instancetype)stringByRemovingEmoji
{
    NSMutableString* __block buffer = [NSMutableString stringWithCapacity:[self length]];

    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
        [buffer appendString:([substring isEmoji])? @"": substring];
    }];

    return buffer;
}

- (instancetype)removedEmojiString
{
    return [self stringByRemovingEmoji];
}

@end
