#import <UIKit/UIKit.h>

/// A reusable toast banner that slides in from the top of a parent view.
/// Supports auto-dismiss, swipe-to-dismiss, and an optional tap action.
@interface HAToastView : UIView

/// Show a toast in the given parent view.
/// @param parentView    View to add the toast to.
/// @param message       Primary message text.
/// @param subtitle      Optional smaller hint text below the message (nil to omit).
/// @param duration      Seconds before auto-dismiss (0 to require manual dismiss).
/// @param tapAction     Block invoked when the user taps the toast (nil for no action).
+ (instancetype)showInView:(UIView *)parentView
                   message:(NSString *)message
                  subtitle:(NSString *)subtitle
                  duration:(NSTimeInterval)duration
                 tapAction:(void (^_Nullable)(void))tapAction;

/// Dismiss the toast with animation.
- (void)dismiss;

@end
