//
//  HBChangePasswordCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/2/12.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBChangePasswordCtr.h"

@interface HBChangePasswordCtr () {
    IBOutlet UIButton       *btnSave;
    IBOutlet UIButton       *btnEyeOld;
    IBOutlet UIButton       *btnEyeNew;
    IBOutlet UIButton       *btnEyeConfirm;
    IBOutlet UILabel        *lbAccount;
    IBOutlet UITextField    *tfOldPassword;
    IBOutlet UITextField    *tfNewPassword;
    IBOutlet UITextField    *tfConfirmPassword;
    HDHUD                   *hud;
    NSURLSessionDataTask    *task;
}

@end

@implementation HBChangePasswordCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    // Do any additional setup after loading the view from its nib.
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
    textField.text  = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 0:{
            textField.placeholder = textField.text.length > 0? @"": @"请输入原密码";
            break;
        }
        case 1:{
            textField.placeholder = textField.text.length > 0? @"": @"请输入新密码";
            break;
        }
        case 2:{
            textField.placeholder = textField.text.length > 0? @"": @"请再次输入新密码";
            break;
        }
        default:
            break;
    }
}

#pragma mark - event

- (void)httpPostPayConfirm {
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    helper.parameters = @{@"oldPass": HDSTR(tfOldPassword.text),
                          @"newPass": HDSTR(tfNewPassword.text),
                          @"confirmPass":HDSTR(tfConfirmPassword.text)};
    Dlog(@"=%@=%@",tfOldPassword.text,tfConfirmPassword.text);
    task = [helper postPath:@"company-user/update-pwd" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        [HDHelper say:@"修改密码成功！"];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (IBAction)allButtonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 0:{
            btnEyeOld.selected  = !btnEyeOld.selected;
            [ btnEyeOld setImage:btnEyeOld.selected?HDIMAGE(@"eyeForShow"): HDIMAGE(@"eyeForHidden") forState:UIControlStateSelected];
            [tfOldPassword setSecureTextEntry:btnEyeOld.selected];
            break;
        }
        case 1:{
            btnEyeNew.selected  = !btnEyeNew.selected;
             [btnEyeNew setImage:btnEyeNew.selected? HDIMAGE(@"eyeForShow"): HDIMAGE(@"eyeForHidden") forState:UIControlStateSelected];
            [tfNewPassword setSecureTextEntry:btnEyeNew.selected];
            break;
        }
        case 2:{
            btnEyeConfirm.selected  = !btnEyeConfirm.selected;
             [ btnEyeConfirm setImage:btnEyeConfirm.selected?HDIMAGE(@"eyeForShow"): HDIMAGE(@"eyeForHidden") forState:UIControlStateSelected];
            [tfConfirmPassword setSecureTextEntry:btnEyeConfirm.selected];
            break;
        }
        case 3:{
            if (tfConfirmPassword.text.length < 6 || tfOldPassword.text.length < 6 || tfNewPassword.text.length < 6 ) {
                [HDHelper say:@"请输入至少6位数的密码！"];
                return;
            }
            if (![tfConfirmPassword.text isEqualToString:tfNewPassword.text]) {
                [HDHelper say:@"两次输入的密码不一样，请重新输入！"];
                return;
            }
            [self httpPostPayConfirm];
        }

        default:
            break;
    }
    }

#pragma mark - setter
#pragma mark -
- (void)setup {
    self.title = @"修改密码";
    lbAccount.text  = HDGI.loginUser.phone;
    btnSave.layer.cornerRadius = 10.f;
    btnSave.layer.masksToBounds;
    btnEyeNew.selected = NO;
    btnEyeOld.selected = NO;
    btnEyeConfirm.selected = NO;
    [tfOldPassword setSecureTextEntry:btnEyeOld.selected];
    [tfNewPassword setSecureTextEntry:btnEyeNew.selected];
    [tfConfirmPassword setSecureTextEntry:btnEyeConfirm.selected];
}
@end
