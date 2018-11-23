//
//  HBWithGetMoneyCtr.h
//  Demo
//
//  Created by 胡勃 on 2018/2/7.
//  Copyright © 2018年 hufan. All rights reserved.
//
@class HBWithdrawalRecordModel;
#import <UIKit/UIKit.h>

@interface HBWithGetMoneyCtr : UIViewController

@end
@interface HBWithdrawalRecordModel : NSObject           //"bankAccount": "账户名称",
@property (nonatomic, strong) NSString *bankAccount;
@property (nonatomic, strong) NSString *bankId;      // 111,
@property (nonatomic, strong) NSString *bankName;      // "收款银行:ccb",
@property (nonatomic, strong) NSString *bankNo;      // 622900887765546,
@property (nonatomic, strong) NSString *companyName;      // "风格公司",
@property (nonatomic, strong) NSString *createTime;      // "2018-02-04 17:37:06",
@property (nonatomic, strong) NSString *handleTime;      // 1513612800000,
@property (nonatomic, strong) NSString *id;      // 1517726539450,
@property (nonatomic, strong) NSString *lastModifyTime;      // "2018-02-04 17:37:06",
@property (nonatomic, strong) NSString *note;      // "2018-02-05",
@property (nonatomic, strong) NSString *openingBank;      // "开户行",
@property (nonatomic, strong) NSString *receipt;      // "string,回执单据",
@property (nonatomic, strong) NSString *status;      // "处理中",
@property (nonatomic, strong) NSString *surplus;      // 5555,
@property (nonatomic, strong) NSString *widthdrawMoney;      // 2000,
@property (nonatomic, strong) NSString *widthdrawTime;      // 1513612800000
@end
