//
//  HDImageHelper.h
//  Demo
//
//  Created by hufan on 2017/12/1.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDImageHelper : NSObject
//等比率缩放
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;
//自定长宽
+ (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;
//将图片缩减到1M以内
+ (UIImage *)resizeImage:(UIImage *)img_original;
/*
处理某个特定View
只要是继承UIView的object 都可以处理
必须先import QuzrtzCore.framework
*/
+ (UIImage*)captureView:(UIView *)theView;
//旋转图片
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

//将图片变灰
+ (UIImage *)getGrayImage:(UIImage *)sourceImage;
//截屏
+ (UIImage *)screenshotFromView:(UIView *)theView;
//获得某个范围内的屏幕图像
+ (UIImage *)screenshotFromView: (UIView *)theView atFrame:(CGRect)r;
@end
