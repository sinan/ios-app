#import <UIKit/UIKit.h>

@class HAEntity;

/// A single item in a Glance card: vertically stacked icon, name, and state.
@interface HAGlanceItemView : UIView

/// Configure the view with an entity and per-entity config options.
/// @param entity The entity to display (may be nil if not found)
/// @param config Per-entity config dict (name, icon, show_state, tap_action, etc.)
/// @param showName Card-level show_name setting
/// @param showState Card-level show_state setting
/// @param showIcon Card-level show_icon setting
/// @param stateColor Card-level state_color setting
- (void)configureWithEntity:(HAEntity *)entity
                entityConfig:(NSDictionary *)config
                    showName:(BOOL)showName
                   showState:(BOOL)showState
                    showIcon:(BOOL)showIcon
                  stateColor:(BOOL)stateColor;

/// The entity displayed by this item (nil if unconfigured or entity not found).
@property (nonatomic, weak, readonly) HAEntity *entity;

/// Per-entity action config (tap_action, hold_action, double_tap_action).
@property (nonatomic, copy, readonly) NSDictionary *actionConfig;

/// Preferred height based on which elements are shown.
+ (CGFloat)preferredHeightShowingName:(BOOL)showName showState:(BOOL)showState showIcon:(BOOL)showIcon;

@end
