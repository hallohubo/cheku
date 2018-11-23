//
//  HDImageBrowser.h
//  JianJian
//
//  Created by Hu Dennis on 15/8/14.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDImageBrowser : NSObject
/*!
 @param oldView 动画开始前的位置所在的控件，可以是一个uiimageview，也可能是一个button
 @param url     图片的网络地址，要显示的图片有可能还没有下载下来
 */
+ (void)showWithView:(UIView *)oldView url:(NSURL *)url;
/*!
 @param imv     动画开始前的位置所在的UIImageView
 @discussion    这种情况是最单纯情形，就是现实UIImageView里的UIImage。
 */
+ (void)show:(UIImageView *)imv;
/*!
 @param oldView 动画开始前的位置所在的控件，可以是一个uiimageview，也可能是一个button
 @param img     图片
 */
+ (void)showWithView:(UIView *)oldView image:(UIImage *)img;
@end
