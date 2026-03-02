#import "HABaseEntityCell.h"

@class HADashboardConfigSection;

/// Picture-glance card: image background with entity state icon overlays.
@interface HAPictureGlanceCardCell : HABaseEntityCell

- (void)configureWithSection:(HADashboardConfigSection *)section
                    entities:(NSDictionary<NSString *, HAEntity *> *)entities
                  configItem:(HADashboardConfigItem *)configItem;

@end
