//
//  ZFChooseTimeCollectionViewCell.h
//  slyjg
//
//  Created by 王小腊 on 16/3/9.
//  Copyright © 2016年 王小腊. All rights reserved.
//


#define CYBColorGreen [UIColor colorWithRed:78/255.0 green:147/255.0 blue:232/255.0 alpha:1]
#define YJCorl(a,b,c) [UIColor colorWithRed:a/255.0 green:b/255.0 blue:c/255.0 alpha:1]
#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define kDeviceHeight [UIScreen mainScreen].bounds.size.height

#import <UIKit/UIKit.h>

@interface ZFChooseTimeCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *number;

@property (weak, nonatomic) IBOutlet UILabel *stateLabel;

@property (nonatomic ,strong) NSArray *currentArray;


/**
 *  更新布局
 *
 *  @param number   cell代表时间
 *  @param judge    选择出团时间
 *  @param judge    选择反团时间
 *  @param newArray 出团时间
 */
- (void)updateDay:(NSArray*)number outDate:(NSArray*)outdateArray selected:(NSInteger)judge currentDate:(NSArray*)newArray;


@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com