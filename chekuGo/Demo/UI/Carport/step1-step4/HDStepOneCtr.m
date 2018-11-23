//
//  HDStepOneCtr.m
//  Demo
//
//  Created by hufan on 2018/2/4.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDStepOneCtr.h"
#import "HDStepTwoCtr.h"
#import "HDClientInfoCtr.h"

@interface HDStepOneCtr (){
    IBOutlet UITableView *tbv;
    NSURLSessionDataTask *task;
    HDHUD *hud;
}

@end

@implementation HDStepOneCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTitleView];
    [self setContentView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    task = nil;
    [hud hiden];
    hud = nil;
}


#pragma mark - setter
- (void)setup{

}

- (void)setTitleView{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width * 0.5, 44)];
    UILabel *lb_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    lb_title.textAlignment = NSTextAlignmentCenter;
    lb_title.font = [UIFont systemFontOfSize:17];
    lb_title.text = @"第一步";
    [v addSubview:lb_title];
    [lb_title makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(v);
        make.centerY.equalTo(v).offset(-10);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    UILabel *lb_sub = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    lb_sub.textAlignment = NSTextAlignmentCenter;
    lb_sub.font = [UIFont systemFontOfSize:12];
    lb_sub.textColor = RGB(224., 70, 56);
    lb_sub.text = @"填充身份证信息";
    [v addSubview:lb_sub];
    [lb_sub makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(v);
        make.centerY.equalTo(v).offset(10);
        make.size.mas_equalTo(CGSizeMake(180, 20));
    }];
    self.navigationItem.titleView = v;
}

- (void)setContentView{
    HDClientInfoCtr *ctr = [HDClientInfoCtr new];
    [self addChildViewController:ctr];
    [self.view addSubview:ctr.view];
    [ctr.view makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
}

@end
