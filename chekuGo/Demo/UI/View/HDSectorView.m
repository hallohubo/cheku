//
//  HDSectorView.m
//  Demo
//
//  Created by hufan on 2017/3/2.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import "HDSectorView.h"

@interface HDSectorView (){
    CGFloat percent;
    CGFloat startAngle;
    CGPoint point;
    CGFloat endAngle;
}

@end

@implementation HDSectorView

- (id)initWithFrame:(CGRect)frame point:(CGPoint)center startAngle:(CGFloat)star endAngle:(CGFloat)end color:(UIColor *)c
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        startAngle = star;
        endAngle = end;
        _color = c;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _color.CGColor);
    CGContextMoveToPoint(context, rect.size.width/2, rect.size.height/2);
    CGContextSetLineWidth(context, 0.);
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, rect.size.height/2, startAngle, endAngle, 0);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)setRatio:(float)ratio{
    if (ratio > 1 || ratio < 0) {
        Dlog(@"传入ratio值超限，%f", ratio);
        return;
    }
    percent = ratio;
    [self setNeedsDisplay];
}

- (void)setColor:(UIColor *)color{
    _color = color;
    if (!color) {
        _color = [UIColor blackColor];
    }
    [self setNeedsDisplay];
}

@end






