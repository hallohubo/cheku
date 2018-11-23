//
//  HDCarportCtr.h
//  Demo
//
//  Created by hufan on 2018/1/18.
//Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDCarportCtr : UIViewController
@property (nonatomic,strong) NSString *strCompanyId;
- (instancetype)initWithCarType:(NSString *)type_ companyId:(NSString *)companyIdenty;
@end
