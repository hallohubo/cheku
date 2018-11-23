//
//  HDClientLicenseCtr.h
//  Demo
//
//  Created by hufan on 2018/2/4.
//Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBClientCtr.h"

@interface HDClientLicenseCtr : UIViewController
@property (nonatomic, copy) void (^saveSuccessAndNextBlock)(HDClientModel *client);

- (id)initWithAddClient:(HDClientModel *)m;     //客户列表新增客户
- (id)initWithStepClient:(HDClientModel *)m;    //第一步那个页面新增客户

@property (nonatomic, strong) HDClientModel *putModel;
@end
