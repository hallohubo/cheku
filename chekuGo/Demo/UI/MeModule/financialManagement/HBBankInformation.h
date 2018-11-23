//
//  HBBankInformation.h
//  Demo
//
//  Created by 胡勃 on 2018/3/6.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBBankInformation : UITableViewCell
@property (nonatomic, strong) IBOutlet UIView  *vBankInformation;
@property (nonatomic, strong) IBOutlet UILabel  *lbBankName;
@property (nonatomic, strong) IBOutlet UILabel  *lbBankCardNumber;
@property (nonatomic, strong) IBOutlet UILabel  *lbBankAccount;
@end
