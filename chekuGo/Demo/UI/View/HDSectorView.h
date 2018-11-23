//
//  HDSectorView.h
//  Demo
//  画一个扇形
//  Created by hufan on 2017/3/2.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDSectorView : UIView
@property (assign, nonatomic) float ratio;
@property (nonatomic, strong) UIColor *color;
- (id)initWithFrame:(CGRect)frame point:(CGPoint)center startAngle:(CGFloat)star endAngle:(CGFloat)end color:(UIColor *)c;
@end
