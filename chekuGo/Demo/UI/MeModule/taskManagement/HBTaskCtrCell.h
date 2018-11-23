//
//  HBContractCell.h
//  Demo
//
//  Created by 胡勃 on 2018/1/19.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HBTaskCtrCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *lbMark;
@property (nonatomic, strong) IBOutlet UILabel *lbTaskName;
@property (nonatomic, strong) IBOutlet UILabel *lbTaskTime;
@property (nonatomic, strong) IBOutlet UILabel *lbtaskIsFinish;
@end
