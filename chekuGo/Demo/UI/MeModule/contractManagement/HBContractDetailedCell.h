//
//  HBContractDetailedCell.h
//  Demo
//
//  Created by 胡勃 on 2018/1/31.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBContractDetailedCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lbLeft;
@property (strong, nonatomic) IBOutlet UILabel *lbRight;
@property (strong, nonatomic) IBOutlet UILabel *lbTitle;
@property (strong, nonatomic) IBOutlet UILabel *lbMiddle;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint   *lcWidth;

@end
