//
//  HBEditBankCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/2/10.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBEditBankCtr.h"

@interface HBEditBankCtr () {
    IBOutlet UIButton       *btnConfirm;
    IBOutlet UITextField    *tfCompanyName;
    IBOutlet UITextField    *tfBankAccount;
    IBOutlet UITextField    *tfBankName;
    IBOutlet UITextField    *tfBankCard;
    NSString                *strCompanyName;
    NSString                *strBankAccount;
    NSString                *strBankName;
    NSString                *strBankCard;
    NSURLSessionDataTask    *task;
    HDHUD                   *hud;
    HBEditBankMode          *bankModel;
    NSString                *strIsEditOrAdd;

}

@end

@implementation HBEditBankCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpMyBankInformation];
    // Do any additional setup after loading the view from its nib.
}

- (instancetype)initWithString:(NSString *)addButtonConstent {
    if(self = [super init]){
        strIsEditOrAdd = addButtonConstent;
        return  self;
    }
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieled delegate
#pragma mark

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.placeholder = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 0:{
            textField.placeholder = textField.text.length > 0? @"": @"请输入所属分公司名称";
            break;
        }
        case 1:{
            textField.placeholder = textField.text.length > 0? @"": @"请输入收款银行";
            break;
        }
        case 2:{
            textField.placeholder = textField.text.length > 0? @"": @"请输入银行卡号";
            break;
        }
        case 3:{
            textField.placeholder = textField.text.length > 0? @"": @"请输入收款账户";
            break;
        }
        default:
            break;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSMutableString *text = [NSMutableString stringWithString:textField.text];
    [text replaceCharactersInRange:range withString:string];
    switch (textField.tag) {
        case 0:{
            strCompanyName  = text;
            break;
        }
        case 1:{
            strBankName     = text;
            break;
        }
        case 2:{
            strBankCard     = text;
            break;
        }
        case 3:{
            strBankAccount  = text;
            break;
        }
        default:
            break;
    }
    return YES;
}


#pragma mark - event

- (void)httpMyBankInformation {
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    NSString *str = HDFORMAT(@"bank-data/%@",strIsEditOrAdd);
    NSString *strPath = [HDGI.loginUser.role isEqualToString:@"Main"]? str: @"my-bank-data";//主账号和别的账户接口参数不一样
    task = [helper getPath:strPath object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        NSDictionary *dic = json;
        bankModel = [HDHttpHelper model:[HBEditBankMode new] fromDictionary:dic];
        if (bankModel) {
            strCompanyName      = bankModel.companyName.length > 0 ?bankModel.companyName: HDGI.loginUser.companyName;
            strBankCard         = bankModel.bankNo;
            strBankName         = bankModel.bankName;
            strBankAccount      = bankModel.bankAccount;
            tfBankAccount.text  = strBankAccount;
            tfBankName.text     = strBankName;
            tfBankCard.text     = strBankCard;
            tfCompanyName.text  = strCompanyName;
        }
    }];
}


- (void)httpPutPackageList {
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    helper.parameters = @{@"bankAccount":       HDSTR(strBankAccount),//账户名称,
                          @"bankNo":            HDSTR(strBankCard),//银行卡号,
                          @"bankName":          HDSTR(strBankName)//银行名称
//                          @"companyName":       HDSTR(strCompanyName)//开户行
                          };
    task = [helper putPath:@"my-bank-data" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        [HDHelper say:@"提交成功！"];
        if (self.finishUpBlock) {
            self.finishUpBlock();
        }
    }];
}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)confirmClick:(id)sender {
    if (tfCompanyName.text.length < 0) {
        [HDHelper say:@"请输入所属分公司名称!"];
        return;
    }
    if (tfBankName.text.length < 0) {
        [HDHelper say:@"请输入银行名称!"];
        return;
    }
    if (tfBankCard.text.length < 0) {
        [HDHelper say:@"请输入卡号!"];
        return;
    }
    if (tfBankName.text.length < 0) {
        [HDHelper say:@"请输入银行账户名称!"];
        return;
    }
    [self httpPutPackageList];
}

#pragma mark - setter and getter

- (void)setup {
    btnConfirm.layer.cornerRadius   = 10.f;
    btnConfirm.layer.masksToBounds  = YES;
    self.title = @"编辑银行信息";
    tfCompanyName.enabled   = NO;
    btnConfirm.hidden       = [HDGI.loginUser.role isEqualToString:@"Filiale"]? NO: YES;
    tfBankAccount.enabled   = [HDGI.loginUser.role isEqualToString:@"Filiale"]? YES: NO;
    tfBankCard.enabled      = [HDGI.loginUser.role isEqualToString:@"Filiale"]? YES: NO;
    tfBankName.enabled      = [HDGI.loginUser.role isEqualToString:@"Filiale"]? YES: NO;
}

@end

@implementation HBEditBankMode

@end


