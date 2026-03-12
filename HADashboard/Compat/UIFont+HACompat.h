#import <UIKit/UIKit.h>

/// iOS 5-safe font helpers. On iOS 8.2+ these use the real weighted/monospaced
/// APIs. On older systems they fall back to bold/system variants.
@interface UIFont (HACompat)

/// Equivalent to +systemFontOfSize:weight: (iOS 8.2+).
/// Falls back to boldSystemFontOfSize: for semibold+ weights, systemFontOfSize: otherwise.
+ (UIFont *)ha_systemFontOfSize:(CGFloat)size weight:(CGFloat)weight;

/// Equivalent to +monospacedDigitSystemFontOfSize:weight: (iOS 9+).
/// Falls back to ha_systemFontOfSize:weight: on older systems.
+ (UIFont *)ha_monospacedDigitSystemFontOfSize:(CGFloat)size weight:(CGFloat)weight;

@end
