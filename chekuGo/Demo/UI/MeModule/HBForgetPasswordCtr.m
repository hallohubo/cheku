//
//  HBForgetPasswordCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/3/28.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBForgetPasswordCtr.h"

@interface HBForgetPasswordCtr () {
    IBOutlet UIButton       *btnCancel;
    IBOutlet UIButton       *btnConfirm;
    IBOutlet UITextField    *tfUsername;
    IBOutlet UITextField    *tfPhoneNumber;
    NSURLSessionDataTask    *task;
    HDHUD                   *hud;
}

@end

@implementation HBForgetPasswordCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    {[self setup];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextFieled delegate
#pragma mark

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

}


- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - event

- (void)httpGetNewPassword {
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    helper.parameters = @{@"username": HDSTR(tfUsername.text),
                          @"phone": HDSTR(tfPhoneNumber.text)
                          };
    Dlog(@"=%@=%@",tfUsername.text,tfPhoneNumber.text);
    task = [helper postPath:@"/session/find-pwd" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        [HDHelper say:@"密码已发送至您的手机，请查看后重新登录！"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (IBAction)allButtonClick:(UIButton *)sender {
    switch (sender.tag) {
        case 0:{
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case 1:{
            if (tfUsername.text.length < 1) {
                [HDHelper say:@"请输入正确的用户名！"];
                return;
            }
            if (tfPhoneNumber.text.length < 11 ) {
                [HDHelper say:@"请输入正确的手机号码！"];
                return;
            }
            [self httpGetNewPassword];
            break;
        }            
        default:
            break;
    }
}
#pragma mark - setter
- (void)setup {
    self.title = @"忘记密码";
    btnConfirm.layer.cornerRadius   = 10.f;
    btnConfirm.layer.masksToBounds  = YES;
    btnCancel.layer.cornerRadius    = 10.f;
    btnCancel.layer.masksToBounds   = YES;
}
@end
