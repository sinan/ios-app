#import <Foundation/Foundation.h>

/// Notification name posted when a non-command notification is received from HA.
/// userInfo contains the raw eventData dictionary with "title", "message", "data" fields.
extern NSString *const HADisplayNotificationReceivedNotification;

/// Listens for display notifications and presents them as in-app banners.
/// Queues multiple notifications and presents them sequentially.
@interface HANotificationPresenter : NSObject

+ (instancetype)sharedPresenter;

/// Start listening for HADisplayNotificationReceivedNotification.
- (void)start;

/// Stop listening and dismiss any active banner.
- (void)stop;

@end
