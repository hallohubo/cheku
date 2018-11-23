//
//  HBTaskDetailCtr.h
//  Demo
//
//  Created by 胡勃 on 2018/1/26.
//Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBClientDetailCtr : UIViewController

@property (nonatomic, copy) void (^saveSucessBlock)(void);

- (id)initWithClientId:(NSString *)client;

@end
