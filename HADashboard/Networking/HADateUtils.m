#import "HADateUtils.h"

@implementation HADateUtils

+ (NSDate *)dateFromISO8601String:(NSString *)string {
    if (!string || ![string isKindOfClass:[NSString class]]) return nil;

    static NSDateFormatter *fmtNoFrac, *fmtFrac3, *fmtFrac6, *fmtNoTZ;
    static NSDateFormatter *fmtNoFracCompat, *fmtFrac3Compat, *fmtFrac6Compat;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];

        // Primary formatters (ZZZZZ = colon timezone, e.g. +00:00)
        fmtNoFrac = [[NSDateFormatter alloc] init];
        fmtNoFrac.locale = posix;
        fmtNoFrac.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";

        fmtFrac3 = [[NSDateFormatter alloc] init];
        fmtFrac3.locale = posix;
        fmtFrac3.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";

        fmtFrac6 = [[NSDateFormatter alloc] init];
        fmtFrac6.locale = posix;
        fmtFrac6.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ";

        // Compat formatters (ZZZ = no-colon timezone, e.g. +0000)
        // Used as fallback on iOS ≤10 where ZZZZZ doesn't work
        fmtNoFracCompat = [[NSDateFormatter alloc] init];
        fmtNoFracCompat.locale = posix;
        fmtNoFracCompat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";

        fmtFrac3Compat = [[NSDateFormatter alloc] init];
        fmtFrac3Compat.locale = posix;
        fmtFrac3Compat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZ";

        fmtFrac6Compat = [[NSDateFormatter alloc] init];
        fmtFrac6Compat.locale = posix;
        fmtFrac6Compat.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZ";

        // No-timezone fallback
        fmtNoTZ = [[NSDateFormatter alloc] init];
        fmtNoTZ.locale = posix;
        fmtNoTZ.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    });

    // Try ZZZZZ formats first (works on iOS 11+)
    NSDate *date = [fmtNoFrac dateFromString:string];
    if (date) return date;
    date = [fmtFrac3 dateFromString:string];
    if (date) return date;
    date = [fmtFrac6 dateFromString:string];
    if (date) return date;

    // Fallback: strip colon from timezone offset for iOS ≤10
    // "+00:00" → "+0000", "+05:30" → "+0530"
    NSString *compat = string;
    NSUInteger len = compat.length;
    if (len >= 6 && [compat characterAtIndex:len - 3] == ':') {
        compat = [NSString stringWithFormat:@"%@%@",
            [compat substringToIndex:len - 3],
            [compat substringFromIndex:len - 2]];

        date = [fmtNoFracCompat dateFromString:compat];
        if (date) return date;
        date = [fmtFrac3Compat dateFromString:compat];
        if (date) return date;
        date = [fmtFrac6Compat dateFromString:compat];
        if (date) return date;
    }

    // Last resort: no timezone at all
    date = [fmtNoTZ dateFromString:string];
    return date;
}

@end
