//
//  HDAddCarDetailCell.h
//  Demo
//
//  Created by hufan on 2018/2/1.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDAddCarDetailCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *lb_title;
@property (nonatomic, strong) IBOutlet UITextField *tf;
@property (nonatomic, strong) IBOutlet UIImageView *imv_datePick;
@property (nonatomic, strong) IBOutlet UIButton *btn_chooseCar;         
@end
