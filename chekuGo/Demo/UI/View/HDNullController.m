//
//  HDNullController.m
//  JianJian
//
//  Created by hufan on 16/6/30.
//  Copyright © 2016年 Hu Dennis. All rights reserved.
//

#import "HDNullController.h"
#import "HDNullView.h"

@interface HDNullController ()

@end

@implementation HDNullController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNullView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - evnet
- (void)doTouchNullAction{
    
}

#pragma mark - setter

- (void)setNullView{
    HDNullView *nullView = [[HDNullView alloc] init];
    nullView.frame = CGRectMake(0, 0, HDDeviceSize.width, 100);
    [self.view addSubview:nullView];
    [self.view sendSubviewToBack:nullView];
    [nullView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
    nullView.touchNullViewAction = ^{
        [self doTouchNullAction];
    };
}

@end
