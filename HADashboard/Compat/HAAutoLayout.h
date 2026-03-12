#import <UIKit/UIKit.h>

/// iOS 5-safe UICollectionElementKindSectionHeader.
/// The extern NSString *const is nil on iOS 5 (UIKit doesn't define it).
/// PSTCollectionView uses the same string value internally.
static inline NSString *HACollectionElementKindSectionHeader(void) {
    return UICollectionElementKindSectionHeader ?: @"UICollectionElementKindSectionHeader";
}

static inline NSString *HACollectionElementKindSectionFooter(void) {
    return UICollectionElementKindSectionFooter ?: @"UICollectionElementKindSectionFooter";
}

/// iOS 5-safe system major version check.
/// NSProcessInfo.operatingSystemVersion is iOS 8+.  On older systems
/// parse [[UIDevice currentDevice] systemVersion] instead.
static inline NSInteger HASystemMajorVersion(void) {
    static NSInteger ver = -1;
    if (ver < 0) {
        if ([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
            ver = [NSProcessInfo processInfo].operatingSystemVersion.majorVersion;
        } else {
            ver = [[[UIDevice currentDevice] systemVersion] integerValue];
        }
    }
    return ver;
}

/// Force-disable Auto Layout for testing iOS 5 layout fallbacks on modern devices.
/// Set via developer settings toggle.  Defaults to NO.
static inline BOOL HAForceDisableAutoLayout(void) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"HAForceDisableAutoLayout"];
}

/// Returns YES if Auto Layout (NSLayoutConstraint) is available at runtime
/// AND the developer hasn't force-disabled it for testing.
/// On iOS 5.x this returns NO.  On iOS 6+ this returns YES (unless overridden).
static inline BOOL HAAutoLayoutAvailable(void) {
    if (HAForceDisableAutoLayout()) return NO;
    static BOOL checked = NO, available = NO;
    if (!checked) {
        available = (NSClassFromString(@"NSLayoutConstraint") != nil);
        checked = YES;
    }
    return available;
}
