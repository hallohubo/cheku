//
//  HDStepFourCtr.h
//  Demo
//
//  Created by hufan on 2018/2/10.
//Copyright © 2018年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDStepThreeCtr.h"

@interface HDStepFourCtr : UIViewController

- (id)initWithCompactInfo:(NSDictionary *)compact andClient:(NSDictionary *)client andOrderNo:(NSString *)order;

- (id)initWithBargainModel:(HDBargainModel *)bargain clientModel:(HDClientModel *)client;

@property (nonatomic, strong) NSString *title;

@end
