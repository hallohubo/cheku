//
//  HBTopUpDetailCtr.h
//  Demo
//
//  Created by 胡勃 on 2018/2/7.
//  Copyright © 2018年 hufan. All rights reserved.
//
@class HBTopUpDetailPageModel;

#import <UIKit/UIKit.h>

@interface HBTopUpDetailCtr : UIViewController
@property (nonatomic, copy) void(^cancelBlock)(void);
- (id)initWithTitle:(NSString *)titleState;
@end

@interface HBTopUpDetailPageModel : NSObject
@property (nonatomic, strong) NSString *companyId;      // 123453344,
@property (nonatomic, strong) NSString *createTime;     // "2018-02-03 10:21:07",
@property (nonatomic, strong) NSString *id;             // 1517613352411,
@property (nonatomic, strong) NSString *lastModifyTime; // "2018-02-03 10:21:07",
@property (nonatomic, strong) NSString *ordersMoney;    // 1231232,
@property (nonatomic, strong) NSString *ordersNo;       // 234234334234,
@property (nonatomic, strong) NSString *payMethod;      // "string,支付方式",
@property (nonatomic, strong) NSString *payStatus;      // "string,支付状态",
@property (nonatomic, strong) NSString *payTime;        // "string,支付时间",
@property (nonatomic, strong) NSString *renewNumber;    // 123
@end
