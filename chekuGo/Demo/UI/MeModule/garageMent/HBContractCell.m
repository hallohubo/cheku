//
//  HBContractCell.m
//  Demo
//
//  Created by 胡勃 on 2018/1/19.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBGarageCell.h"

@implementation HBGarageCell

- (void)awakeFromNib {
   
    _lbMark.layer.cornerRadius  = 5.f;
    _lbMark.layer.masksToBounds = YES;
    _lbMark.layer.borderWidth = 1.f;
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
