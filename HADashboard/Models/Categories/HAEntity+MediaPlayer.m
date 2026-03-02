#import "HAEntity+MediaPlayer.h"

@implementation HAEntity (MediaPlayer)

- (NSNumber *)mediaDuration {
    return HAAttrNumber(self.attributes, HAAttrMediaDuration);
}

- (NSNumber *)mediaPosition {
    return HAAttrNumber(self.attributes, HAAttrMediaPosition);
}

- (NSString *)mediaAppName {
    return HAAttrString(self.attributes, HAAttrAppName);
}

- (NSString *)mediaSoundMode {
    return HAAttrString(self.attributes, HAAttrSoundMode);
}

- (NSArray<NSString *> *)mediaSoundModes {
    return HAAttrArray(self.attributes, HAAttrSoundModeList) ?: @[];
}

- (NSString *)mediaSource {
    return HAAttrString(self.attributes, @"source");
}

- (NSArray<NSString *> *)mediaSourceList {
    return HAAttrArray(self.attributes, @"source_list") ?: @[];
}

- (BOOL)mediaShuffle {
    return HAAttrBool(self.attributes, @"shuffle", NO);
}

- (NSString *)mediaRepeat {
    return HAAttrString(self.attributes, @"repeat") ?: @"off";
}

@end
