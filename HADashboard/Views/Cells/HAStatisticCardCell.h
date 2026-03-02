#import "HABaseEntityCell.h"

/// Statistic card: displays a statistical aggregation (min/max/mean/change/state)
/// for a sensor entity over a configurable period.
/// Note: min/max/mean/change require the HA statistics API which is not yet
/// implemented. Currently displays the entity's current state as a fallback.
@interface HAStatisticCardCell : HABaseEntityCell
@end
