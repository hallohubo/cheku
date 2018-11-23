//
//  HDPayWayCell.m
//  Demo
//
//  Created by hufan on 2018/2/22.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HDPayWayCell.h"

@implementation HDPayWayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)doChoosePayWay:(id)sender{
    [HDHelper say:@"目前只支持银行转账支付"];
//    _btn_selected0.selected = !_btn_selected0.selected;
}
@end
