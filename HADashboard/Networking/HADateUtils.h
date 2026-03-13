#import <Foundation/Foundation.h>

/**
 * Shared ISO 8601 date parsing with fallback for iOS versions
 * where ZZZZZ (colon-separated timezone, e.g. +00:00) is unsupported.
 *
 * Falls back by stripping the colon from the timezone offset
 * (+00:00 → +0000) and retrying with ZZZ format.
 */
@interface HADateUtils : NSObject

/**
 * Parse an ISO 8601 datetime string.
 * Tries formats in order:
 *   1. yyyy-MM-dd'T'HH:mm:ssZZZZZ
 *   2. yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ
 *   3. yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ
 *   4. Colon-stripped timezone fallback for each (iOS ≤10)
 *   5. yyyy-MM-dd'T'HH:mm:ss (no timezone)
 *
 * @param string ISO 8601 datetime string from Home Assistant
 * @return Parsed date, or nil if unparseable
 */
+ (NSDate *)dateFromISO8601String:(NSString *)string;

@end
