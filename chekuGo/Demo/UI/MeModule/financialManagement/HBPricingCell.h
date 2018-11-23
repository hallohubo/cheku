//
//  HBPricingCell.h
//  Demo
//
//  Created by 胡勃 on 2018/9/8.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBPricingCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UIButton *btnChang;
@property (nonatomic, strong) IBOutlet UIButton *btnAmount;
@property (nonatomic, strong) IBOutlet UIButton *btnExplain;
@property (nonatomic, strong) IBOutlet UIButton *btnData;
@property (nonatomic, strong) IBOutlet UIButton *btnDelete;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *lcWidth;
@property (nonatomic, strong) IBOutlet UIView   *vLine;
@end
