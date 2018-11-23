//
//  HBContractCtr.h
//  Demo
//
//  Created by 胡勃 on 2018/1/19.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HDGarageScreenType) {
    HDGarageScreenTypePeccancy = 1, //违章车辆
    HDGarageScreenTypeInsure,       //保险
    HDGarageScreenTypeInspection,   //年检车辆
    HDGarageScreenTypeMaintain,     //保养
};

@class HDCarModel;

@interface HBGarageCtr : UIViewController
- (id)initWithTitle:(NSString *)title;
- (id)initWithScreenType:(HDGarageScreenType)type;
@property (nonatomic, copy) void (^chooseCarBlock)(HDCarModel *carInfo);

@end

@interface HDCarModel : NSObject
@property (nonatomic, strong) NSString *id;             //id
@property (nonatomic, strong) NSString *regDate;        //注册日期
@property (nonatomic, strong) NSString *vehicleWeight;  // "string,总质量",
@property (nonatomic, strong) NSString *dateIssued;     // "date,发证日期",
@property (nonatomic, strong) NSString *address;        // "string,住址",
@property (nonatomic, strong) NSString *engineNumber;   // "string,发动机号码",
@property (nonatomic, strong) NSString *maintainHint;   // "string,保养公里数提示",
@property (nonatomic, strong) NSString *own;            // "string,所有人",
@property (nonatomic, strong) NSString *personsInCab;   // "string,核定载人数",
@property (nonatomic, strong) NSString *vehicleTravelLicenseFront;  // "string,行驶证正面",
@property (nonatomic, strong) NSString *basicProperties;    // "string,使用性质",
@property (nonatomic, strong) NSString *cover;              // "string,封面",
@property (nonatomic, strong) NSString *vehicleBrand;       // "string,品牌型号",
@property (nonatomic, strong) NSString *archivesNumber;     // "string,档案编号",
@property (nonatomic, strong) NSString *overallDimensions;  // "string,外廓尺寸",
@property (nonatomic, strong) NSString *vehicleModel;       // "string,车辆类型",
@property (nonatomic, strong) NSString *vehicleNumber;      // "string,车辆号码",
@property (nonatomic, strong) NSString *vehicleVin;         // "string,车辆识别号码",
@property (nonatomic, strong) NSString *tractionMass;       // "string,准牵引总质量",
@property (nonatomic, strong) NSString *ratedPayload;       // "string,核定载质量",
@property (nonatomic, strong) NSString *vehicleTravelLicenseBack;    // "string,行驶证反面",
@property (nonatomic, strong) NSString *note;           // "string,备注",
@property (nonatomic, strong) NSString *status;         // "string,使用状态",
@property (nonatomic, strong) NSString *curbWeight;     // "string,整备质量",
@property (nonatomic, strong) NSString *checkLog;       // "string,检查记录",
@property (nonatomic, strong) NSString *banner;         // "string,图片",
@property (nonatomic, strong) NSString *yearlyDate;     // "date,年检时间",
@property (nonatomic, strong) NSString *insureanceExpiryDate;    // "date,保险到期时间",
@property (nonatomic, strong) NSString *bargainType;    // "string,合同类型"
@end
