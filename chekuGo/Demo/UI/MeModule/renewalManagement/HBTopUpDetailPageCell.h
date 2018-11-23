//
//  HBTopUpDetailPageCell.h
//  Demo
//
//  Created by 胡勃 on 2018/2/3.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBTopUpDetailPageCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *lbTitle;
@property (nonatomic, strong) IBOutlet UILabel *lbDetailed;
@property (nonatomic, strong) IBOutlet UIView  *vSelectPay;
@property (nonatomic, strong) IBOutlet UIImageView    *imvAlipay;
@property (nonatomic, strong) IBOutlet UIImageView    *imvWechat;
@property (nonatomic, strong) IBOutlet UIImageView    *imvUnionCard;
@property (nonatomic, strong) IBOutlet UIButton       *btnAlipay;
@property (nonatomic, strong) IBOutlet UIButton       *btnWechat;
@property (nonatomic, strong) IBOutlet UIButton       *btnUnionCard;
@property (nonatomic, strong) IBOutlet UIView  *vAlipay;
@property (nonatomic, strong) IBOutlet UIView  *vWechatPay;
@property (nonatomic, strong) IBOutlet UIView  *vBankInformation;
@property (nonatomic, strong) IBOutlet UILabel  *lbBankName;
@property (nonatomic, strong) IBOutlet UILabel  *lbBankCardNumber;
@property (nonatomic, strong) IBOutlet UILabel  *lbBankAccount;
@property (nonatomic, strong) IBOutlet UITableView    *tbv;
@end
