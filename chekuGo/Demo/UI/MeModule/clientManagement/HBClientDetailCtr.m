//
//  HBTaskDetailCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/1/26.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HBClientDetailCtr.h"
#import "HDClientInfoCtr.h"
#import "HDClientLicenseCtr.h"

@interface HBClientDetailCtr ()<UITextFieldDelegate,UIScrollViewDelegate>{
    IBOutlet UIButton           *btnIdentyInfo;
    IBOutlet UIButton           *btnDriverIDInfo;
    IBOutlet UIButton           *btnSaveInfo;
    IBOutlet UIView             *line;
    IBOutlet NSLayoutConstraint *lc_lineLeading;
    IBOutlet NSLayoutConstraint *lc_saveViewHeight;
    IBOutlet UIView *vSave;
    NSURLSessionDataTask *task;
    HDHUD *hud;
    HDClientInfoCtr *clientCardIdCtr;
    HDClientLicenseCtr *clientLicenseCtr;
    NSString *clientId;
    HDClientModel *model;
}

@end

@implementation HBClientDetailCtr

- (id)initWithClientId:(NSString *)client{
    if (self = [super init]) {
        clientId = client;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setLicenseContentView];
    [self setCardIdContentView];
    if (clientId.length > 0) {
        [self httpGetClient];
    }
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

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - event

- (IBAction)saveClick:(id)sender {
    if (model.cardFront.length == 0) {
        [HDHelper say:@"请选择身份证正面"];
        return;
    }
    if (model.cardBack.length == 0) {
        [HDHelper say:@"请选择身份证背面"];
        return;
    }
    if (model.realname.length == 0) {
        [HDHelper say:@"请输入姓名"];
        return;
    }
    if (model.realname.length > 20) {
        [HDHelper say:@"请输入20字以内姓名"];
        return;
    }
    if (model.gender.length == 0) {
        [HDHelper say:@"请选择性别"];
        return;
    }
    if (model.birthday.length == 0) {
        [HDHelper say:@"请输入出生日期"];
        return;
    }
    if (model.cardId.length == 0) {
        [HDHelper say:@"请输入身份证号码"];
        return;
    }
    if (model.cardId.length > 20) {
        [HDHelper say:@"请输入正确身份证号码"];
        return;
    }
    if (model.nation.length == 0) {
        [HDHelper say:@"请输入民族"];
        return;
    }
    if (model.nation.length > 20) {
        [HDHelper say:@"请输入正确民族"];
        return;
    }
    if (model.address.length == 0) {
        [HDHelper say:@"请输入住址"];
        return;
    }
    if (model.address.length > 30) {
        [HDHelper say:@"请输入正确住址"];
        return;
    }
    if (model.office.length == 0) {
        [HDHelper say:@"请输入签发机关"];
        return;
    }
    if (model.office.length > 20) {
        [HDHelper say:@"请输入正确签发机关"];
        return;
    }
    if (model.startDate.length == 0) {
        [HDHelper say:@"请输入有效期起始日期"];
        return;
    }
    if (model.endDate.length == 0) {
        [HDHelper say:@"请输入有效期结束日期"];
        return;
    }
    if (![HDHelper isValidateMobile:model.phone]) {
        [HDHelper say:@"请输入正确手机号码"];
        return;
    }

    if (model.driveFront.length == 0) {
        [HDHelper say:@"请选择驾驶证照片"];
        return;
    }
    if (model.driveRealname.length == 0) {
        [HDHelper say:@"请输入姓名"];
        return;
    }
    if (model.driveRealname.length > 20) {
        [HDHelper say:@"请输入20字以内姓名"];
        return;
    }
    if (model.driveGender.length == 0) {
        [HDHelper say:@"请选择性别"];
        return;
    }
    if (model.driveDataId.length == 0) {
        [HDHelper say:@"请输入档案编号"];
        return;
    }
    if (model.driveDataId.length > 20) {
        [HDHelper say:@"请输入正确档案编号"];
        return;
    }
    if (model.driveFirstDate.length == 0) {
        [HDHelper say:@"请输入初次领证日期"];
        return;
    }
    if (model.driveBirthday.length == 0) {
        [HDHelper say:@"请输入出生日期"];
        return;
    }
    if (model.driveNumber.length == 0) {
        [HDHelper say:@"请输入驾驶证号码"];
        return;
    }
    if (model.driveNumber.length > 20) {
        [HDHelper say:@"请输入正确驾驶证号码"];
        return;
    }
    if (model.driveDataRecord.length > 30) {
        [HDHelper say:@"请输入正确记录"];
        return;
    }
    if (model.driveNation.length == 0) {
        [HDHelper say:@"请输入国籍"];
        return;
    }
    if (model.driveNation.length > 10) {
        [HDHelper say:@"请输入正确国籍"];
        return;
    }
    if (model.driveAddress.length == 0) {
        [HDHelper say:@"请输入住址"];
        return;
    }
    if (model.driveAddress.length > 30) {
        [HDHelper say:@"请输入正确住址"];
        return;
    }
    if (model.driveStartDate.length == 0) {
        [HDHelper say:@"请输入有效期起始日期"];
        return;
    }
    if (model.driveExpiryDate.length == 0) {
        [HDHelper say:@"请输入有效期结束日期"];
        return;
    }
    if (clientId.length > 0) {
        [self httpUpdate];
    }else{
        [self httpAddClient];
    }
    
}

- (IBAction)selectTask:(UIButton *)sender {
    lc_lineLeading.constant = HDDeviceSize.width * 0.5 * sender.tag;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    btnIdentyInfo.selected      = !sender.tag;
    btnDriverIDInfo.selected    = sender.tag;
    if (sender.tag) {
        if (!clientLicenseCtr) {
            [self setLicenseContentView];
            return;
        }
        [self.view bringSubviewToFront:clientLicenseCtr.view];
        return;
    }
    [self.view bringSubviewToFront:clientCardIdCtr.view];
}

- (void)httpGetClient{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:HDFORMAT(@"/member/%@", clientId) object:[HDClientModel new] finished:^(HDError *error, id object, BOOL isLast, id data) {
        [hud hiden];
        if (error) {
            [HDHelper say:error.desc];
            return ;
        }
        model = object;
        clientCardIdCtr.putModel = model;
        clientLicenseCtr.putModel = model;
    }];
}

- (void)httpAddClient{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    NSArray *ar = [HDHttpHelper allProperties:model];
    NSMutableDictionary *mdc = [NSMutableDictionary new];
    for (int i = 0; i < ar.count; i++) {
        NSString *key = ar[i];
        NSString *value = [model valueForKey:key];
        [mdc setValue:HDSTR(value) forKey:key];
    }
    helper.parameters = mdc;
    task = [helper postPath:HDFORMAT(@"/member") object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        [HDHelper mbSay:@"保存成功！"];
        [self.navigationController popViewControllerAnimated:YES];
        if (self.saveSucessBlock) {
            self.saveSucessBlock();
        }
    }];
}

- (void)httpUpdate{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    NSArray *ar = [HDHttpHelper allProperties:model];
    NSMutableDictionary *mdc = [NSMutableDictionary new];
    for (int i = 0; i < ar.count; i++) {
        NSString *key = ar[i];
        NSString *value = [model valueForKey:key];
        [mdc setValue:HDSTR(value) forKey:key];
    }
    helper.parameters = mdc;
    task = [helper putPath:HDFORMAT(@"/member/%@", model.id) object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        [HDHelper mbSay:@"保存成功！"];
        [self.navigationController popViewControllerAnimated:YES];
        if (self.saveSucessBlock) {
            self.saveSucessBlock();
        }
    }];
}
#pragma mark - setter
- (void)setup{
    self.title  = @"客户详情";
    if (clientId.length == 0) {
        self.title = @"添加客户";
    }
    model = [HDClientModel new];
    btnIdentyInfo.selected          = YES;
    btnDriverIDInfo.selected        = NO;
    btnSaveInfo.layer.cornerRadius  = 5;
    btnSaveInfo.layer.masksToBounds = YES;
    if ([HDGI.loginUser.role isEqualToString:@"Main"]) {
        lc_saveViewHeight.constant = 0.;
        [self.view updateConstraints];
        vSave.hidden = YES;
    }
}

- (void)setCardIdContentView{
    clientCardIdCtr = [[HDClientInfoCtr alloc] initWithAddClient:model];
    if (clientId.length > 0) {
        clientCardIdCtr = [[HDClientInfoCtr alloc] init];
    }
    [self addChildViewController:clientCardIdCtr];
    [self.view addSubview:clientCardIdCtr.view];
    [clientCardIdCtr.view makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(line.bottom);
        make.bottom.equalTo(vSave.top);
    }];
}

- (void)setLicenseContentView{
    clientLicenseCtr = [[HDClientLicenseCtr alloc] initWithAddClient:model];
    if (clientId.length > 0) {
        clientLicenseCtr = [[HDClientLicenseCtr alloc] init];
    }
    [self addChildViewController:clientLicenseCtr];
    [self.view addSubview:clientLicenseCtr.view];
    [clientLicenseCtr.view makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(line.bottom);
        make.bottom.equalTo(vSave.top);
    }];
}
@end
