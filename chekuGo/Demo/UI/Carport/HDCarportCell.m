//
//  HDCarportCell.m
//  Demo
//
//  Created by hufan on 2018/1/21.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HDCarportCell.h"
#import "HDImageBrowser.h"

@implementation HDCarportCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _btn_carNumber.layer.borderWidth = 1.;
    _btn_carNumber.layer.cornerRadius = 5.;
    _btn_carNumber.layer.masksToBounds = YES;
    _btn_carNumber.layer.borderColor = HDCOLOR_GRAY.CGColor;
    
    _imv.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)];
    [_imv addGestureRecognizer:tap];
}

- (void)showImage:(UITapGestureRecognizer *)tap{
    [HDImageBrowser show:_imv];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
