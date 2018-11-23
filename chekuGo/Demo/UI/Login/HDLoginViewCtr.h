//
//  HBLoginViewCtr.h
//  Demo
//
//  Created by hubo on 2017/12/19.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDLoginViewCtr : UIViewController
@property (nonatomic, copy) void(^loginFinishedBlock)(HDLoginUserModel *model);
@end
