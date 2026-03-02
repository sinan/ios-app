#import "HABaseEntityCell.h"

@class HADashboardConfigSection;

/// Area card: shows area name with optional picture/camera background,
/// aggregated sensor readings, and toggle controls for area entities.
@interface HAAreaCardCell : HABaseEntityCell

/// Configure with area section containing entity IDs resolved from the area.
- (void)configureWithSection:(HADashboardConfigSection *)section
                    entities:(NSDictionary<NSString *, HAEntity *> *)entities
                  configItem:(HADashboardConfigItem *)configItem;

@end
