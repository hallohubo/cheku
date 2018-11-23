//
//  HDClientSexCell.h
//  Demo
//
//  Created by hufan on 2018/2/4.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDClientSexCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *lb_title;
@property (nonatomic, strong) IBOutlet UIButton *btn0;
@property (nonatomic, strong) IBOutlet UIButton *btn1;
@property (nonatomic, copy) void (^chooseSex)(int sex); //男1，女0
@property (nonatomic, strong) NSString *sex;
@end
