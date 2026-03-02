#import "HARemoteEntityCell.h"
#import "HAEntity.h"
#import "HADashboardConfig.h"
#import "HATheme.h"
#import "HASwitch.h"
#import "HAHaptics.h"

@interface HARemoteEntityCell ()
@property (nonatomic, strong) UISwitch *toggleSwitch;
@property (nonatomic, strong) UIButton *activityButton;
@end

@implementation HARemoteEntityCell

- (void)setupSubviews {
    [super setupSubviews];
    self.stateLabel.hidden = YES;

    CGFloat padding = 10.0;

    self.toggleSwitch = [[HASwitch alloc] init];
    self.toggleSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toggleSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.toggleSwitch];

    self.activityButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.activityButton.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    [self.activityButton setTitleColor:[HATheme secondaryTextColor] forState:UIControlStateNormal];
    self.activityButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.activityButton.hidden = YES;
    [self.activityButton addTarget:self action:@selector(activityTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.activityButton];

    [NSLayoutConstraint activateConstraints:@[
        [self.toggleSwitch.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-padding],
        [self.toggleSwitch.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:padding],
        [self.activityButton.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:padding],
        [self.activityButton.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-padding],
    ]];
}

- (void)configureWithEntity:(HAEntity *)entity configItem:(HADashboardConfigItem *)configItem {
    [super configureWithEntity:entity configItem:configItem];
    self.stateLabel.hidden = YES;

    BOOL isOn = [entity.state isEqualToString:@"on"];
    self.toggleSwitch.on = isOn;
    self.toggleSwitch.enabled = entity.isAvailable;

    NSString *activity = entity.attributes[@"current_activity"];
    NSArray *activities = entity.attributes[@"activity_list"];
    if ([activity isKindOfClass:[NSString class]] && [activities isKindOfClass:[NSArray class]] && activities.count > 0) {
        [self.activityButton setTitle:[NSString stringWithFormat:@"%@ \u25BE", activity] forState:UIControlStateNormal];
        self.activityButton.hidden = NO;
        self.activityButton.enabled = entity.isAvailable;
    } else {
        self.activityButton.hidden = YES;
    }

    self.contentView.backgroundColor = isOn ? [HATheme onTintColor] : [HATheme cellBackgroundColor];
}

- (void)switchToggled:(UISwitch *)sender {
    [HAHaptics lightImpact];
    [self callService:sender.isOn ? @"turn_on" : @"turn_off" inDomain:@"remote"];
}

- (void)activityTapped {
    NSArray *activities = self.entity.attributes[@"activity_list"];
    if (![activities isKindOfClass:[NSArray class]] || activities.count == 0) return;
    UIResponder *responder = self;
    while (responder && ![responder isKindOfClass:[UIViewController class]]) responder = [responder nextResponder];
    UIViewController *vc = (UIViewController *)responder;
    if (!vc) return;

    NSString *current = self.entity.attributes[@"current_activity"];
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil
                                                           preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *act in activities) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:act style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *a) {
            [HAHaptics lightImpact];
            [self callService:@"turn_on" inDomain:@"remote" withData:@{@"activity": act}];
        }];
        if ([act isEqualToString:current]) [action setValue:@YES forKey:@"checked"];
        [sheet addAction:action];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    sheet.popoverPresentationController.sourceView = self.activityButton;
    sheet.popoverPresentationController.sourceRect = self.activityButton.bounds;
    [vc presentViewController:sheet animated:YES completion:nil];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.toggleSwitch.on = NO;
    self.activityButton.hidden = YES;
    self.contentView.backgroundColor = [HATheme cellBackgroundColor];
}

@end
