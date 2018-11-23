//
//  HDAddInspectionCtr.m
//  Demo
//
//  Created by hufan on 2018/2/1.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDAddInspectionCtr.h"
#import "HDAddCarDetailCell.h"
#import "HDTableView.h"

@interface HDAddInspectionCtr (){
    IBOutlet HDTableView *tbv;
    IBOutlet UIView *headView;
    IBOutlet UIDatePicker *picker;
    IBOutlet NSLayoutConstraint *lc_pickerBottom;
    NSURLSessionDataTask *task;
    HDHUD *hud;
    NSString *workUser;
    NSString *yearlyDate;
    NSString *vehicleId;
    NSString *nextYearlyDate;
    NSString *inspectionId;
}

@end

@implementation HDAddInspectionCtr

- (id)initWithCarIdentifier:(NSString *)identifier{
    if (self = [super init]) {
        vehicleId = identifier;
    }
    return self;
}

- (id)initWithInspectionId:(NSString *)inspection{
    if (self = [super init]) {
        inspectionId = inspection;
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

- (void)textFiledValueChanged:(UITextField *)textField{
    switch (textField.tag) {
        case 0:{
            workUser = textField.text;
            break;
        }
        case 1:{
            
            break;
        }
        default:
            break;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag >= 1) {
        [self.view endEditing:YES];
        lc_pickerBottom.constant = 0;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        picker.tag = textField.tag;
        return NO;
    }
    lc_pickerBottom.constant = -210;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    return YES;
}
- (IBAction)datepickerValueChanged:(UIDatePicker *)sender{
    if (sender.tag == 1) {
        yearlyDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
    }else{
        nextYearlyDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
    }
    [tbv reloadData];
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"HDAddCarDetailCell";
    HDAddCarDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HDAddCarDetailCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.lb_title.text = @[@"经办人", @"年检时间", @"下次年检日期"][indexPath.row];
    cell.tf.placeholder = @[@"请输入经办人姓名", @"请输入年检时间", @"请输入下次年检日期"][indexPath.row];
    cell.tf.text = @[HDSTR(workUser), HDSTR(yearlyDate), HDSTR(nextYearlyDate)][indexPath.row];
    cell.tf.tag = indexPath.row;
    cell.tf.delegate = self;
    BOOL isFiliale = [HDGI.loginUser.role isEqualToString:@"Filiale"];
    BOOL isExcutor = [HDGI.loginUser.role isEqualToString:@"Executor"];
    cell.tf.userInteractionEnabled = (isFiliale && inspectionId.length > 0) || (isExcutor && inspectionId.length == 0);
    [cell.tf addTarget:self action:@selector(textFiledValueChanged:) forControlEvents:UIControlEventAllEditingEvents];
    return cell;
}

#pragma mark - event
- (void)httpGet{
    if (!inspectionId || inspectionId.length == 0) {
        return;
    }
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:HDFORMAT(@"/vehicle-yearly/%@", inspectionId) object:nil finished:^(HDError *error, id object, BOOL isLast, id data) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        NSDictionary *dic = data;
        workUser = JSON(dic[@"workUser"]);
        yearlyDate = JSON(dic[@"yearlyDate"]);
        nextYearlyDate = JSON(dic[@"nextYearlyDate"]);
        [tbv reloadData];
    }];
}
- (void)httpPost{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    helper.parameters = @{@"vehicleId": HDSTR(vehicleId),
                          @"workUser": HDSTR(workUser),
                          @"yearlyDate": HDSTR(yearlyDate),
                          @"nextYearlyDate": HDSTR(nextYearlyDate)
                          };
    task = [helper postPath:@"/vehicle-yearly" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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
                          @"yearlyDate": HDSTR(yearlyDate),
                          @"nextYearlyDate": HDSTR(nextYearlyDate)
                          };
    task = [helper putPath:HDFORMAT(@"/vehicle-yearly/%@", inspectionId) object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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
    if (workUser.length == 0) {
        [HDHelper say:@"请输入经办人"];
        return;
    }
    if (workUser.length > 20) {
        [HDHelper say:@"请输入20字以内经办人名字"];
        return;
    }
    if (yearlyDate.length == 0) {
        [HDHelper say:@"请输入年检时间"];
        return;
    }
    if (yearlyDate.length > 20) {
        [HDHelper say:@"请输入正确年检日期"];
        return;
    }
    if (nextYearlyDate.length == 0 || nextYearlyDate.length > 20) {
        [HDHelper say:@"请输下次年检日期"];
        return;
    }
    if (inspectionId.length > 0) {
        [self httpPut];
        return;
    }
    [self httpPost];
}
- (IBAction)doPickerButtonAction:(UIButton *)sender{
    if (sender.tag == 1) {
        NSString *date = [HDDateHelper stringWithDate:picker.date withFormat:@"yyyy-MM-dd"];
        if (picker.tag == 1) {
            yearlyDate = date;
        }else{
            nextYearlyDate = date;
        }
        [tbv reloadData];
    }
    lc_pickerBottom.constant = -210.;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}
#pragma mark - setter
- (void)setup{
    self.title = @"年检录入";
    lc_pickerBottom.constant = -210.;
    [self.view updateConstraints];
}
- (void)setTableFooter{
    BOOL isFiliale = [HDGI.loginUser.role isEqualToString:@"Filiale"];
    BOOL isExcutor = [HDGI.loginUser.role isEqualToString:@"Executor"];
    if ((isFiliale && inspectionId.length > 0) || (isExcutor && inspectionId.length == 0)) {
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
