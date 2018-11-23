//
//  HDAddMaintainCtr.h
//  Demo
//
//  Created by hufan on 2018/2/1.
//Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDAddMaintainCtr : UIViewController
- (id)initWithCarIdentifier:(NSString *)identifier;
- (id)initWithMaintainId:(NSString *)maintain;
@property (nonatomic, copy) void (^saveSuccessBlock)(void);
@end
