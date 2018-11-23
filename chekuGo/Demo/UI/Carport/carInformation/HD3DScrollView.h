//
//  HD3DScrollView.h
//  HD3DScrollView
//
//  Created by DennisHu
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HD3DScrollViewEffect) {
    HD3DScrollViewEffectNone,
    HD3DScrollViewEffectTranslation,
    HD3DScrollViewEffectDepth,
    HD3DScrollViewEffectCarousel,
    HD3DScrollViewEffectCards
};

@interface HD3DScrollView : UIScrollView

@property (nonatomic) HD3DScrollViewEffect effect;

@property (nonatomic) CGFloat angleRatio;

@property (nonatomic) CGFloat rotationX;
@property (nonatomic) CGFloat rotationY;
@property (nonatomic) CGFloat rotationZ;

@property (nonatomic) CGFloat translateX;
@property (nonatomic) CGFloat translateY;

- (NSUInteger)currentPage;

- (void)loadNextPage:(BOOL)animated;
- (void)loadPreviousPage:(BOOL)animated;
- (void)loadPageIndex:(NSUInteger)index animated:(BOOL)animated;

@end