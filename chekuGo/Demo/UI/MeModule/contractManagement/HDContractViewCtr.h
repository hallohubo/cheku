//
//  HDContractViewCtr.h
//  Demo
//
//  Created by hufan on 2018/2/1.
//Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDContractViewCtr : UIViewController

- (id)initWithIsExpire:(BOOL)expire;

@end


@interface HBInformationModel : NSObject
@property (nonatomic, strong) NSString * bargainContent ;       //  string,合同内容 ,
@property (nonatomic, strong) NSString * bargainNo ;            //  string,合同编号 ,
@property (nonatomic, strong) NSString * bargainType ;          //  string,合同类型 ,
@property (nonatomic, strong) NSString * companyUserId ;        // 12,
@property (nonatomic, strong) NSString * companyUserRealname ;  //  string,对接人姓名 ,
@property (nonatomic, strong) NSString * createTime ;           //  2018-01-30 15;//18;//44 ,
@property (nonatomic, strong) NSString * deposit ;              // 300,
@property (nonatomic, strong) NSString * endDate ;              // 1515600000000,
@property (nonatomic, strong) NSString * id ;                   // 1517289866017,
@property (nonatomic, strong) NSString * lastModifyTime ;       //  2018-01-30 15;//18;//44 ,
@property (nonatomic, strong) NSString * rent ;                 // 1200,
@property (nonatomic, strong) NSString * rentDate ;             // 1515600000000,
@property (nonatomic, strong) NSString * signCardId ;           //  string,签约人身份证 ,
@property (nonatomic, strong) NSString * signDate ;             // 1515600000000,
@property (nonatomic, strong) NSString * signMemberId ;         // 101,
@property (nonatomic, strong) NSString * signRealname ;         //  string,签约人名字 ,
@property (nonatomic, strong) NSString * startDate ;            // 1515600000000,
@property (nonatomic, strong) NSString * vehicleBrand ;         //  string,品牌型号 ,
@property (nonatomic, strong) NSString * vehicleId ;            // 11,
@property (nonatomic, strong) NSString * vehicleNo ;            //  string,车牌编号 @end

@end
