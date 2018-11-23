//
//  UIImage+Color.m
//  JianJian
//
//  Created by hufan on 16/5/4.
//  Copyright © 2016年 Hu Dennis. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

- (id)color:(UIColor *)color{
    // begin a new image context, to draw our colored image onto with the right scale
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextDrawImage(context, rect, self.CGImage);
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

- (id)theamColor{
    return [self color:HDCOLOR_THEME];
}

- (id)blackColor{
    return [self color:[UIColor blackColor]];
}

- (id)whiteColor{
    return [self color:[UIColor whiteColor]];
}

- (id)grayColor{
    return [self color:[UIColor grayColor]];
}

- (id)blueColor{
    return [self color:[UIColor blueColor]];
}

@end
