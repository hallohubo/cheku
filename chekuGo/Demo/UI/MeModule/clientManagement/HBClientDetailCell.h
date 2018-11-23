//
//  HBClientDetailCell.h
//  Demo
//
//  Created by 胡勃 on 2018/1/28.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBClientDetailCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel          *lbTitel;
@property (nonatomic, strong) IBOutlet UITextField      *tfTitelDetail;
@property (nonatomic, strong) IBOutlet UILabel      *lbTitelValidityBegin;
@property (nonatomic, strong) IBOutlet UILabel      *lbTitelValidityEnd;
@property (nonatomic, strong) IBOutlet UIButton         *btnBirthday;
@property (nonatomic, strong) IBOutlet UIButton         *btnValidityBegin;
@property (nonatomic, strong) IBOutlet UIButton         *btnValidityEnd;
@property (nonatomic, strong) IBOutlet UIButton         *btnBoy;
@property (nonatomic, strong) IBOutlet UIButton         *btnGirl;
@property (nonatomic, strong) IBOutlet UIView           *vSexyChoose;
@property (nonatomic, strong) IBOutlet UIView           *vValidityDayChoose;
@property (nonatomic, strong) IBOutlet UIImageView      *imvBoy;
@property (nonatomic, strong) IBOutlet UIImageView      *imvGirl;
@property (nonatomic, strong) IBOutlet UIImageView      *imvBirthday;
@end
