//
//  HDImageBrowser.m
//  JianJian
//
//  Created by Hu Dennis on 15/8/14.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDImageBrowser.h"

static CGRect oldframe;
@implementation HDImageBrowser
+ (void)show:(UIImageView *)imv{
    if (!imv) {
        return;
    }
    [self showWithView:imv image:imv.image];
}

+ (void)showWithView:(UIView *)oldView url:(NSURL *)url{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if (!oldView || !url) {
        Dlog(@"Error:传入参数有误！");
        return;
    }
    UIImage *image          = HDIMAGE(@"placeHold");
    UIWindow *window        = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    oldframe                = [oldView convertRect:oldView.bounds toView:window];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha    = 0;
    UIImageView *imageView  = [[UIImageView alloc]initWithFrame:oldframe];
    imageView.image         = image;
    imageView.tag           = 1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = CGRectMake(0,([UIScreen mainScreen].bounds.size.height - image.size.height * [UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha = 1;
//        [[SDWebImageManager sharedManager] downloadWithURL:url options:SDWebImageContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
//            if (!image) {
//                imageView.image = HDIMAGE(@"falseImage");
//                return ;
//            }
//            imageView.image = image;
//            imageView.frame = CGRectMake(0,([UIScreen mainScreen].bounds.size.height - image.size.height * [UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
//        }];
    } completion:^(BOOL finished) {
        
    }];
}

+ (void)showWithView:(UIView *)oldView image:(UIImage *)img{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    if (!oldView || !img) {
        Dlog(@"Error:传入参数有误！");
        return;
    }
    UIImage *image          = img;
    UIWindow *window        = [UIApplication sharedApplication].keyWindow;
    UIView *backgroundView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    oldframe                = [oldView convertRect:oldView.bounds toView:window];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha    = 0;
    UIImageView *imageView  = [[UIImageView alloc]initWithFrame:oldframe];
    imageView.image         = image;
    imageView.tag           = 1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer: tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = CGRectMake(0,([UIScreen mainScreen].bounds.size.height - image.size.height * [UIScreen mainScreen].bounds.size.width/image.size.width)/2, [UIScreen mainScreen].bounds.size.width, image.size.height*[UIScreen mainScreen].bounds.size.width/image.size.width);
        backgroundView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

+ (void)hideImage:(UITapGestureRecognizer*)tap{
    UIView *backgroundView = tap.view;
    UIImageView *imageView = (UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = oldframe;
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
    }];
}

@end
