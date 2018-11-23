//
//  HBOrderChangePriceCtr.h
//  Demo
//
//  Created by 胡勃 on 2018/9/12.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^finishChangeBlock)(NSString *strType, NSString *money, NSString *strDescription);

@interface HBOrderChangePriceCtr : UIViewController

@property (nonatomic, copy) finishChangeBlock finishBlock;
@end
