#import "HABaseEntityCell.h"

/// Displays a todo list entity with item count and add button.
/// Full item listing requires WebSocket subscription (todo/item/list),
/// which is deferred. This cell shows the count and provides basic controls.
@interface HATodoEntityCell : HABaseEntityCell
@end
