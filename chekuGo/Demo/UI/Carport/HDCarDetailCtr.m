//
//  HDCarDetailCtr.m
//  Demo
//
//  Created by hufan on 2018/1/18.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDCarDetailCtr.h"
#import "HDCarInformationCtr.h"
#import "HDCarPeccancyCtr.h"
#import "HDStepOneCtr.h"
#import "HBClientCtr.h"
#import "HDStepThreeCtr.h"
#import "HDStepTwoCtr.h"

@interface HDCarDetailCtr (){
    NSURLSessionDataTask *task;
    HDHUD *hud;
    NSString *carIdetifier;
    IBOutlet UIScrollView *scv;
    IBOutlet NSLayoutConstraint *lc_lineLeading;
    IBOutlet UIButton *btn_detail;
    IBOutlet UIButton *btn_peccancy;
    IBOutlet UIButton *btn_insure;
    IBOutlet UIButton *btn_inspection;
    IBOutlet UIButton *btn_maintain;
    IBOutlet UIButton *btn_accident;
    IBOutlet UIButton *btn_addNewCustomer;
    IBOutlet UIButton *btn_bindAcount;
    IBOutlet UIView   *contentView;
    BOOL              isUsedTheCar;
    HDCarInformationCtr *informationCtr;
    HDCarPeccancyCtr *peccancyCtr;
    HDCarPeccancyCtr *insureCtr;
    HDCarPeccancyCtr *inspectionCtr;
    HDCarPeccancyCtr *maintainCtr;
    HDCarPeccancyCtr *accidentCtr;
}

@end

@implementation HDCarDetailCtr

- (id)initWithCarId:(NSString *)carId{
    if (self = [super init]) {
        carIdetifier = carId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
//    [self httpGetCarDetail];
    [self setInformationView];
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

#pragma mark - event
- (IBAction)doChooseButton:(UIButton *)sender{
    [self setButtonSeleted:sender];
    switch (sender.tag) {
        case 0:{//详情
            [self setInformationView];
            break;
        }
        case 1:{//违章
            if (!peccancyCtr) {
                peccancyCtr = [[HDCarPeccancyCtr alloc] initWithCarId:carIdetifier carDetailType:HDCarDetailTypePeccancy];
                [self setPeccacyView:peccancyCtr];
            }
            [contentView bringSubviewToFront:peccancyCtr.view];
            break;
        }   
        case 2:{//保险
            if (!insureCtr) {
                insureCtr = [[HDCarPeccancyCtr alloc] initWithCarId:carIdetifier carDetailType:HDCarDetailTypeInsure];
                [self setPeccacyView:insureCtr];
            }
            [contentView bringSubviewToFront:insureCtr.view];
            break;
        }
        case 3:{//年检
            if (!inspectionCtr) {
                inspectionCtr = [[HDCarPeccancyCtr alloc] initWithCarId:carIdetifier carDetailType:HDCarDetailTypeInspection];
                [self setPeccacyView:inspectionCtr];
            }
            [contentView bringSubviewToFront:inspectionCtr.view];
            break;
        }
        case 4:{//保养
            if (!maintainCtr) {
                maintainCtr = [[HDCarPeccancyCtr alloc] initWithCarId:carIdetifier carDetailType:HDCarDetailTypeMaintain];
                [self setPeccacyView:maintainCtr];
            }
            [contentView bringSubviewToFront:maintainCtr.view];
            break;
        }
        case 5:{//事故
            if (!accidentCtr) {
                accidentCtr = [[HDCarPeccancyCtr alloc] initWithCarId:carIdetifier carDetailType:HDCarDetailTypeAccident];
                [self setPeccacyView:accidentCtr];
            }
            [contentView bringSubviewToFront:accidentCtr.view];
            break;
        }
        default:
            break;
    }
}

- (IBAction)doAddNewClient:(id)sender{
    HDGI.signCarId = carIdetifier;
    HDStepOneCtr *ctr = [HDStepOneCtr new];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (IBAction)doBindExistClient:(id)sender{
    HDGI.signCarId = carIdetifier;
    HBClientCtr *ctr = [[HBClientCtr alloc] init];
    [self.navigationController pushViewController:ctr animated:YES];
    ctr.chooseClientBlock = ^(HDClientModel *model) {
        [self.navigationController popViewControllerAnimated:NO];
        HDStepThreeCtr *ctr = [[HDStepThreeCtr alloc] initWithClientModel:model];
        [self.navigationController pushViewController:ctr animated:YES];
    };
}

#pragma mark - setter
- (void)setup{
    self.title = @"车辆详情";
    btn_bindAcount.layer.borderColor = HDCOLOR_GRAY.CGColor;
    btn_bindAcount.layer.borderWidth = 1.;
    NSString *role = HDGI.loginUser.role;
    if ([role isEqualToString:@"Main"] || isUsedTheCar) {
        btn_bindAcount.enabled = NO;
        btn_addNewCustomer.enabled = NO;
        [btn_addNewCustomer setBackgroundColor:[UIColor grayColor]];
        [btn_bindAcount setBackgroundColor:[UIColor grayColor]];
        [btn_bindAcount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
}

- (void)setButtonSeleted:(UIButton *)btn{
    NSArray *ar = @[btn_detail, btn_peccancy, btn_insure, btn_inspection, btn_maintain, btn_accident];
    for (int i = 0; i < ar.count; i++) {
        UIButton *b = ar[i];
        b.selected = NO;
    }
    btn.selected = YES;
    lc_lineLeading.constant = CGRectGetMinX(btn.frame);
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)setInformationView{
    if (!informationCtr) {
        informationCtr = [[HDCarInformationCtr alloc] initWithCarId:carIdetifier];
        informationCtr.view.frame = CGRectMake(0, 0, HDDeviceSize.width, HDDeviceSize.height - 64 - 100);
        [contentView addSubview:informationCtr.view];
        [self addChildViewController:informationCtr];
        [informationCtr.view makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(contentView);
            make.right.equalTo(contentView);
            make.top.equalTo(contentView);
            make.bottom.equalTo(contentView);
        }];
        [informationCtr setUsingStateBlock:^(NSString *strIsBusy) {
            isUsedTheCar = [strIsBusy isEqualToString:@"忙碌"];
            [self setup];
        }];
        return;
    }
    [contentView bringSubviewToFront:informationCtr.view];
}

- (void)setPeccacyView:(UIViewController *)ctr{//违章、。。。。
    ctr.view.frame = CGRectMake(0, 0, HDDeviceSize.width, HDDeviceSize.height - 64 - 100);
    [contentView addSubview:ctr.view];
    [self addChildViewController:ctr];
    [ctr.view makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(contentView);
        make.right.equalTo(contentView);
        make.top.equalTo(contentView);
        make.bottom.equalTo(contentView);
    }];
    return;
}


@end
