//
//  HBTopUpMoneyCtr.h
//  Demo
//
//  Created by 胡勃 on 2018/2/3.
//  Copyright © 2018年 hufan. All rights reserved.
//
@class HBChargeModel;
#import <UIKit/UIKit.h>

@interface HBTopUpMoneyCtr : UIViewController

@end
@interface HBChargeModel:NSObject
@property (nonatomic, strong) NSString *companyId;      // 123456,
@property (nonatomic, strong) NSString *createTime;     // "2018-01-28 18:01:45",
@property (nonatomic, strong) NSString *id;             // 1516831343858,
@property (nonatomic, strong) NSString *lastModifyTime; // "2018-01-28 18:01:45",
@property (nonatomic, strong) NSString *ordersMoney;    // 30000,
@property (nonatomic, strong) NSString *ordersNo;       // 90000,
@property (nonatomic, strong) NSString *payMethod;      // "支付宝",
@property (nonatomic, strong) NSString *payStatus;      // "处理中",
@property (nonatomic, strong) NSString *payTime;        // "today",
@property (nonatomic, strong) NSString *renewNumber;    // 1
@end
