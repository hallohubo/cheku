//
//  HDCarPeccancyCtr.h
//  Demo
//
//  Created by hufan on 2018/1/31.
//Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDNullController.h"

typedef NS_ENUM(NSInteger, HDCarDetailType) {
    
    HDCarDetailTypePeccancy = 0,    //违章
    HDCarDetailTypeInsure,          //保险
    HDCarDetailTypeInspection,      //年检
    HDCarDetailTypeMaintain,        //保养
    HDCarDetailTypeAccident,        //事故
};

@interface HDCarPeccancyCtr : HDNullController
- (id)initWithCarId:(NSString *)carId carDetailType:(HDCarDetailType)type;
@end
