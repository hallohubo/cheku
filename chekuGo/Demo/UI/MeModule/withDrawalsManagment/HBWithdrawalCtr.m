//
//  HBWithdrawalCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/1/25.
//Copyright © 2018年 hufan. All rights reserved.
//
#define titleLeft @[@[@"收款银行",@"银行卡号",@"银行账户"],@[@"冻结金额",@"提现金额"]]
#define titleRight @[@[@"请输入收款银行",@"请输入银行卡号",@"请输入银行账户"],@[@"",@"请输入提现金额"]]

#import "HBWithdrawalCtr.h"
#import "HBWithdrawalCell.h"

@interface HBWithdrawalCtr ()<UITextFieldDelegate>{
    IBOutlet UIView         *vHead;
    IBOutlet UIView         *vBottom;
    IBOutlet UILabel        *lbAccout;
    IBOutlet UIButton       *btnSubmit;
    IBOutlet UIButton       *btnEndEdit;
    IBOutlet UITableView    *tbv;
    NSURLSessionDataTask    *task;
    HBWithdrawalModel       *model;
    HDHUD                   *hud;
    NSString                *strDeposit;    //冻结金额数
    NSString                *strBank;       //银行名称
    NSString                *strBankCardNum;//银行卡号
    NSString                *strBankAccount;//银行账户信息
    NSString                *strWithdrawalMoney;
    CGFloat contentHeight;
}

@end

@implementation HBWithdrawalCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getDepositHttp];
    [self getBankInformation];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
   
}

- (void)viewWillAppear:(BOOL)animated {
    contentHeight = tbv.contentSize.height;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    //注册通知,监听键盘消失事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHidden:)
                                                 name:UIKeyboardDidHideNotification object:nil];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    task = nil;
    [hud hiden];
    hud = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *str = @"HBWithdrawalCell";
    HBWithdrawalCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HBWithdrawalCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.lbTitle.text   = titleLeft[indexPath.section][indexPath.row];
    cell.tfContent.placeholder = titleRight[indexPath.section][indexPath.row];
    cell.tfContent.delegate = self;
    cell.tfContent.tag = indexPath.section == 0? indexPath.row: indexPath.row + 3;
    cell.tfContent.userInteractionEnabled   = NO;
    switch (indexPath.section) {
        case 0:{
            switch (indexPath.row) {
                case 0:{
                    cell.tfContent.placeholder  = (strBank.length > 1)? strBank: @"请到银行管理页面设置银行信息";
                    return cell;
                }
                case 1:{
                    cell.tfContent.placeholder  = (strBankCardNum.length >1 )? strBankCardNum: @"请到银行管理页面设置银行信息";
                    return cell;
                }
                case 2:{
                    cell.tfContent.placeholder  = (strBankAccount.length > 1)? strBankAccount: @"请到银行管理页面设置银行信息";
                    return cell;
                }
                default:
                    break;
            }
            break;
        }
        case 1:{
            switch (indexPath.row) {
                case 0:{
                    cell.tfContent.placeholder  = strDeposit;
                    [cell.tfContent setValue:HDCOLOR_DARKBLUE forKeyPath:@"_placeholderLabel.textColor"];
                    [cell.tfContent setValue:[UIFont boldSystemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
                    return cell;
                }
                case 1:{
                    if (!strBankAccount.length > 1) {
                        cell.tfContent.placeholder = @"请到银行管理页面设置银行信息" ;
                        return cell;
                    }
                    cell.tfContent.userInteractionEnabled  = YES;
                    [cell.tfContent setKeyboardType:UIKeyboardTypeNumberPad];
                    return cell;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return cell;
}

#pragma mark - textField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    CGPoint scrollPoint = CGPointMake(0, -64);
    [tbv setContentOffset:scrollPoint animated:YES];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSMutableString *text = [NSMutableString stringWithString:textField.text];
    [text replaceCharactersInRange:range withString:string];
    strWithdrawalMoney = text;
    return YES;
    
}

#pragma mark - UIScrollViewDelegate
#pragma mark

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if ([scrollView isEqual:tbv]) {
        CGFloat y = tbv.contentOffset.y;
        if (y < -70.) {
            [self.view endEditing:YES];
        }
//    }
}

#pragma mark - event


- (IBAction)confirmClick:(UIButton *)sender {
    if (!strWithdrawalMoney.intValue > 0) {
        [HDHelper say:@"请输入提取金额！"];
        return;
    }
    if (strWithdrawalMoney.intValue > (lbAccout.text.intValue - strDeposit.intValue)) {
        [HDHelper say:@"提取金额超额，请核对！"];
        return;
    }
    [self postExtractCashHttp];
}

- (IBAction)endEditing:(id)sender {
    [self.view endEditing:YES];
}

- (void)getDepositHttp {//余额和冻结金额
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:@"company/balance" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            [HDHelper say:error.desc];
            return ;
        }
        strDeposit  = HDFORMAT(@"¥%@",JSON(json[@"freezeBalance"]));
        lbAccout.text  = HDFORMAT(@"%@元",JSON(json[@"balance"]));
        [tbv reloadData];
    }];
}

- (void)getBankInformation {//查询银行信息
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    
    task = [helper getPath:@"my-bank-data" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            [HDHelper say:error.desc];
            return ;
        }
        NSDictionary *d = json;
        model = [HDHttpHelper model:[HBWithdrawalModel new] fromDictionary:d];
        strBank         = model.bankName;
        strBankCardNum  = model.bankNo;
        strBankAccount  = model.bankAccount;
        [tbv reloadData];
    }];
}


- (void)postExtractCashHttp {
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    helper.parameters = @{@"note":              HDSTR(@""),//备注,
                          @"bankId":            HDSTR(@""),//银行编号,
                          @"widthdrawTime":     HDSTR(model.createTime),//提现申请时间
                          @"companyName":       HDSTR(@""),//公司名称
                          @"widthdrawMoney":    HDSTR(strWithdrawalMoney),//提现金额
                          @"bankName":          HDSTR(model.bankName),//收款银行
                          @"bankNo":            HDSTR(model.bankNo),//银行卡号
                          @"bankAccount":       HDSTR(model.bankAccount),//账户名称
                          @"openingBank":       HDSTR(model.openingBank)};//开户行
    task = [helper postPath:@"company-withdraw-cash" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        [HDHelper say:@"保存成功！"];
        if (self.cancelBlock) {
            self.cancelBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    tbv.contentSize  = CGSizeMake(HDDeviceSize.width, contentHeight + height);
    [tbv updateConstraints];
    //tbv.contentOffset = CGPointMake(0, contentHeight);
    
}

- (void)keyboardDidHidden:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    tbv.contentSize = CGSizeMake(HDDeviceSize.width, contentHeight - height+64);
    [tbv reloadData];
    //tbv.contentOffset = CGPointMake(0, contentHeight);
}


#pragma mark - setter


- (void)setup{
    self.title = @"提现";
    btnEndEdit.hidden = YES;
    btnSubmit.layer.cornerRadius    = 5.f;
    btnSubmit.layer.masksToBounds   = YES;
    [tbv setTableFooterView:vBottom];
    [tbv setTableHeaderView:vHead];
    model = [HBWithdrawalModel new];
    strWithdrawalMoney = @"0";
}

@end

@implementation HBWithdrawalModel


@end

