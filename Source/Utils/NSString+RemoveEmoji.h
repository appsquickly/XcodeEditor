#import <Foundation/Foundation.h>

@interface NSString (RemoveEmoji)

- (BOOL)isIncludingEmoji;

- (instancetype)stringByRemovingEmoji;

- (instancetype)removedEmojiString __attribute__((deprecated));

@end
