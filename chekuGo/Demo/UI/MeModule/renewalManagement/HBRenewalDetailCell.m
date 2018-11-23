//
//  HBRenewalDetailCell.m
//  Demo
//
//  Created by 胡勃 on 2018/1/23.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBRenewalDetailCell.h"

@implementation HBRenewalDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _btnToView.layer.cornerRadius   = 15.f;
    _btnToView.layer.masksToBounds  = YES;
    UIColor *col = [[UIColor alloc] initWithRed:235/255. green:182/255. blue:59/255. alpha:1];
    _btnToView.layer.borderColor = col.CGColor;
    _btnToView.layer.borderWidth = 1.f;
    [_btnToView setHidden:YES];
    [_imv setHidden:YES];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
