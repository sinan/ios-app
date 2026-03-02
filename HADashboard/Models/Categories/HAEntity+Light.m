#import "HAEntity+Light.h"
#import "HAEntityAttributes.h"

@implementation HAEntity (Light)

#pragma mark - Existing (moved from HAEntity.m)

- (NSInteger)brightness {
    return HAAttrInteger(self.attributes, HAAttrBrightness, 0);
}

- (NSInteger)brightnessPercent {
    NSInteger raw = [self brightness];
    if (raw <= 0) return 0;
    return (NSInteger)round((raw / 255.0) * 100.0);
}

#pragma mark - Color Modes

- (NSArray<NSString *> *)supportedColorModes {
    return HAAttrArray(self.attributes, HAAttrSupportedColorModes);
}

- (NSString *)colorMode {
    return HAAttrString(self.attributes, HAAttrColorMode);
}

#pragma mark - Color Temperature

- (NSNumber *)colorTempKelvin {
    NSNumber *kelvin = HAAttrNumber(self.attributes, HAAttrColorTempKelvin);
    if (kelvin) return kelvin;
    // Fallback: convert from mireds (1,000,000 / mireds = kelvin)
    NSNumber *mireds = HAAttrNumber(self.attributes, @"color_temp");
    if (mireds && [mireds doubleValue] > 0) {
        return @(1000000.0 / [mireds doubleValue]);
    }
    return nil;
}

- (NSNumber *)minColorTempKelvin {
    NSNumber *kelvin = HAAttrNumber(self.attributes, HAAttrMinColorTempKelvin);
    if (kelvin) return kelvin;
    // Fallback: max_mireds → min_kelvin (inverse relationship)
    NSNumber *maxMireds = HAAttrNumber(self.attributes, @"max_mireds");
    if (maxMireds && [maxMireds doubleValue] > 0) {
        return @(1000000.0 / [maxMireds doubleValue]);
    }
    return nil;
}

- (NSNumber *)maxColorTempKelvin {
    NSNumber *kelvin = HAAttrNumber(self.attributes, HAAttrMaxColorTempKelvin);
    if (kelvin) return kelvin;
    // Fallback: min_mireds → max_kelvin (inverse relationship)
    NSNumber *minMireds = HAAttrNumber(self.attributes, @"min_mireds");
    if (minMireds && [minMireds doubleValue] > 0) {
        return @(1000000.0 / [minMireds doubleValue]);
    }
    return nil;
}

#pragma mark - HS Color

- (NSArray<NSNumber *> *)hsColor {
    return HAAttrArray(self.attributes, HAAttrHSColor);
}

#pragma mark - RGB / RGBW / RGBWW / XY Color

- (NSArray<NSNumber *> *)rgbColor {
    return HAAttrArray(self.attributes, @"rgb_color");
}

- (NSArray<NSNumber *> *)rgbwColor {
    return HAAttrArray(self.attributes, @"rgbw_color");
}

- (NSArray<NSNumber *> *)rgbwwColor {
    return HAAttrArray(self.attributes, @"rgbww_color");
}

- (NSArray<NSNumber *> *)xyColor {
    return HAAttrArray(self.attributes, @"xy_color");
}

#pragma mark - Effects

- (NSString *)effect {
    return HAAttrString(self.attributes, HAAttrEffect);
}

- (NSArray<NSString *> *)effectList {
    return HAAttrArray(self.attributes, HAAttrEffectList) ?: @[];
}

#pragma mark - Computed Convenience

- (BOOL)supportsColorTemp {
    NSArray<NSString *> *modes = [self supportedColorModes];
    if (modes) {
        return [modes containsObject:@"color_temp"];
    }
    // Fallback: check current color mode
    return [[self colorMode] isEqualToString:@"color_temp"];
}

- (BOOL)supportsHSColor {
    NSArray<NSString *> *modes = [self supportedColorModes];
    if (modes) {
        static NSSet *colorModes = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            colorModes = [NSSet setWithObjects:@"hs", @"xy", @"rgb", @"rgbw", @"rgbww", nil];
        });
        for (NSString *mode in modes) {
            if ([colorModes containsObject:mode]) return YES;
        }
        return NO;
    }
    // Fallback: check current color mode
    NSString *current = [self colorMode];
    if (!current) return NO;
    static NSSet *fallbackModes = nil;
    static dispatch_once_t fallbackToken;
    dispatch_once(&fallbackToken, ^{
        fallbackModes = [NSSet setWithObjects:@"hs", @"xy", @"rgb", @"rgbw", @"rgbww", nil];
    });
    return [fallbackModes containsObject:current];
}

- (BOOL)supportsEffects {
    return [self effectList].count > 0;
}

#pragma mark - Current Color

- (UIColor *)currentColor {
    // Try hs_color first (most common)
    NSArray<NSNumber *> *hs = [self hsColor];
    if (hs.count >= 2) {
        CGFloat hue = [hs[0] doubleValue] / 360.0;
        CGFloat sat = [hs[1] doubleValue] / 100.0;
        return [UIColor colorWithHue:hue saturation:sat brightness:1.0 alpha:1.0];
    }
    // Fallback: rgb_color
    NSArray<NSNumber *> *rgb = [self rgbColor];
    if (rgb.count >= 3) {
        return [UIColor colorWithRed:[rgb[0] doubleValue] / 255.0
                               green:[rgb[1] doubleValue] / 255.0
                                blue:[rgb[2] doubleValue] / 255.0
                               alpha:1.0];
    }
    // Fallback: rgbw_color (ignore white channel for display)
    NSArray<NSNumber *> *rgbw = [self rgbwColor];
    if (rgbw.count >= 3) {
        return [UIColor colorWithRed:[rgbw[0] doubleValue] / 255.0
                               green:[rgbw[1] doubleValue] / 255.0
                                blue:[rgbw[2] doubleValue] / 255.0
                               alpha:1.0];
    }
    return nil;
}

@end
