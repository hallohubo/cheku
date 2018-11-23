//
//  HBLoginViewCtr.m
//  Demo
//
//  Created by hubo on 2017/12/19.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import "HDLoginViewCtr.h"
#import "HDUMHelper.h"
#import "LDCry.h"
#import "HBForgetPasswordCtr.h"

@interface HDLoginViewCtr (){
    IBOutlet UITextField    *tfPassword;
    IBOutlet UITextField    *tfPhone;
    IBOutlet UIView         *v_back;
    IBOutlet UIImageView    *imv;
    IBOutlet UIButton       *btn_login;
    IBOutlet UIButton       *btnForgetPassword;
    IBOutlet NSLayoutConstraint *lcHeightForTextField;
}

@end

@implementation HDLoginViewCtr

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [HDUMHelper setupbeginLog:@"登录页"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [HDUMHelper setupEndLog:@"登录页"];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieled delegate
#pragma mark

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
        lcHeightForTextField.constant = 0.f;
        [UIView animateWithDuration:0.4 animations:^{
            [self.view layoutIfNeeded];
        }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    lcHeightForTextField.constant = 73.f;
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}



#pragma mark - event

- (void)passwordHttpLogin:(NSString *)mobile password:(NSString *)pwd{
    HDHttpHelper *helper = [HDHttpHelper instance];
    NSString *password = [LDCry md5:pwd];
    helper.parameters = @{@"username": HDSTR(mobile), @"password": HDSTR(password)};
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    [helper postPath:@"/session/login" object:[HDLoginUserModel new] finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            [HDHelper say:error.desc];
            return ;
        }
        tfPassword.text = nil;
        HDGI.loginUser  = nil;
        HDLoginUserModel *model = object;
        NSDictionary *user = json[@"user"];
        model.ID = JSON(user[@"id"]);
        [model saveToLocal];
        HDGI.loginUser = model;
        HDGI.token = JSON(json[@"token"]);
        [HDAppHelper saveTokenToLocal:HDGI.token];
        if (self.loginFinishedBlock) {
            self.loginFinishedBlock(model);
            return;
        }
        //第一次登录
        UIViewController *ctr = [HDAppHelper builder];
        [self presentViewController:ctr animated:YES completion:nil];
    }];
}

- (IBAction)login:(id)sender {
    if (tfPhone.text.length > 30) {
        [HDHelper say:@"请输入正确账号"];
        return;
    }
    if (![HDHelper isValidatePassword:tfPassword.text]) {
        [HDHelper say:@"请输入6位数以上密码"];
        return;
    }
    [self.view endEditing:YES];
    [self passwordHttpLogin:tfPhone.text password:tfPassword.text];
}

- (IBAction)resetPassworld:(id)sender {
    HBForgetPasswordCtr *ctr = [[HBForgetPasswordCtr alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ctr];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - setter

- (void)setup{
    self.title = @"登录";
    v_back.layer.cornerRadius       = 5.;
    v_back.layer.masksToBounds      = YES;
    v_back.layer.borderWidth        = 1.;
    v_back.layer.borderColor        = HDCOLOR_GRAY.CGColor;
    btn_login.layer.cornerRadius    = 5.;
    btn_login.layer.masksToBounds   = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
