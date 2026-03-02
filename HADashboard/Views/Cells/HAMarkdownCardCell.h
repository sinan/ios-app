#import <UIKit/UIKit.h>

@class HADashboardConfigItem;

/// Renders markdown content as formatted text.
/// Note: Jinja2 templates are not evaluated — content is rendered as-is.
@interface HAMarkdownCardCell : UICollectionViewCell

- (void)configureWithConfigItem:(HADashboardConfigItem *)configItem;

+ (CGFloat)preferredHeightForConfigItem:(HADashboardConfigItem *)configItem width:(CGFloat)width;

@end
