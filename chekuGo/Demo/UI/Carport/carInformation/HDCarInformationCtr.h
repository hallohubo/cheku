//
//  HDCarInformationCtr.h
//  Demo
//
//  Created by hufan on 2018/1/29.
//Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HD3DScrollView.h"
typedef void(^getTheStateBlock)(NSString *strIsBusy);
@interface HDCarInformationCtr : UIViewController
@property (nonatomic, copy) getTheStateBlock usingStateBlock;
- (id)initWithCarId:(NSString *)carId;
@end
