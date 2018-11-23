//
//  HDStepTwoCtr.m
//  Demo
//
//  Created by hufan on 2018/2/7.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDStepTwoCtr.h"
#import "HDClientLicenseCtr.h"
#import "HDStepThreeCtr.h"

@interface HDStepTwoCtr (){
    IBOutlet UITableView *tbv;
    NSURLSessionDataTask *task;
    HDHUD *hud;
    HDClientModel *model;
}

@end

@implementation HDStepTwoCtr

- (id)initWithClient:(HDClientModel *)m{
    if (self = [super init]) {
        model = m;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"HDTableViewCell";
    HDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HDTableViewCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

#pragma mark - setter

- (void)setTitleView{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width * 0.5, 44)];
    UILabel *lb_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    lb_title.textAlignment = NSTextAlignmentCenter;
    lb_title.font = [UIFont systemFontOfSize:17];
    lb_title.text = @"第二步";
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
    lb_sub.text = @"填充驾驶证信息";
    [v addSubview:lb_sub];
    [lb_sub makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(v);
        make.centerY.equalTo(v).offset(10);
        make.size.mas_equalTo(CGSizeMake(180, 20));
    }];
    self.navigationItem.titleView = v;
}

- (void)setContentView{
    HDClientLicenseCtr *ctr = [[HDClientLicenseCtr alloc] initWithStepClient:model];
    [self addChildViewController:ctr];
    [self.view addSubview:ctr.view];
    [ctr.view makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(self.view);
        make.center.equalTo(self.view);
    }];
    ctr.saveSuccessAndNextBlock = ^(HDClientModel *client) {
        HDStepThreeCtr *ctr = [[HDStepThreeCtr alloc] initWithClientModel:client];
        [self.navigationController pushViewController:ctr animated:YES];
    };
}

@end
