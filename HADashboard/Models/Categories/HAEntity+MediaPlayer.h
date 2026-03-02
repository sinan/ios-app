#import "HAEntity.h"

@interface HAEntity (MediaPlayer)

// Existing in HAEntity.h: mediaTitle, mediaArtist, volumeLevel, isVolumeMuted, isPlaying, isPaused, isIdle

// New
- (NSNumber *)mediaDuration;
- (NSNumber *)mediaPosition;
- (NSString *)mediaAppName;
- (NSString *)mediaSoundMode;
- (NSArray<NSString *> *)mediaSoundModes;
- (NSString *)mediaSource;
- (NSArray<NSString *> *)mediaSourceList;
- (BOOL)mediaShuffle;
- (NSString *)mediaRepeat;  // "off", "all", "one"

@end
