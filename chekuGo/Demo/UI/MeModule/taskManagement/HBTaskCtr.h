//
//  HBContractCtr.h
//  Demo
//
//  Created by 胡勃 on 2018/1/19.
//  Copyright © 2018年 hufan. All rights reserved.
//
@class HBTaskModel;

#import <UIKit/UIKit.h>

@interface HBTaskCtr : UIViewController
- (id)initWithTaskStatus:(BOOL)complete;
- (id)initWithTaskIsExpired:(BOOL)isExpired;
@end
@interface HBTaskModel : NSObject
@property (nonatomic, strong) NSString *completeDate;           // null,
@property (nonatomic, strong) NSString *completeDesc;           // null,
@property (nonatomic, strong) NSString *createTime;             // "2018-02-11 01:12:26",
@property (nonatomic, strong) NSString *examineCompany;         // "福建省福州市阿三公司",
@property (nonatomic, strong) NSString *examineCompanyId;       // 1516872328000,
@property (nonatomic, strong) NSString *examineDate;            // null,
@property (nonatomic, strong) NSString *examineDesc;            // null,
@property (nonatomic, strong) NSString *examineName;            // "张三",
@property (nonatomic, strong) NSString *examineParentId;        // 1,
@property (nonatomic, strong) NSString *examineStatus;          // null,
@property (nonatomic, strong) NSString *examineUserId;          // 1517750314001,
@property (nonatomic, strong) NSString *executeCompany;         // "福建省福州市阿三公司",
@property (nonatomic, strong) NSString *executeCompanyId;       // 1516872328000,
@property (nonatomic, strong) NSString *executeName;            // "张三",
@property (nonatomic, strong) NSString *executeParentId;        // 1,
@property (nonatomic, strong) NSString *executeUserId;          // 1517750314002,
@property (nonatomic, strong) NSString *expectDate;             // "2018-02-09 00:00:00",
@property (nonatomic, strong) NSString *id;                     // 1518278884458,
@property (nonatomic, strong) NSString *initiatorCompany;       // "福建省福州市阿三公司",
@property (nonatomic, strong) NSString *initiatorCompanyId;     // 1516872328000,
@property (nonatomic, strong) NSString *initiatorName;          // "张三",
@property (nonatomic, strong) NSString *initiatorParentId;      // 1,
@property (nonatomic, strong) NSString *initiatorUserId;        // 1517750314000,
@property (nonatomic, strong) NSString *lastModifyTime;         // "2018-02-11 01:12:26",
@property (nonatomic, strong) NSString *startDate;              // "2018-02-15 00:00:00",
@property (nonatomic, strong) NSString *taskDesc;               // "范德萨打发似的",
@property (nonatomic, strong) NSString *taskStatus;             // null,
@property (nonatomic, strong) NSString *taskTitle;              // "电风扇"@end
@end

