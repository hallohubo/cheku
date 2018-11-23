//
//  HD3DScrollView.m
//  HD3DScrollView
//
//  Created by DennisHu
//

#import "HD3DScrollView.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation HD3DScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    [self commonInit];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    [self commonInit];
    return self;
}

- (void)commonInit
{
    self.pagingEnabled = YES;
    self.clipsToBounds = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator   = NO;
    self.effect = HD3DScrollViewEffectNone;
}

- (void)setEffect:(HD3DScrollViewEffect)effect
{
    self->_effect = effect;
    switch (effect) {
        case HD3DScrollViewEffectTranslation:
            self.angleRatio = 0.;
            self.rotationX  = 0.;
            self.rotationY  = 0.;
            self.rotationZ  = 0.;
            self.translateX = .25;
            self.translateY = .25;
            break;
        case HD3DScrollViewEffectDepth:
            self.angleRatio = .2;
            self.rotationX  = 0;
            self.rotationY  = 1.;
            self.rotationZ  = 0.;
            self.translateX = 0.;
            self.translateY = 0.;
            break;
        case HD3DScrollViewEffectCarousel:
            self.angleRatio = .5;
            self.rotationX  = -1.;
            self.rotationY  = 0.;
            self.rotationZ  = 0.;
            self.translateX = .25;
            self.translateY = .25;
            break;
        case HD3DScrollViewEffectCards:
            self.angleRatio = .5;
            self.rotationX  = -1.;
            self.rotationY  = -1.;
            self.rotationZ  = 0.;
            self.translateX = .25;
            self.translateY = .25;
            break;
        default:
            self.angleRatio = 0.;
            self.rotationX  = 0.;
            self.rotationY  = 0.;
            self.rotationZ  = 0.;
            self.translateX = 0.;
            self.translateY = 0.;
            break;
    }
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat contentOffsetX = self.contentOffset.x;
    for(UIView *view in self.subviews){
        CATransform3D t1 = view.layer.transform; // Hack for avoid visual bug
        view.layer.transform = CATransform3DIdentity;
        CGFloat distanceFromCenterX = view.frame.origin.x - contentOffsetX;
        view.layer.transform = t1;
        distanceFromCenterX = distanceFromCenterX * 100. / CGRectGetWidth(self.frame);
        CGFloat angle       = distanceFromCenterX * 0.15;
        CGFloat offset      = distanceFromCenterX;
        CGFloat translateX  = (CGRectGetWidth(self.frame) * 0.06) * offset / 100.;
        CGFloat translateY  = (CGRectGetWidth(self.frame) * 0.) * fabs(offset) / 100.;
        CATransform3D t = CATransform3DMakeTranslation(translateX, translateY, -fabs(offset));
        t.m34 = -1./500;
        t = CATransform3DScale(t, 1, 1 - pow(fabs(0.4*distanceFromCenterX/100), 2), 1);
        view.layer.transform = CATransform3DRotate(t, DEGREES_TO_RADIANS(angle), 0, 1, 0);
    }
}

- (NSUInteger)currentPage
{
    CGFloat pageWidth       = self.frame.size.width;
    float fractionalPage    = self.contentOffset.x / pageWidth;
    return lround(fractionalPage);
}

- (void)loadNextPage:(BOOL)animated
{
    [self loadPageIndex:self.currentPage + 1 animated:animated];
}

- (void)loadPreviousPage:(BOOL)animated
{
    [self loadPageIndex:self.currentPage - 1 animated:animated];
}

- (void)loadPageIndex:(NSUInteger)index animated:(BOOL)animated
{
    CGRect frame    = self.frame;
    frame.origin.x  = frame.size.width * index;
    frame.origin.y  = 0;
    [self scrollRectToVisible:frame animated:animated];
}

@end
