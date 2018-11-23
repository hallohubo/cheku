//
//  ZFChooseTimeViewController.h
//  slyjg
//
//  Created by 王小腊 on 16/3/9.
//  Copyright © 2016年 王小腊. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^chooseDate)(NSArray *goDate, NSArray *backDate);

typedef void(^chooseDateFinishBlock)(NSDate *date);
/**
 *  时间选择器
 */
@interface ZFChooseTimeViewController : UIViewController

@property (nonatomic, copy) chooseDate selectedDate;
@property (nonatomic, copy) chooseDateFinishBlock finishBlock;
/**
 *  返回选中时间
 *
 *  @param listDate 时间
 */
-(void)backDate:(chooseDate)listDate;



@end

