//
//  HDStepThreeCtr.m
//  Demo
//
//  Created by hufan on 2018/2/9.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDStepThreeCtr.h"
#import "HDAddCarDetailCell.h"
#import "HDClientSexCell.h"
#import "HDTableView.h"
#import "HDValidDateCell.h"
#import "HDStepFourCtr.h"
#import "HBGarageCtr.h"

@interface HDStepThreeCtr (){
    IBOutlet HDTableView *tbv;
    NSURLSessionDataTask *task;
    HDHUD *hud;
    
    IBOutlet UIView *footView;
    IBOutlet UIButton *btn_complete;
    IBOutlet UIDatePicker *picker;
    IBOutlet UIPickerView *pickerView;
    IBOutlet NSLayoutConstraint *lc_pickerBottom;
    
    HDBargainModel *model;
    CGFloat contentSizeHeight;
    UITextField *curTextFiled;
    HDClientModel *clientModel;
    UIEdgeInsets edSet;
    NSIndexPath *myIndexPath;
    BOOL isSelectWind;
}
@property (nonatomic, assign) CGRect activedTextFieldRect;
@end

@implementation HDStepThreeCtr

- (id)initWithClientModel:(HDClientModel *)model{
    if (self = [super init]) {
        clientModel = model;
    }
    return self;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setup];
    [self setTitleView];
    [self setTableFooter];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    task = nil;
    [hud hiden];
    hud = nil;
}
- (void)viewDidAppear:(BOOL)animated{
    contentSizeHeight = tbv.contentSize.height;
}

- (void)viewDidDisappear:(BOOL)animated{
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    lc_pickerBottom.constant = 300;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    tbv.contentSize = CGSizeMake(HDDeviceSize.width, contentSizeHeight + 300);
    [tbv reloadData];
    if (!myIndexPath) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //刷新完成
        [tbv scrollToRowAtIndexPath:myIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    });

}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return 28;
}

#pragma mark - UIPickerViewDelegate
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return HDFORMAT(@"%d", row + 1);
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    curTextFiled.text = HDFORMAT(@"%d", row + 1);
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    lc_pickerBottom.constant = 300;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    tbv.contentSize = CGSizeMake(HDDeviceSize.width, contentSizeHeight+300);;
    return YES;
}

- (void)textFiledValueChanged:(UITextField *)textField{
    switch (textField.tag) {
        case 0:{
            model.bargainNo = textField.text;
            break;
        }
        case 1:{
            model.signRealname = textField.text;
            break;
        }
        case 2:{
            model.signCardId = textField.text;
            break;
        }
        case 3:{
            //对接人就是用户
            break;
        }
        case 4:{
            model.vehicleNo = textField.text;
            break;
        }
        case 5:{
            model.vehicleBrand = textField.text;
            break;
        }
        case 6:{
            //合同类型
            break;
        }
        case 7:{
            model.deposit = textField.text;
            break;
        }
        case 8:{
            //合同有效期
            break;
        }
        case 9:{
            //收租方式
            break;
        }
        case 10:{
            //合同租金日期
            model.rentDay = textField.text;
            break;
        }
        case 11:{
            model.riskDay = textField.text;
        }
        case 12:{
            model.monthRate = textField.text;
        }
        case 13:{
            model.dailyRate = textField.text;
            break;
        }
        case 14:{
            model.returnActivityMoneyMonth = textField.text;
            break;
        }
        case 15:{
            model.returnActivityMoneyDay = textField.text;
            break;
        }
        case 16:{
            break;
        }
        case 17:{
            //交租日期
            break;
        }
        case 18:{
            //备注
            model.note = textField.text;
            break;
        }
        default:
            break;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    myIndexPath = [tbv indexPathForCell:(UITableViewCell *)[[textField superview] superview]];
    Dlog(@"indexPath:%@",myIndexPath);
    
    if (textField.tag == 10 || textField.tag == 11 || textField.tag >= 90) {//时间选择器
            //收起键盘，弹出picker
            [self.view endEditing:YES];
            lc_pickerBottom.constant = 0;
            picker.tag = textField.tag;
            [UIView animateWithDuration:0.3 animations:^{
                [self.view layoutIfNeeded];
            }];
            picker.hidden = (textField.tag == 10 || textField.tag == 11);
            pickerView.hidden = !picker.hidden;
            //靠底部了，contentsize拉长
            curTextFiled = textField;
            CGSize size = CGSizeMake(HDDeviceSize.width, contentSizeHeight);;
            size.height += 300;
            tbv.contentSize = size;
            return NO;
        }
        //其他情况收起picker
        lc_pickerBottom.constant = 300;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        return YES;
    }


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activedTextFieldRect = [textField convertRect:textField.frame toView:tbv];
    edSet = UIEdgeInsetsMake(self.activedTextFieldRect.origin.y, 0, 0, 0 );
    Dlog(@"edgeInsets:%@", NSStringFromCGRect(self.activedTextFieldRect));
    Dlog(@"edgeInsets:%@", NSStringFromUIEdgeInsets(edSet));
    if (textField.tag >= 0) {//靠底部了，contentSize拉长
        CGSize size = CGSizeMake(HDDeviceSize.width, contentSizeHeight);
        size.height += 300;
        tbv.contentSize = size;
        
        if ((self.activedTextFieldRect.origin.y + self.activedTextFieldRect.size.height +64) >  ([UIScreen mainScreen].bounds.size.height - 300))
        {
            [UIView animateWithDuration:.5 animations:^{
                tbv.contentOffset = CGPointMake(0, 64 + self.activedTextFieldRect.origin.y + self.activedTextFieldRect.size.height - ([UIScreen mainScreen].bounds.size.height - 300));
            }];
        }
    }

}


- (IBAction)datepickerValueChanged:(UIDatePicker *)sender {
    if (sender.tag == 10) {
//        model.rentDay = [HDDateHelper stringWithDate:sender.date withFormat:@"dd"];
//        curTextFiled.text = model.rentDay;
    }
    
    if (sender.tag == 90) {
        model.startDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
        curTextFiled.text = model.startDate;
    }
    if (sender.tag == 91) {
        model.endDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
        curTextFiled.text = model.endDate;
    }
    if (sender.tag == 100) {
        model.rentingStartDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
        curTextFiled.text = model.rentingStartDate;
    }
    if (sender.tag == 101) {
        model.rentingEndDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
        curTextFiled.text = model.rentingEndDate;
    }
    if (sender.tag == 120) {
        model.takeCarDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
        curTextFiled.text = model.takeCarDate;
    }

    
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (HDIndexPath(0, 11)) {
        return isSelectWind? .1 : 90;
    }else {
        return 90;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 19;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (HDIndexPath(0, 6)) {
        static NSString *str = @"HDClientSexCell0";
        HDClientSexCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [HDClientSexCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.lb_title.text  =  @"合同类型";
        NSString *str0      =  @"经租合同";
        NSString *str1      =  @"融租合同";
        [cell.btn0 setTitle:str0 forState:UIControlStateNormal];
        [cell.btn1 setTitle:str1 forState:UIControlStateNormal];
        
        if (model.bargainType.length == 0) {
            cell.sex = @"";
        }else {
            cell.sex = [model.bargainType isEqualToString:@"经租合同"]? @"1" : @"0";
        }
        cell.chooseSex = ^(int s) {
            model.bargainType = (s == 1)? @"经租合同": @"融租合同";
        };
        return cell;
    }
    if (HDIndexPath(0, 9)) {
        static NSString *str = @"HDClientSexCell1";
        HDClientSexCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [HDClientSexCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.lb_title.text  =  @"收租方式";
        NSString *str0      =  @"普通模式";
        NSString *str1      =  @"风控模式";
        [cell.btn0 setTitle:str0 forState:UIControlStateNormal];
        [cell.btn1 setTitle:str1 forState:UIControlStateNormal];
            if (model.rentalsMethod.length == 0) {
                cell.sex =  @"";
            }else{
                cell.sex = (model.rentalsMethod.intValue == 1)? @"1" : @"0";
            }
            cell.chooseSex = ^(int s) {
                model.rentalsMethod = (s == 1)? @"1": @"0";
                model.riskDay = (s==1)? @"0" : @"";
                isSelectWind = (s==1)? YES : NO;
                [tbv reloadData];
            };
        return cell;
    }
    if (HDIndexPath(0, 8) || HDIndexPath(0, 17)) {
        static NSString *str = @"HDValidDateCell";
        HDValidDateCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [HDValidDateCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.lb_title.text  = HDIndexPath(0, 8)? @"合同日期" : @"交租日期";
        cell.tf_start.text  = HDIndexPath(0, 8)? model.startDate : model.rentingStartDate;
        cell.tf_end.text    = HDIndexPath(0, 8)? model.endDate : model.rentingEndDate;
        cell.tf_start.tag   = HDIndexPath(0, 8)? 90 : 100;
        cell.tf_end.tag     = HDIndexPath(0, 8)? 91 : 101;
        cell.tf_end.delegate    = self;
        cell.tf_start.delegate  = self;
        return cell;
    }
    static NSString *str = @"HDAddCarDetailCell";
    HDAddCarDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HDAddCarDetailCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.tf.delegate = self;
    cell.tf.tag = indexPath.row;
    [cell.tf addTarget:self action:@selector(textFiledValueChanged:) forControlEvents:UIControlEventAllEditingEvents];
    cell.imv_datePick.hidden = !(HDIndexPath(0, 10) || HDIndexPath(0, 11) || HDIndexPath(0, 16));
    cell.btn_chooseCar.hidden = !HDIndexPath(0, 4);
    [cell.btn_chooseCar addTarget:self action:@selector(chooseCar) forControlEvents:UIControlEventTouchUpInside];
    cell.lb_title.text = @[@"合同编号", @"签约姓名", @"身份证", @"对接人", @"车牌号", @"品牌型号", @"合同类型", @"押金",  @"合同日期", @"收租方式", @"收租日", @"风控日", @"整月租金", @"单日租金", @"活动月返金额", @"活动日返金额", @"提车日期", @"交租日期", @"备注"][indexPath.row];
    cell.tf.placeholder = @[@"请输入合同编号", @"请输入签约姓名", @"请输入身份证", @"请输入对接人", @"请输入车牌号", @"请输入品牌型号", @"", @"请输入押金", @"请选择合同日期", @"", @"请选择收租日", @"请选择风控日", @"请输入整月租金", @"请输入单日租金", @"请输入活动月返金额", @"请输入活动日返金额", @"请选择提车日期", @"请选择交租日期", @"请输入备注"][indexPath.row];
    cell.tf.text = @[HDSTR(model.bargainNo), HDSTR(model.signRealname), HDSTR(model.signCardId), HDSTR(HDGI.loginUser.username), HDSTR(model.vehicleNo), HDSTR(model.vehicleBrand), HDSTR(@""), HDSTR(model.deposit),HDSTR(@""), HDSTR(@""), HDSTR(model.rentDay), HDSTR(model.riskDay), HDSTR(model.monthRate), HDSTR(model.dailyRate), HDSTR(model.returnActivityMoneyMonth), HDSTR(model.returnActivityMoneyDay), HDSTR(model.takeCarDate), HDSTR(@""), HDSTR(model.note)][indexPath.row];
    cell.hidden = NO;
    if (HDIndexPath(0, 7) || HDIndexPath(0, 12) || HDIndexPath(0, 13) || HDIndexPath(0, 14) || HDIndexPath(0, 15)) {
        cell.tf.keyboardType = UIKeyboardTypeNumberPad;
    }else{
        cell.tf.keyboardType = UIKeyboardTypeDefault;
    }
    if (HDIndexPath(0, 11)) {
        cell.hidden = isSelectWind;
//        BOOL is_ = cell.hidden;
    }
    if (HDIndexPath(0, 16)) {
        cell.lb_title.text = @"提车日期";
        cell.tf.text = model.takeCarDate;
        cell.tf.tag =120;
        cell.tf.delegate = self;
    }
    return cell;
}

#pragma mark - event

- (void)httpNewOrder{
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
    task = [helper postPath:@"/member-bargain" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        model.id = JSON(json[@"orderId"]);
        HDStepFourCtr *ctr = [[HDStepFourCtr alloc] initWithBargainModel:model clientModel:clientModel];
        if (self.title.length > 0) {
            ctr.title = @"第三步";
        }
        [self.navigationController pushViewController:ctr animated:YES];
    }];
    
}

- (IBAction)doNext:(id)sender{
    if (model.bargainNo.length == 0 || model.bargainNo.length > 20) {
        [HDHelper say:@"请输入20个字符以内正确合同编号！"];
        return;
    }
    if (model.signRealname.length == 0 || model.signRealname.length > 10) {
        [HDHelper say:@"请输入10个字以内正确签约姓名"];
        return;
    }
    if (model.signCardId.length == 0 || model.signCardId.length > 22) {
        [HDHelper say:@"请输入正确身份证号码"];
        return;
    }
    if (model.vehicleNo.length == 0 || model.vehicleNo.length > 30) {
        [HDHelper say:@"请输入正确车牌号"];
        return;
    }
    if (model.vehicleBrand.length == 0 || model.vehicleBrand.length > 30) {
        [HDHelper say:@"请输入正确品牌型号"];
        return;
    }
    if (model.bargainType.length == 0) {
        [HDHelper say:@"请选择合同类型"];
        return;
    }
    if (model.deposit.length == 0) {
        [HDHelper say:@"请输入押金"];
        return;
    }
    if (model.startDate.length == 0) {
        [HDHelper say:@"请选择合同起始日期"];
        return;
    }
    if (model.endDate.length == 0) {
        [HDHelper say:@"请选择合同截止日期"];
        return;
    }
    if (model.rentalsMethod.length == 0) {
        [HDHelper say:@"请选择收租方式"];
        return;
    }
    if (model.rentDay.length == 0) {
        [HDHelper say:@"请选择收租日"];
        return;
    }
    if (model.riskDay.length == 0 && !isSelectWind) {
        [HDHelper say:@"请选择风控日"];
        return;
    }
    if (model.monthRate.length == 0) {
        [HDHelper say:@"请输入整月租金"];
        return;
    }
    if (model.dailyRate.length == 0) {
        [HDHelper say:@"请输入整日租金"];
        return;
    }
    if (model.returnActivityMoneyMonth.length == 0) {
        [HDHelper say:@"请输入活动月返金额"];
        return;
    }
    if (model.returnActivityMoneyDay.length == 0) {
        [HDHelper say:@"请输入活动日返金额"];
        return;
    }
    if (model.takeCarDate.length == 0) {
        [HDHelper say:@"请选择提车日期"];
        return;
    }
    if (model.rentingStartDate.length == 0) {
        [HDHelper say:@"请选择交租起始日期"];
        return;
    }
    if (model.rentingEndDate.length == 0) {
        [HDHelper say:@"请选择交租截止日期"];
        return;
    }
    
    model.rent = @"0";
    model.firstRent = @"0";
    
    NSDate *start0 = [HDDateHelper dateWithString:model.rentingStartDate formate:@"yyyy-MM-dd"];
    NSDate *end0 = [HDDateHelper dateWithString:model.rentingEndDate formate:@"yyyy-MM-dd"];
    if ([start0 compare:end0] == NSOrderedDescending) {
        [HDHelper say:@"交租起始时间不能大于结束时间"];
        return;
    }

    NSDate *start = [HDDateHelper dateWithString:model.startDate formate:@"yyyy-MM-dd"];
    NSDate *end = [HDDateHelper dateWithString:model.endDate formate:@"yyyy-MM-dd"];
    if ([start compare:end] == NSOrderedDescending) {
        [HDHelper say:@"起始时间不能大于结束时间"];
        return;
    }
    [self httpNewOrder];
}

- (IBAction)doPickerButtonAction:(UIDatePicker *)sender {
    if (sender.tag == 1) {
        NSString *date = [HDDateHelper stringWithDate:picker.date withFormat:@"yyyy-MM-dd"];
        if (picker.tag == 10) {
            model.rentDay = HDFORMAT(@"%d", [pickerView selectedRowInComponent:0] + 1);
        }
        if (picker.tag == 11) {
            model.riskDay = HDFORMAT(@"%d", [pickerView selectedRowInComponent:0] + 1);
        
        }
        if (picker.tag == 90) {
            model.startDate = date;
        }
        if (picker.tag == 91) {
            model.endDate = date;
        }
        if (picker.tag == 100) {
            model.rentingStartDate = date;
        }
        if (picker.tag == 101) {
            model.rentingEndDate = date;
        }
        if (picker.tag == 120) {
            model.takeCarDate = date;
        }
    }
    
    lc_pickerBottom.constant = 300.;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    tbv.contentSize = CGSizeMake(HDDeviceSize.width, contentSizeHeight);
    [tbv reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        //刷新完成
        [tbv scrollToRowAtIndexPath:myIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    });
}

- (void)chooseCar{
    HBGarageCtr *ctr = [[HBGarageCtr alloc] initWithTitle:@"请选择车辆"];
    [self.navigationController pushViewController:ctr animated:YES];
    ctr.chooseCarBlock = ^(HDCarModel *carInfo) {
        [self.navigationController popViewControllerAnimated:YES];
        model.vehicleNo = carInfo.vehicleNumber;
        model.vehicleBrand = carInfo.vehicleModel;
        model.vehicleId = carInfo.id;
        [tbv reloadData];
    };
}

#pragma mark - setter
- (void)setup{
    lc_pickerBottom.constant = 300.;
    [self.view updateConstraints];
    btn_complete.layer.cornerRadius = 5.;
    btn_complete.layer.masksToBounds = YES;
    model = [HDBargainModel new];
    model.vehicleNo     = HDGI.carNumber;
    model.vehicleBrand  = HDGI.carBrand;
    model.vehicleId     = HDGI.signCarId;
    model.signRealname  = clientModel.realname;
    model.signCardId    = clientModel.cardId;
    model.signMemberId  = clientModel.id;
    
    isSelectWind = YES;
    model.rentalsMethod = @"1";
    model.riskDay = @"0";

}

- (void)setTitleView{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width * 0.5, 44)];
    UILabel *lb_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    lb_title.textAlignment = NSTextAlignmentCenter;
    lb_title.font = [UIFont systemFontOfSize:17];
    lb_title.text = @"第三步";
    if (self.title) {
        lb_title.text = self.title;
    }
    [v addSubview:lb_title];
    [lb_title makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(v);
        make.centerY.equalTo(v).offset(-10);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    UILabel *lb_sub = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    lb_sub.textAlignment = NSTextAlignmentCenter;
    lb_sub.font = [UIFont systemFontOfSize:12];
    lb_sub.textColor = RGB(224., 70, 56);
    lb_sub.text = @"填充合同信息";
    [v addSubview:lb_sub];
    [lb_sub makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(v);
        make.centerY.equalTo(v).offset(10);
        make.size.mas_equalTo(CGSizeMake(180, 20));
    }];
    self.navigationItem.titleView = v;
}

- (void)setTableFooter{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 110)];
    [v addSubview:footView];
    v.backgroundColor = [UIColor clearColor];
    [footView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(v);
        make.center.equalTo(v);
    }];
    tbv.tableFooterView = v;
}


@end

@implementation HDBargainModel

@end

