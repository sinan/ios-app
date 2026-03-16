#import "HATopAlignedFlowLayout.h"
#import "HAColumnarLayout.h" // for isHeadingItemAtIndexPath: delegate method

@implementation HATopAlignedFlowLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *original = [super layoutAttributesForElementsInRect:rect];
    if (!original || original.count == 0) return original;

    // Copy attributes (required by UICollectionView)
    NSMutableArray *attrs = [NSMutableArray arrayWithCapacity:original.count];
    for (UICollectionViewLayoutAttributes *a in original) {
        [attrs addObject:[a copy]];
    }

    // Collect cell attributes only, sorted by center Y then X
    NSMutableArray<UICollectionViewLayoutAttributes *> *cells = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *a in attrs) {
        if (a.representedElementCategory == UICollectionElementCategoryCell) {
            [cells addObject:a];
        }
    }
    [cells sortUsingComparator:^NSComparisonResult(UICollectionViewLayoutAttributes *a, UICollectionViewLayoutAttributes *b) {
        CGFloat diff = CGRectGetMidY(a.frame) - CGRectGetMidY(b.frame);
        if (fabs(diff) < 1.0) {
            return CGRectGetMinX(a.frame) < CGRectGetMinX(b.frame) ? NSOrderedAscending : NSOrderedDescending;
        }
        return diff < 0 ? NSOrderedAscending : NSOrderedDescending;
    }];

    // Group into rows: items whose center-Y is within half the line spacing
    // of each other are on the same visual row.
    NSMutableArray<NSMutableArray *> *rows = [NSMutableArray array];
    NSMutableArray *currentRow = nil;
    CGFloat currentRowCenterY = 0;

    for (UICollectionViewLayoutAttributes *a in cells) {
        CGFloat centerY = CGRectGetMidY(a.frame);
        if (!currentRow || fabs(centerY - currentRowCenterY) > a.frame.size.height * 0.5) {
            // Start a new row
            currentRow = [NSMutableArray array];
            [rows addObject:currentRow];
            currentRowCenterY = centerY;
        }
        [currentRow addObject:a];
    }

    // For each row with multiple items, top-align all items
    for (NSMutableArray *row in rows) {
        if (row.count <= 1) continue;

        CGFloat minY = CGFLOAT_MAX;
        for (UICollectionViewLayoutAttributes *a in row) {
            if (a.frame.origin.y < minY) minY = a.frame.origin.y;
        }

        for (UICollectionViewLayoutAttributes *a in row) {
            CGRect frame = a.frame;
            frame.origin.y = minY;
            a.frame = frame;
        }
    }

    // Reduce spacing around heading cells: shift heading up to eat the line spacing
    // above it, and shift all subsequent items in the same section up by the same amount.
    // This makes heading items render with the same tight spacing as section headers.
    id delegate = self.collectionView.delegate;
    BOOL canQueryHeading = [delegate conformsToProtocol:@protocol(HAColumnarLayoutDelegate)] &&
                           [delegate respondsToSelector:@selector(collectionView:layout:isHeadingItemAtIndexPath:)];
    if (canQueryHeading) {
        id<HAColumnarLayoutDelegate> headingDelegate = (id<HAColumnarLayoutDelegate>)delegate;
        CGFloat lineSpacing = self.minimumLineSpacing;
        // Build a set of heading index paths
        NSMutableSet<NSIndexPath *> *headingPaths = [NSMutableSet set];
        for (UICollectionViewLayoutAttributes *a in attrs) {
            if (a.representedElementCategory == UICollectionElementCategoryCell) {
                if ([headingDelegate collectionView:self.collectionView layout:self isHeadingItemAtIndexPath:a.indexPath]) {
                    [headingPaths addObject:a.indexPath];
                }
            }
        }
        if (headingPaths.count > 0) {
            // For each heading, shift it and all subsequent items in its section up
            for (UICollectionViewLayoutAttributes *a in attrs) {
                if (a.representedElementCategory != UICollectionElementCategoryCell) continue;
                NSIndexPath *ip = a.indexPath;
                // Check if this item IS a heading or comes AFTER a heading in the same section
                for (NSIndexPath *hIP in headingPaths) {
                    if (ip.section == hIP.section) {
                        if (ip.item == hIP.item) {
                            // The heading itself: shift up by lineSpacing
                            CGRect f = a.frame;
                            f.origin.y -= lineSpacing;
                            a.frame = f;
                        } else if (ip.item == hIP.item + 1) {
                            // First item after heading: shift up by 2x line spacing
                            // (once to follow the heading's shift, once to remove the gap)
                            CGRect f = a.frame;
                            f.origin.y -= lineSpacing * 2;
                            a.frame = f;
                        } else if (ip.item > hIP.item + 1) {
                            // All subsequent items: shift up by 2x to stay consistent
                            CGRect f = a.frame;
                            f.origin.y -= lineSpacing * 2;
                            a.frame = f;
                        }
                    }
                }
            }
        }
    }

    return attrs;
}

@end
