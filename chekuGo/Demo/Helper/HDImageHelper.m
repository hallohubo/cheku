//
//  HDImageHelper.m
//  Demo
//
//  Created by hufan on 2017/12/1.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import "HDImageHelper.h"

@implementation HDImageHelper

//等比率缩放
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

//自定长宽
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}
                                
/*
处理某个特定View
只要是继承UIView的object 都可以处理
必须先import QuzrtzCore.framework
 */
+ (UIImage*)captureView:(UIView *)theView{
    CGRect rect = theView.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

//旋转图片
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation{
    UIImage *imageToDisplay = [UIImage imageWithCGImage:[image CGImage] scale:1. orientation: orientation];
    return imageToDisplay;
}

+ (UIImage *)resizeImage:(UIImage *)img_original{
    if (!img_original) {
        Dlog(@"Error:传入参数错误");
        return nil;
    }
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.3f;
    NSData *imageData = UIImageJPEGRepresentation(img_original, compression);
    while ([imageData length] > 1024 * 1024 && compression > maxCompression) {
        compression -= 0.1;
        Dlog(@"compression = %f", compression);
        imageData = UIImageJPEGRepresentation(img_original, compression);
    }
    Dlog(@"imageData = %lu", (unsigned long)imageData.length);
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}

+ (UIImage *)getGrayImage:(UIImage *)sourceImage{
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil, width, height, 8, 0, colorSpace, kCGBitmapByteOrderDefault);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), sourceImage.CGImage);
    CGImageRef grayImageRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage:grayImageRef];
    CGContextRelease(context);
    CGImageRelease(grayImageRef);
    return grayImage;
}

//截屏
+ (UIImage *)screenshotFromView:(UIView *)theView{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context    = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage       = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

//获得某个范围内的屏幕图像
+ (UIImage *)screenshotFromView: (UIView *)theView atFrame:(CGRect)r{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context    = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(r);
    [theView.layer renderInContext:context];
    UIImage *theImage       = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  theImage;//[self getImageAreaFromImage:theImage atFrame:r];
}

@end
