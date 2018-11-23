//
//  HBFinancialCtr.h
//  Demo
//
//  Created by 胡勃 on 2018/2/2.
//Copyright © 2018年 hufan. All rights reserved.
//

@class HBFinancialtModel;
#import <UIKit/UIKit.h>

@interface HBFinancialCtr : UIViewController

- (id)initWithStatus:(NSString *)status;
- (id)initWithBargainId:(NSString *)bargainId;

@end
@interface HBFinancialtModel : NSObject
@property (nonatomic, strong) NSString *bargainId;              // 100911811111,
@property (nonatomic, strong) NSString *bargainType;            // "普通合同",
@property (nonatomic, strong) NSString *companyId;              // 111111111234,
@property (nonatomic, strong) NSString *companyUserId;          // 111111111234,
@property (nonatomic, strong) NSString *companyUserRealname;    // "对接：小三",
@property (nonatomic, strong) NSString *createTime;             // "2018-01-28 14:02:24",
@property (nonatomic, strong) NSString *id;                     // 1516831343343,
@property (nonatomic, strong) NSString *lastModifyTime;         // "2018-01-28 14:02:24",
@property (nonatomic, strong) NSString *memberId;               // 20101022222,
@property (nonatomic, strong) NSString *memberRealname;         // "客户：小四",
@property (nonatomic, strong) NSString *ordersDate;             // 1888818182000,
@property (nonatomic, strong) NSString *ordersMoney;            // 100000,
@property (nonatomic, strong) NSString *ordersType;             // "订单类型",
@property (nonatomic, strong) NSString *payDate;                // 2018112000,
@property (nonatomic, strong) NSString *payMethod;              // "支付宝",
@property (nonatomic, strong) NSString *status;                 // "已支付"

@end
