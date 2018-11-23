//
//  HDAddInsureCtr.h
//  Demo
//
//  Created by hufan on 2018/2/1.
//Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDAddInsureCtr : UIViewController

- (id)initWithCarIdentifier:(NSString *)identifier;
- (id)initWithInsureId:(NSString *)insure;

@property (nonatomic, copy) void (^saveSuccessBlock)(void);

@end

@interface HDInsureModel : NSObject

@property (nonatomic, strong) NSString *createTime;    // "2018-02-10 19:28:05",
@property (nonatomic, strong) NSString *id;    // 1518261988012,
@property (nonatomic, strong) NSString *insuranceDate;    // null,
@property (nonatomic, strong) NSString *insuranceImage;    // "/files/insurance/20180210/37897265-0c8c-40ab-88ba-b3971534ca12.jpg",
@property (nonatomic, strong) NSString *insuranceMoney;    // "43",
@property (nonatomic, strong) NSString *insuranceNumber;    // "dsf",
@property (nonatomic, strong) NSString *insurancePrice;    // "3",
@property (nonatomic, strong) NSString *insureanceExpiryDate;    // null,
@property (nonatomic, strong) NSString *lastModifyTime;    // "2018-02-10 19:28:05",
@property (nonatomic, strong) NSString *vehicleId;    // 1518169921031
@end
