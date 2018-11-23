//
//  HBTriangleV.m
//  TestPopMenu
//
//  Created by hubo on 2017/12/22.
//  Copyright © 2017年 hubo. All rights reserved.
//

#import "HBTriangleV.h"

@implementation HBTriangleV

- (void)setTriangleColor:(UIColor *)triangleColor {
    _triangleColor = triangleColor;
    [self setNeedsDisplay];//setNeedsDisplay:会自动调用drawRect方法
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [UIBezierPath bezierPath];     //绘制路径
//    [self.triangleColor set];    //设置颜色：在当前绘制上下文中设置填充和线段颜色
    //[_triangleColor set];
    
    //-------------绘制三角形------------
    //
    //                 B
    //                /\
    //               /  \
    //              /    \
    //             /______\
    //            A        C
    //
    //

    [path moveToPoint:CGPointMake(rect.size.width*0.2, rect.size.height)];  //设置起点 A
    [path addLineToPoint:CGPointMake(rect.size.width * 0.8,0)];    //拉线到某个点 B
    [path addLineToPoint:CGPointMake(rect.size.width*0.6, rect.size.height)];//拉线到某个点 C
    [path closePath];       //关闭路径
    [path fill];            //填充（会把颜色填充进去）
}




@end
