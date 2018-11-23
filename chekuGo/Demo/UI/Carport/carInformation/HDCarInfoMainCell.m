//
//  HDCarInfoMainCell.m
//  Demo
//
//  Created by hufan on 2018/1/30.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HDCarInfoMainCell.h"

@implementation HDCarInfoMainCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.lb_desc0 sizeToFit];
    [self.lb_desc1 sizeToFit];
    [self.lb_desc2 sizeToFit];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
