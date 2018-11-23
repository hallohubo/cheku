@class HBWithdrawalModel;
#import <UIKit/UIKit.h>

@interface HBWithdrawalCtr : UIViewController
@property (nonatomic, copy) void(^cancelBlock)(void);
@end
@interface HBWithdrawalModel : NSObject
@property (nonatomic, strong) NSString *bankAccount ;
@property (nonatomic, strong) NSString *bankName ;
@property (nonatomic, strong) NSString *bankNo ;
@property (nonatomic, strong) NSString *companyId ;
@property (nonatomic, strong) NSString *createTime ;
@property (nonatomic, strong) NSString *id ;
@property (nonatomic, strong) NSString *lastModifyTime ;
@property (nonatomic, strong) NSString *openingBank ;
@property (nonatomic, strong) NSString *parentId ;   
@end
