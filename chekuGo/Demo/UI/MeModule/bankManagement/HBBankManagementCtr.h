//
//  HBBankManagementCtr.h
//  Demo
//
//  Created by 胡勃 on 2018/2/10.
//  Copyright © 2018年 hufan. All rights reserved.
//
@class HBBankManageModel;

#import <UIKit/UIKit.h>


@interface HBBankManagementCtr : UIViewController

@end
@interface HBBankManageModel : NSObject
@property (nonatomic, strong) NSString *bankAccount;    // "string,账户名称",
@property (nonatomic, strong) NSString *bankName;       // "string,收款银行",
@property (nonatomic, strong) NSString *bankNo;         // "string,银行卡号",
@property (nonatomic, strong) NSString *companyId;      // 1516872328000,
@property (nonatomic, strong) NSString *createTime;     // "2018-02-09 14:40:03",
@property (nonatomic, strong) NSString *id;             // 1518158402000,
@property (nonatomic, strong) NSString *pkId;             // 1518158402000,
@property (nonatomic, strong) NSString *lastModifyTime; // "2018-02-09 14:40:03",
@property (nonatomic, strong) NSString *openingBank;    // "string,开户行",
@property (nonatomic, strong) NSString *parentId;       // null
@end
