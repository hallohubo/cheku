//
//  HDClientInfoCtr.h
//  Demo
//
//  Created by hufan on 2018/2/4.
//Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBClientCtr.h"

@interface HDClientInfoCtr : UIViewController

- (id)initWithAddClient:(HDClientModel *)m;     //客户列表新增客户
- (id)initWithStepClient;    //第一步那个页面新增客户
@property (nonatomic, copy) void (^saveSuccessBlock)(void);
@property (nonatomic, strong) HDClientModel *putModel;  //显示客户详情，并可以保存更新
@end

