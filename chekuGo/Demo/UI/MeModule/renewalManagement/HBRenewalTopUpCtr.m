//
//  HBRenewalTopUpCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/1/23.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HBRenewalTopUpCtr.h"
#import "HBTopUpDetailCtr.h"

@interface HBRenewalTopUpCtr (){
    IBOutlet UILabel        *lbAnnualFee;
    IBOutlet UITextField    *tfYears;
    IBOutlet UILabel        *lbAcount;
    IBOutlet UIButton       *btnSubmit;
    NSURLSessionDataTask    *task;
    HDHUD                   *hud;
    NSString                *strAnnualFee;
    NSString                *orderId;
    
}

@end

@implementation HBRenewalTopUpCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self getCountHttp];
    
    [self getAnnualFeeHttp];
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

#pragma mark - judge string

//判断是否为整形：
- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形：
- (BOOL)isPureFloat:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}


#pragma mark - event

- (IBAction)submit:(UIButton *)sender {
    if (tfYears.text.length <0) {
        [HDHelper say:@"请输入续费年数"];
        [tfYears resignFirstResponder];
        return;
    }
    //判断是否是纯数字
    if( ![self isPureInt:tfYears.text] || ![self isPureFloat:tfYears.text]) {
        [HDHelper say:@"请输入纯数字"];
        [tfYears resignFirstResponder];
        return;
    }
    NSString *strId = HDGI.loginUser.companyId;
    [self addRenewalPostHttp:strId renewNumber:tfYears.text];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)addRenewalPostHttp:(NSString *)Id renewNumber:(NSString *)number {
    HDHttpHelper *helper = [HDHttpHelper instance];
    helper.parameters = @{@"renewNumber": HDSTR(number)
                          };
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    [helper postPath:@"company-renew" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            [HDHelper say:error.desc];
            return ;
        }
        orderId = JSON(json[@"id"]);
        if (orderId.length >1) {
            HBTopUpDetailCtr *ctr = [[HBTopUpDetailCtr alloc] initWithTitle:orderId];
            [ctr setCancelBlock:^{
                if (self.backBlock) {
                    self.backBlock();
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [self.navigationController pushViewController:ctr animated:YES];
        }
    }];
}

- (void)getCountHttp{//账户余额
    HDHttpHelper *helper = [HDHttpHelper instance];
    helper.parameters = @{@"": HDSTR(@"")};
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    task = [helper getPath:@"company/balance" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        if (!HDGI.loginUser) {
            return;
        }
        HDLoginUserModel *m = HDGI.loginUser;
        lbAcount.text = JSON(json[@"balance"]);
    }];
    
}


- (void)getAnnualFeeHttp{//续费单价
    HDHttpHelper *helper = [HDHttpHelper instance];
    helper.parameters = @{@"": HDSTR(@"")};
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    task = [helper getPath:@"company-renew/annual-fee" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        if (!HDGI.loginUser) {
            return;
        }
//        HDLoginUserModel *m = HDGI.loginUser;
        
        strAnnualFee  = JSON(json[@"annualFee"]);
        lbAnnualFee.text = HDFORMAT(@"%@元/1年",strAnnualFee);
    }];

            }

#pragma mark - UITextFieled delegate
#pragma mark

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    tfYears.placeholder = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.placeholder = tfYears.text.length > 0? @"": @"请输入续费年数";
}


#pragma mark - setter
- (void)setup{
    self.title = @"续费";
}

@end
