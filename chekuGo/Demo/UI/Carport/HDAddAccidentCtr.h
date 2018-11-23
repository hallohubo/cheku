//
//  HDAddAccidentCtr.h
//  Demo
//
//  Created by hufan on 2018/2/1.
//Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDAddAccidentCtr : UIViewController
- (id)initWithCarIdentifier:(NSString *)identifier;
- (id)initWithAccidentId:(NSString *)accident;
@property (nonatomic, copy) void (^saveSuccessBlock)(void);
@end
