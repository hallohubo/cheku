//
//  HBFinancialtdetailCell.m
//  Demo
//
//  Created by 胡勃 on 2018/2/18.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBFinancialtdetailCell.h"

@implementation HBFinancialtdetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _btnCheckMoreOrder.layer.cornerRadius   = 12.f;
    _btnCheckMoreOrder.layer.masksToBounds  = YES;
    _btnCheckMoreOrder.layer.borderColor    = RGB(247, 176, 50).CGColor;
    _btnCheckMoreOrder.layer.borderWidth    = 1.f;
    [_btnCheckMoreOrder setTintColor:RGB(247, 176, 50)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
