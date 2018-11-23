//
//  HDAddCarCtr.h
//  Demo
//
//  Created by hufan on 2018/2/19.
//Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBGarageCtr.h"

@interface HDAddCarCtr : UIViewController

- (id)initWithCarId:(NSString *)car;

@property (nonatomic, copy) void (^saveSuccessBlock)(void);

@end

