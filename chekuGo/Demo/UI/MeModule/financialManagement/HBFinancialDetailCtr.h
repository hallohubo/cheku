//
//  HBFinancialDetailCtr.h
//  Demo
//
//  Created by 胡勃 on 2018/2/18.
//  Copyright © 2018年 hufan. All rights reserved.
//
@class HBFinancialDetailModel;
@class HBForContractModel;
@class HBPricingMode;
#import <UIKit/UIKit.h>

@interface HBFinancialDetailCtr : UIViewController
@property (nonatomic, copy) void(^cancelBlock)(void);
- (id)initWithOrderNo:(NSString *)no company:(NSString *)companyId showAssociatedBtn:(BOOL)isHidden;
@end

@interface HBFinancialDetailModel : NSObject

@property (nonatomic, strong) NSString *bargainId;   // 1520999497734,
@property (nonatomic, strong) NSString *bargainNo;   // "bdjdjdjf",
@property (nonatomic, strong) NSString *bargainType;   // "经租合同",
@property (nonatomic, strong) NSString *companyId;   // 1519389581379,
@property (nonatomic, strong) NSString *companyUserId;   // 1519404411010,
@property (nonatomic, strong) NSString *companyUserRealname;   // "分公司二分公司最高管理员",
@property (nonatomic, strong) NSString *createTime;   // "2018-03-14 12:44:01",
@property (nonatomic, strong) NSString *deposit;   // 10000,
@property (nonatomic, strong) NSString *id;   // 1520999497735,
@property (nonatomic, strong) NSString *isExpire;   // 0,
@property (nonatomic, strong) NSString *lastModifyTime;   // "2018-03-14 12:44:19",
@property (nonatomic, strong) NSString *memberId;   // 1519806930020,
@property (nonatomic, strong) NSString *memberRealname;   // "李嘉楠",
@property (nonatomic, strong) NSString *note;   // "hdhdhd",
@property (nonatomic, strong) NSString *ordersDate;   // null,
@property (nonatomic, strong) NSString *ordersMoney;   // 10288,
@property (nonatomic, strong) NSString *ordersType;   // "押金+首月租金",
@property (nonatomic, strong) NSString *parentId;   // 1519389581358,
@property (nonatomic, strong) NSString *payDate;   // null,
@property (nonatomic, strong) NSString *payMethod;   // "UnionPay",
@property (nonatomic, strong) NSString *pkId;   // 1520999497735,
@property (nonatomic, strong) NSString *rent;   // 288,
@property (nonatomic, strong) NSString *rentDay;   // 15,
@property (nonatomic, strong) NSString *status;   // "未支付",
@property (nonatomic, strong) NSString *vehicleBrand;   // "分公司二的揽胜运动SALWA2VF",
@property (nonatomic, strong) NSString *vehicleId;   // 1520245576050,
@property (nonatomic, strong) NSString *vehicleNo;   // "闽B7900M"

@end

@interface HBForContractModel : NSObject
@property (nonatomic, strong) NSString *bargainContent;     // null,
@property (nonatomic, strong) NSString *bargainNo;          // "1111111",
@property (nonatomic, strong) NSString *bargainType;        // "0",
@property (nonatomic, strong) NSString *companyId;          // 1516872328000,
@property (nonatomic, strong) NSString *companyUserId;      // 1517750314001,
@property (nonatomic, strong) NSString *companyUserRealname;// "张三",
@property (nonatomic, strong) NSString *createTime;         // "2018-02-18 21:26:40",
@property (nonatomic, strong) NSString *deposit;            // 23333,
@property (nonatomic, strong) NSString *endDate;            // "2018-02-18 00:00:00",
@property (nonatomic, strong) NSString *id;                 // 1518891370796,
@property (nonatomic, strong) NSString *isExpire;           // 0,
@property (nonatomic, strong) NSString *lastModifyTime;     // "2018-02-18 21:26:40",
@property (nonatomic, strong) NSString *parentId;           // 1,
@property (nonatomic, strong) NSString *rent;               // 200,
@property (nonatomic, strong) NSString *rentDay;            // 17,
@property (nonatomic, strong) NSString *signCardId;         // "348467684848464",
@property (nonatomic, strong) NSString *signDate;           // null,
@property (nonatomic, strong) NSString *signMemberId;       // 1518774928848,
@property (nonatomic, strong) NSString *signRealname;       // "地名",
@property (nonatomic, strong) NSString *startDate;          // "2016-02-18 00:00:00",
@property (nonatomic, strong) NSString *vehicleBrand;       // "string,品牌型号",
@property (nonatomic, strong) NSString *vehicleId;          // 1518341415281,
@property (nonatomic, strong) NSString *vehicleNo;          // "string,车辆号码"
@end

@interface HBPricingMode : NSObject
@property (nonatomic, strong) NSString *changeAction;       // null,
@property (nonatomic, strong) NSString *createTime;         // "1111111",
@property (nonatomic, strong) NSString *id;                 // "0",
@property (nonatomic, strong) NSString *lastModifyTime;     // 2018-09-08 15:49:59
@property (nonatomic, strong) NSString *money;              // 1517750314001,
@property (nonatomic, strong) NSString *note;               // "张三",
@property (nonatomic, strong) NSString *ordersNo;           // 1535126400385,
@property (nonatomic, strong) NSString *pkId;               // 23333,

@end

