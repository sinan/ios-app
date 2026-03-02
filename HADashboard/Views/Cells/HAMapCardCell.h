#import "HABaseEntityCell.h"
#import <MapKit/MapKit.h>

@class HADashboardConfigSection;

/// Map card: shows entity locations as annotations on an MKMapView.
@interface HAMapCardCell : HABaseEntityCell

- (void)configureWithSection:(HADashboardConfigSection *)section
                    entities:(NSDictionary<NSString *, HAEntity *> *)entities
                  configItem:(HADashboardConfigItem *)configItem;

@end
