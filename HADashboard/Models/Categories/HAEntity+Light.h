#import "HAEntity.h"
#import <UIKit/UIKit.h>

@interface HAEntity (Light)

// Existing (moved from HAEntity.m — do NOT redeclare in this header since they're already in HAEntity.h)
// - (NSInteger)brightness;
// - (NSInteger)brightnessPercent;

// New accessors
- (NSArray<NSString *> *)supportedColorModes;
- (NSString *)colorMode;
- (NSNumber *)colorTempKelvin;
- (NSNumber *)minColorTempKelvin;
- (NSNumber *)maxColorTempKelvin;
- (NSArray<NSNumber *> *)hsColor;           // [hue (0-360), saturation (0-100)]
- (NSArray<NSNumber *> *)rgbColor;          // [r, g, b] (0-255)
- (NSArray<NSNumber *> *)rgbwColor;         // [r, g, b, w] (0-255)
- (NSArray<NSNumber *> *)rgbwwColor;        // [r, g, b, cw, ww] (0-255)
- (NSArray<NSNumber *> *)xyColor;           // [x, y] (CIE 1931)
- (NSString *)effect;
- (NSArray<NSString *> *)effectList;

// Computed convenience
- (BOOL)supportsColorTemp;
- (BOOL)supportsHSColor;
- (BOOL)supportsEffects;

/// Returns the current color as a UIColor, derived from hs_color or rgb_color.
/// Returns nil if the light has no color information.
- (UIColor *)currentColor;

@end
