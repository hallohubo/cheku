//
//  HDAppHelper.h
//  Demo
//
//  Created by hufan on 2017/2/28.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UUID_KEY        @"UUID_KEY"
#define PRODUCTTYPE     @"producttype"
#define HDNavigationBarHidden self.tabBarController.navigationController.navigationBarHidden

//存储本地key
#define USER_LOCATION @"USER_LOCATION"

#define vacationReasonLendth 100    //请假原因说明最大限制字数
#define vocationWorkHandover 100    //请假工作交接说明最大限制字数
#define overtimeReasonLendth 100    //加班原因说明
#define doPassRemarkLendth   100    //审批意见字数限制

typedef NS_ENUM(int, HDApproveStatus){
    HDApproveStatusDepending = 1,   //待审批
    HDApproveStatusSuccess   = 2,   //已审批
    HDApproveStatusRefused   = 3,   //不通过
};

@interface HDAppHelper : NSObject

+ (UIViewController *)builder;
+ (void)setAppearence;

+ (id)readTokenFromLocal;
+ (BOOL)saveTokenToLocal:(NSString *)token;
+ (void)clearTokenFromLocal;

@end
