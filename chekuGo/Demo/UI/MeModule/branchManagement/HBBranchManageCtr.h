//
//  HBBranchManageCtr.h
//  Demo
//
//  Created by 胡勃 on 2018/1/26.
//Copyright © 2018年 hufan. All rights reserved.
//
@class HBBranchModel;

#import <UIKit/UIKit.h>

@interface HBBranchManageCtr : UIViewController

@end

@interface HBBranchModel : NSObject
@property (nonatomic, strong) NSString *address;            // "fdsa ",
@property (nonatomic, strong) NSString *areaId;             // null,
@property (nonatomic, strong) NSString *assetsCount;        // 0,
@property (nonatomic, strong) NSString *assetsUsed;         // 0,
@property (nonatomic, strong) NSString *balance;            // 0,
@property (nonatomic, strong) NSString *businessLicense;    // null,
@property (nonatomic, strong) NSString *cityId;             // null,
@property (nonatomic, strong) NSString *companyName;        // "gtdgfgfd",
@property (nonatomic, strong) NSString *contactsName;       // "fds",
@property (nonatomic, strong) NSString *contactsPhone;      // "fdsf",
@property (nonatomic, strong) NSString *createTime;         // "2018-02-09 20:56:50",
@property (nonatomic, strong) NSString *dueDate;            // 1549717010000,
@property (nonatomic, strong) NSString *freezeBalance;      // 0,
@property (nonatomic, strong) NSString *id;                 // 1518171296292,
@property (nonatomic, strong) NSString *lastModifyTime;     // "2018-02-09 20:56:50",
@property (nonatomic, strong) NSString *note;               // "fdsf",
@property (nonatomic, strong) NSString *parent;             // 1516872328000,
@property (nonatomic, strong) NSString *provinceId;         // null,
@property (nonatomic, strong) NSString *userNum;            //0
//@property (nonatomic, strong) NSString *companyId;
@end

