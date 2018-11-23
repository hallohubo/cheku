//
//  HDClientSexCell.m
//  Demo
//
//  Created by hufan on 2018/2/4.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HDClientSexCell.h"
@interface HDClientSexCell(){
    IBOutlet UIButton *btn_maleIcon;
    IBOutlet UIButton *btn_femaleIcon;
}

@end
@implementation HDClientSexCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)doChooseSex:(UIButton *)sender{
    if (!sender) {
        btn_maleIcon.selected = NO;
        btn_femaleIcon.selected = NO;
        return;
    }
    btn_maleIcon.selected = sender.tag;
    btn_femaleIcon.selected = !sender.tag;
    if (self.chooseSex) {
        self.chooseSex(sender.tag);
    }
}

- (void)setSex:(NSString *)sex{
    if (sex.length == 0) {
        [self doChooseSex:nil];
        return;
    }
    [self doChooseSex:sex.intValue == 1? btn_maleIcon: btn_femaleIcon];
}

@end
