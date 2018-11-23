//
//  HDGlobleInfo.h
//  HDStudio
//
//  Created by Hu Dennis on 14/12/12.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HDUserModel.h"

#define HDGI [HDGlobal instance]

#define HDNOTI_DID_TAP_TABBAR_INDEX @"HDNOTI_DID_TAP_TABBAR_INDEX"
#define HBNOTI_DID_TAP_TABBAR_INDEX @"HBNOTI_DID_TAP_TWO"

@interface HDGlobal : NSObject

@property (nonatomic, strong) HDLoginUserModel *loginUser;  //登录用户
@property (nonatomic, strong) NSString *token;             
@property (nonatomic, strong) UINavigationController *nav;  //大厦基石导航控件
@property (nonatomic, strong) NSString *signCarId;          //计划签约的汽车编号，因为要跨好几个页面，放这里省事
@property (nonatomic, strong) NSString *carNumber;          //计划签约的汽车车牌，因为要跨好几个页面，放这里省事
@property (nonatomic, strong) NSString *carBrand;          //计划签约的汽车品牌，因为要跨好几个页面，放这里省事，
+ (HDGlobal *)instance;

@end
