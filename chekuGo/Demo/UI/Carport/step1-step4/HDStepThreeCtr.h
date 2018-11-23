//
//  HDStepThreeCtr.h
//  Demo
//
//  Created by hufan on 2018/2/9.
//Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBClientCtr.h"

@interface HDStepThreeCtr : UIViewController

- (id)initWithClientModel:(HDClientModel *)model;

@property (nonatomic, strong) NSString *title;

@end

@interface HDBargainModel : NSObject

@property (nonatomic, strong) NSString *id;

@property (nonatomic, strong) NSString *signMemberId;          //long,签约人编号",
@property (nonatomic, strong) NSString *bargainNo;          //string,合同编号",
@property (nonatomic, strong) NSString *bargainContent;        //string,合同内容",
@property (nonatomic, strong) NSString *endDate;          //date,结束日期",
@property (nonatomic, strong) NSString *rent;          //integer,租金",
@property (nonatomic, strong) NSString *signDate;          //date,签约时间",
@property (nonatomic, strong) NSString *vehicleNo;          //string,车牌编号",
@property (nonatomic, strong) NSString *vehicleBrand;          //string,品牌型号",
@property (nonatomic, strong) NSString *rentDay;          //integer,租金日期",
@property (nonatomic, strong) NSString *signRealname;          //string,签约人名字",
@property (nonatomic, strong) NSString *deposit;          //integer,押金",
@property (nonatomic, strong) NSString *vehicleId;          //long,车牌编号",
@property (nonatomic, strong) NSString *bargainType;          //string,合同类型",
@property (nonatomic, strong) NSString *signCardId;          //string,签约人身份证",
@property (nonatomic, strong) NSString *startDate;          //date,起始日期",
@property (nonatomic, strong) NSString *note;          //string,备注",
@property (nonatomic, strong) NSString *firstRent;          //float,首月租金",

@property (nonatomic, strong) NSString *rentalsMethod;          //integer,风控模式",
@property (nonatomic, strong) NSString *dailyRate;          //decimal,每日租金",
@property (nonatomic, strong) NSString *monthRate;          //decimal,每月租金",
@property (nonatomic, strong) NSString *rentingStartDate;          //date,租金起始日期",
@property (nonatomic, strong) NSString *rentingEndDate;          //date,租金结束日期",
@property (nonatomic, strong) NSString *returnActivityMoneyMonth;          //decimal,月返金额",
@property (nonatomic, strong) NSString *returnActivityMoneyDay;          //decimal,日返金额",
@property (nonatomic, strong) NSString *riskDay;          //integer,风控日",
@property (nonatomic, strong) NSString *takeCarDate;          //string,提车时间"

@end
