@class HBContractDetailedModel;
#import <UIKit/UIKit.h>

@interface HBContractDetailedCtr : UIViewController

- (instancetype)initWithString:(NSString *)contractID;

@end
@interface HBContractDetailedModel :NSObject
@property (nonatomic, strong) NSString *bargainContent;// "string,合同内容",
@property (nonatomic, strong) NSString *bargainNo;// 合同编号
@property (nonatomic, strong) NSString *bargainType;// "融租",
@property (nonatomic, strong) NSString *companyUserId;// 12,
@property (nonatomic, strong) NSString *companyUserRealname;// "开发宇宙",
@property (nonatomic, strong) NSString *createTime;// "2018-01-30 20:57:03",
@property (nonatomic, strong) NSString *deposit;// 300,
@property (nonatomic, strong) NSString *endDate;// 1484064000000,
@property (nonatomic, strong) NSString *id;// 1517314302138,
@property (nonatomic, strong) NSString *lastModifyTime;// "2018-01-30 20:57:03",
@property (nonatomic, strong) NSString *rent;// 1200,
@property (nonatomic, strong) NSString *rentDay;// 1515600000000,
@property (nonatomic, strong) NSString *signCardId;// "string,签约人身份证",
@property (nonatomic, strong) NSString *signDate;// 1515600000000,
@property (nonatomic, strong) NSString *signMemberId;// 101,
@property (nonatomic, strong) NSString *signRealname;// "宇宙开发宇宙",
@property (nonatomic, strong) NSString *startDate;// 1515600000000,
@property (nonatomic, strong) NSString *vehicleBrand;// "string,品牌型号",
@property (nonatomic, strong) NSString *vehicleId;// 11,
@property (nonatomic, strong) NSString *vehicleNo;// "闽B111111111B"
@property (nonatomic, strong) NSString * note;                  //  : "合同备注",

@end
