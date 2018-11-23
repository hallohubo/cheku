//
//  HBEditBankCtr.h
//  Demo
//
//  Created by 胡勃 on 2018/2/10.
//  Copyright © 2018年 hufan. All rights reserved.
//
@class HBEditBankMode;
#import <UIKit/UIKit.h>

@interface HBEditBankCtr : UIViewController
@property (nonatomic, copy) void(^finishUpBlock)(void);
- (instancetype)initWithString:(NSString *)addButtonConstent;
@end
@interface HBEditBankMode:NSObject
@property (nonatomic, strong) NSString *bankAccount;    // "你在干嘛",
@property (nonatomic, strong) NSString *bankName;       // "中国人民保险公司银行",
@property (nonatomic, strong) NSString *bankNo;         // "585236985241258",
@property (nonatomic, strong) NSString *companyId;      // 1516872328000,
@property (nonatomic, strong) NSString *companyName;    // null,
@property (nonatomic, strong) NSString *createTime;     // "2018-02-09 14:40:03",
@property (nonatomic, strong) NSString *id;             // 1518158402000,
@property (nonatomic, strong) NSString *lastModifyTime; // "2018-03-03 17:17:04",
@property (nonatomic, strong) NSString *openingBank;    // "中国人民保险公司银行",
@property (nonatomic, strong) NSString *parentId;       // null
@end

