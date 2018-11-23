//
//  HDAddCarDetailCell.m
//  Demo
//
//  Created by hufan on 2018/2/1.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HDAddCarDetailCell.h"

@implementation HDAddCarDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.btn_chooseCar.layer.cornerRadius = 12.;
    self.btn_chooseCar.layer.masksToBounds = YES;
    self.btn_chooseCar.layer.borderColor = RGB(253., 181, 52.).CGColor;
    self.btn_chooseCar.layer.borderWidth = 1.;
    [self.btn_chooseCar setTitleColor:RGB(253, 181, 52) forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)doChooseSex:(UIButton *)sender{
    
}
@end
