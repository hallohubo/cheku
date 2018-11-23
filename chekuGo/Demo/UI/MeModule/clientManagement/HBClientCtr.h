//
//  HBContractCtr.h
//  Demo
//
//  Created by 胡勃 on 2018/1/19.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDClientModel : NSObject

@property (nonatomic, strong) NSString *address;        // "前几名",
@property (nonatomic, strong) NSString *bargainNum;     // null,
@property (nonatomic, strong) NSString *birthday;       // "2018-02-17",
@property (nonatomic, strong) NSString *cardBack;       // "/files/image/20180217/548b30ee-45a2-4c23-9a33-5460d2fee6ca.jpg",
@property (nonatomic, strong) NSString *cardFront;      // "/files/image/20180217/f2691777-46be-48bf-945c-059144cd5455.jpg",
@property (nonatomic, strong) NSString *cardId;         // "6",
@property (nonatomic, strong) NSString *createTime;     // "2018-02-17 00:18:39",
@property (nonatomic, strong) NSString *driveAddress;   // null,
@property (nonatomic, strong) NSString *driveBack;      // null,
@property (nonatomic, strong) NSString *driveBirthday;  // "2018-02-17",
@property (nonatomic, strong) NSString *driveDataId;    // null,
@property (nonatomic, strong) NSString *driveDataRecord;// "8婆婆你",
@property (nonatomic, strong) NSString *driveExpiryDate;// "2018-02-17",
@property (nonatomic, strong) NSString *driveFirstDate; // "2018-02-17",
@property (nonatomic, strong) NSString *driveFront;     // "/files/image/20180217/b5a6014b-9443-4f9c-8a2a-f47fecb9fe89.jpg",
@property (nonatomic, strong) NSString *driveGender;    // null,
@property (nonatomic, strong) NSString *driveNation;    // "李敏",
@property (nonatomic, strong) NSString *driveNumber;    // "34946346464",
@property (nonatomic, strong) NSString *driveRealname;  // null,
@property (nonatomic, strong) NSString *driveStartDate; // "2018-02-17",
@property (nonatomic, strong) NSString *driveVehicleType;    // "很急定了",
@property (nonatomic, strong) NSString *driverIsExpire; // null,
@property (nonatomic, strong) NSString *endDate;        // "2018-02-17",
@property (nonatomic, strong) NSString *gender;         // "男",
@property (nonatomic, strong) NSString *id;             // 1518774928699,
@property (nonatomic, strong) NSString *idcardIsExpire; // 0,
@property (nonatomic, strong) NSString *lastModifyTime; // "2018-02-17 00:18:39",
@property (nonatomic, strong) NSString *nation;         // "好",
@property (nonatomic, strong) NSString *note;           // null,
@property (nonatomic, strong) NSString *office;         // "股民GHZ你",
@property (nonatomic, strong) NSString *password;       // null,
@property (nonatomic, strong) NSString *phone;          // null,
@property (nonatomic, strong) NSString *realname;       // "李子自己",
@property (nonatomic, strong) NSString *startDate;      // "2018-02-17",
@property (nonatomic, strong) NSString *username;       // "李子自己"

@end

@interface HBClientCtr : UIViewController
- (id)initWithIdCardIsExpire:(BOOL)expire;
- (id)initWithDriveIsExpire:(BOOL)expire;
@property (nonatomic, copy) void (^chooseClientBlock)(HDClientModel *model);

@end
