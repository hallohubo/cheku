//
//  HDUMHelper.h
//  Demo
//
//  Created by hufan on 2017/3/1.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMMobClick/MobClick.h"
#import <UMSocialCore/UMSocialCore.h>

#define UmengAppKey         "5a308f2aa40fa3355b0000c4"  //友盟分享key
#define UmengStatistic      "55d2bb59e0f55a18ab00100a"  //友盟统计key
#define SinaAppKey          "4126668562"                //sina微博appkey
#define WechatAppId         "wx09ebbad2ac8e5236"        //微信appID
#define WechatAppSecret     "23796b4054dedfebde91d030af901c22" //AppSecret，3449857b3887cbfc9ef2aaa03792f039
#define WechatPayPartnerId  "1233397002"                //微信支付商户合作ID
#define QQAppId             "1102156782"
@interface HDUMHelper : NSObject

+ (void)setupAnalytics; //设置分析统计组件
+ (void)setupSocial;    //设置分享第三方登录组件
+ (void)getUserInfoForPlatform:(UMSocialPlatformType)platformType basedController:target complete:(void (^)(UMSocialUserInfoResponse *result, NSError *error))block;

+ (void)setupbeginLog:(NSString *)pageTitle;//设置页面统计：
+ (void)setupEndLog:(NSString *)pageTitle;//设置页面统计

@end
