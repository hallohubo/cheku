//
//  HDAddMaintainCtr.m
//  Demo
//
//  Created by hufan on 2018/2/1.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDAddMaintainCtr.h"
#import "HDAddCarDetailCell.h"
#import "HDTableView.h"

@interface HDAddMaintainCtr (){
    IBOutlet HDTableView *tbv;
    IBOutlet UIView *headView;
    IBOutlet UIDatePicker *picker;
    IBOutlet NSLayoutConstraint *lc_pickerBottom;
    NSURLSessionDataTask *task;
    HDHUD *hud;
    NSString *vehicleId;
    NSString *lastDate;
    NSString *vkt;
    NSString *workUser;
    NSString *expense;
    NSString *needMaintainVkt;
    NSString *maintainId;
}

@end

@implementation HDAddMaintainCtr

- (id)initWithCarIdentifier:(NSString *)identifier{
    if (self = [super init]) {
        vehicleId = identifier;
    }
    return self;
}

- (id)initWithMaintainId:(NSString *)maintain{
    if (self = [super init]) {
        maintainId = maintain;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpGet];
    [self setTableFooter];
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

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    lc_pickerBottom.constant = -210;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    lc_pickerBottom.constant = -210;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 0) {
        [self.view endEditing:YES];
        lc_pickerBottom.constant = 0;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        return NO;
    }
    lc_pickerBottom.constant = -210;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    if (textField.tag == 4) {
        CGSize size = tbv.contentSize;
        size.height += 300;
        tbv.contentSize = size;
        [tbv setContentOffset:CGPointMake(0, size.height - CGRectGetHeight(tbv.frame))];
    }
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    if (textField.tag == 4) {
        CGSize size = tbv.contentSize;
        size.height -= 300;
        tbv.contentSize = size;
    }
    return YES;
}

- (IBAction)datepickerValueChanged:(UIDatePicker *)sender{
    lastDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
    [tbv reloadData];
}

- (void)textFiledValueChanged:(UITextField *)textField{
    switch (textField.tag) {
        case 0:{
//            maintainDate = textField.text;
            break;
        }
        case 1:{
            vkt = textField.text;
            break;
        }
        case 2:{
            workUser = textField.text;
            break;
        }
        case 3:{
            expense = textField.text;
            break;
        }
        case 4:{
            needMaintainVkt = textField.text;
            break;
        }
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
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
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"HDAddCarDetailCell";
    HDAddCarDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HDAddCarDetailCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.lb_title.text = @[@"保养日期", @"当前公里数", @"经办人", @"保养费用", @"保养公里数"][indexPath.row];
    cell.tf.placeholder = @[@"请输入保养日期", @"请输入当前公里数", @"请输入经办人", @"请输入保养费用", @"请输入保养公里数"][indexPath.row];
    cell.tf.text = @[HDSTR(lastDate), HDSTR(vkt), HDSTR(workUser), HDSTR(expense), HDSTR(needMaintainVkt)][indexPath.row];
    cell.tf.tag = indexPath.row;
    cell.tf.delegate = self;
    cell.tf.keyboardType = HDIndexPath(0, 3)? UIKeyboardTypeNumbersAndPunctuation: UIKeyboardTypeDefault;
    BOOL isFiliale = [HDGI.loginUser.role isEqualToString:@"Filiale"];
    BOOL isExcutor = [HDGI.loginUser.role isEqualToString:@"Executor"];
    cell.tf.userInteractionEnabled = (isFiliale && maintainId.length > 0) || (isExcutor && maintainId.length == 0);
    [cell.tf addTarget:self action:@selector(textFiledValueChanged:) forControlEvents:UIControlEventAllEditingEvents];
    return cell;
}


#pragma mark - event
- (void)httpGet{
    if (!maintainId || maintainId.length == 0) {
        return;
    }
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:HDFORMAT(@"/vehicle-maintain/%@", maintainId) object:nil finished:^(HDError *error, id object, BOOL isLast, id data) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        NSDictionary *dic = data;
        workUser = JSON(dic[@"workUser"]);
        expense = JSON(dic[@"expense"]);
        vkt = JSON(dic[@"vkt"]);
        lastDate = JSON(dic[@"lastDate"]);
        needMaintainVkt = JSON(dic[@"needMaintainVkt"]);
        [tbv reloadData];
    }];
}

- (void)httpPost{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    helper.parameters = @{@"vehicleId": HDSTR(vehicleId),
                          @"workUser": HDSTR(workUser),
                          @"expense": HDSTR(expense),
                          @"vkt": HDSTR(vkt),
                          @"lastDate": HDSTR(lastDate),
                          @"needMaintainVkt": HDSTR(needMaintainVkt)
                          };
    task = [helper postPath:@"/vehicle-maintain" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        [HDHelper say:@"保存成功！"];
        if (self.saveSuccessBlock) {
            self.saveSuccessBlock();
        }
    }];
}

- (void)httpPut{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    helper.parameters = @{@"vehicleId": HDSTR(vehicleId),
                          @"workUser": HDSTR(workUser),
                          @"expense": HDSTR(expense),
                          @"vkt": HDSTR(vkt),
                          @"lastDate": HDSTR(lastDate),
                          @"needMaintainVkt": HDSTR(needMaintainVkt)
                          };
    task = [helper putPath:HDFORMAT(@"/vehicle-maintain/%@", maintainId) object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        [HDHelper say:@"保存成功！"];
        if (self.saveSuccessBlock) {
            self.saveSuccessBlock();
        }
    }];
}

- (IBAction)doSave:(id)sender{
    if (lastDate.length == 0) {
        [HDHelper say:@"请输入保养日期"];
        return;
    }
    if (vkt.length == 0) {
        [HDHelper say:@"请输入当前公里数"];
        return;
    }
    if (vkt.length > 20) {
        [HDHelper say:@"请输入正确公里数"];
        return;
    }
    if (workUser.length == 0) {
        [HDHelper say:@"请输入经办人姓名"];
        return;
    }
    if (workUser.length > 20) {
        [HDHelper say:@"请输入正确经办人姓名"];
        return;
    }
    if (expense.length == 0) {
        [HDHelper say:@"请输入保养费用"];
        return;
    }
    if (expense.length > 20) {
        [HDHelper say:@"请输入正确保养费用"];
        return;
    }
    if (needMaintainVkt.length == 0 || needMaintainVkt.length > 10) {
        [HDHelper say:@"请输入正确保养公里数"];
        return;
    }
    if (maintainId.length > 0) {
        [self httpPut];
        return;
    }
    [self httpPost];
}

- (IBAction)doPickerButtonAction:(UIButton *)sender{
    if (sender.tag == 1) {
        NSString *date = [HDDateHelper stringWithDate:picker.date withFormat:@"yyyy-MM-dd"];
        lastDate = date;
        [tbv reloadData];
    }
    lc_pickerBottom.constant = -210.;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - setter
- (void)setup{
    self.title = @"保养录入";
    lc_pickerBottom.constant = -210;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (void)setTableFooter{
    BOOL isFiliale = [HDGI.loginUser.role isEqualToString:@"Filiale"];
    BOOL isExcutor = [HDGI.loginUser.role isEqualToString:@"Executor"];
    if ((isFiliale && maintainId.length > 0) || (isExcutor && maintainId.length == 0)) {
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 110)];
        [v addSubview:headView];
        v.backgroundColor = [UIColor clearColor];
        [headView makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(v);
            make.center.equalTo(v);
        }];
        tbv.tableFooterView = v;
    }
}

@end
