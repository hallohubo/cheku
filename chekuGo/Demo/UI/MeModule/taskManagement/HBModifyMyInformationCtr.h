
//  HBModifyMyInformationCtr.h
//  Demo
//
//  Created by hubo on 2017/11/28.
//Copyright © 2017年 hufan. All rights reserved.


#import <UIKit/UIKit.h>

@interface HBModifyMyInformationCtr : UIViewController
@property (nonatomic, copy) void(^HBModifyMyInformationBlock)(NSString *str_title);

- (instancetype)initWithTitle:(NSString *)strTile defaultValue:(NSString *)value isEdited:(BOOL)isEdited;
@end

