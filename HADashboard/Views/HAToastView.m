#import "HAToastView.h"

@interface HAToastView ()
@property (nonatomic, strong) NSTimer *dismissTimer;
@property (nonatomic, strong) NSLayoutConstraint *topConstraint;
@property (nonatomic, copy) void (^tapAction)(void);
@end

@implementation HAToastView

+ (instancetype)showInView:(UIView *)parentView
                   message:(NSString *)message
                  subtitle:(NSString *)subtitle
                  duration:(NSTimeInterval)duration
                 tapAction:(void (^)(void))tapAction {
    HAToastView *toast = [[HAToastView alloc] init];
    toast.translatesAutoresizingMaskIntoConstraints = NO;
    toast.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
    toast.layer.cornerRadius = 12;
    toast.clipsToBounds = YES;
    toast.alpha = 0;
    toast.tapAction = tapAction;

    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = message;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    label.numberOfLines = 0;
    label.textAlignment = NSTextAlignmentCenter;
    [toast addSubview:label];

    UIView *bottomAnchorView = label;

    if (subtitle.length > 0) {
        UILabel *hint = [[UILabel alloc] init];
        hint.translatesAutoresizingMaskIntoConstraints = NO;
        hint.text = subtitle;
        hint.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        hint.font = [UIFont systemFontOfSize:11];
        hint.textAlignment = NSTextAlignmentCenter;
        [toast addSubview:hint];

        [NSLayoutConstraint activateConstraints:@[
            [hint.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:4],
            [hint.leadingAnchor constraintEqualToAnchor:toast.leadingAnchor constant:16],
            [hint.trailingAnchor constraintEqualToAnchor:toast.trailingAnchor constant:-16],
        ]];
        bottomAnchorView = hint;
    }

    [parentView addSubview:toast];

    [NSLayoutConstraint activateConstraints:@[
        [toast.centerXAnchor constraintEqualToAnchor:parentView.centerXAnchor],
        [toast.widthAnchor constraintLessThanOrEqualToAnchor:parentView.widthAnchor multiplier:0.9],
        [toast.widthAnchor constraintGreaterThanOrEqualToConstant:260],
        [label.topAnchor constraintEqualToAnchor:toast.topAnchor constant:12],
        [label.leadingAnchor constraintEqualToAnchor:toast.leadingAnchor constant:16],
        [label.trailingAnchor constraintEqualToAnchor:toast.trailingAnchor constant:-16],
        [bottomAnchorView.bottomAnchor constraintEqualToAnchor:toast.bottomAnchor constant:-12],
    ]];

    // Start off-screen, animate in
    toast.topConstraint = [toast.topAnchor constraintEqualToAnchor:parentView.topAnchor constant:-80];
    toast.topConstraint.active = YES;
    [parentView layoutIfNeeded];

    CGFloat topInset = 12;
    if (@available(iOS 11.0, *)) {
        topInset = parentView.safeAreaInsets.top + 12;
    }
    toast.topConstraint.constant = topInset;

    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.5 options:0 animations:^{
        toast.alpha = 1;
        [parentView layoutIfNeeded];
    } completion:nil];

    // Tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:toast action:@selector(handleTap)];
    [toast addGestureRecognizer:tap];

    // Swipe up to dismiss
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:toast action:@selector(dismiss)];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [toast addGestureRecognizer:swipe];

    // Auto-dismiss
    if (duration > 0) {
        toast.dismissTimer = [NSTimer scheduledTimerWithTimeInterval:duration
                                                              target:toast
                                                            selector:@selector(dismiss)
                                                            userInfo:nil
                                                             repeats:NO];
    }

    return toast;
}

- (void)handleTap {
    void (^action)(void) = self.tapAction;
    [self dismiss];
    if (action) {
        action();
    }
}

- (void)dismiss {
    [self.dismissTimer invalidate];
    self.dismissTimer = nil;
    if (!self.superview) return;
    self.topConstraint.constant = -80;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
