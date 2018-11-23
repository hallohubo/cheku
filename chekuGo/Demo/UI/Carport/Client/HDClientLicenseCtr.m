//
//  HDClientLicenseCtr.m
//  Demo
//
//  Created by hufan on 2018/2/4.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDClientLicenseCtr.h"
#import "HDPhotoHelper.h"
#import "HDImageBrowser.h"
#import "HDAddCarDetailCell.h"
#import "HDClientSexCell.h"
#import "HDTableView.h"
#import "HDValidDateCell.h"

@interface HDClientLicenseCtr (){
    IBOutlet UITableView *tbv;
    NSURLSessionDataTask *task;
    HDHUD *hud;
    IBOutlet UIButton *btn_changeFront;
    IBOutlet UIButton *btn_changeBack;
    IBOutlet UIButton *btn_addFront;
    IBOutlet UIButton *btn_addBack;
    IBOutlet UIImageView *imv_front;
    IBOutlet UIImageView *imv_back;
    IBOutlet UIImageView *imv_arrowFront;
    IBOutlet UIImageView *imv_arrowBack;
    IBOutlet UIView *frontView;
    IBOutlet UIView *backView;
    IBOutlet UIView *headView;
    IBOutlet UIView *footView;
    IBOutlet UIButton *btn_next;
    IBOutlet UIDatePicker *picker;
    IBOutlet NSLayoutConstraint *lc_pickerBottom;

    CGSize contentSize;
    UITextField *curTextFiled;
    HDClientModel *model;
    BOOL isAdd;
    BOOL isStep;
    BOOL hasPostedTheClient;//如果是已经生成过的，不要再生成，比如生成后跳到下一步，用户又点击返回，再下一步，就不能在post生成新client了。
}

@end

@implementation HDClientLicenseCtr
- (id)initWithAddClient:(HDClientModel *)m{
    if (self = [super init]) {
        isAdd = YES;
        model = m;
    }
    return self;
}

- (id)initWithStepClient:(HDClientModel *)m{
    if (self = [super init]) {
        isStep = YES;
        model = m;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTableheader];
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

- (void)viewDidAppear:(BOOL)animated{
    contentSize = tbv.contentSize;
}

- (void)viewDidDisappear:(BOOL)animated{
    tbv.contentSize = contentSize;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    lc_pickerBottom.constant = 300;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    tbv.contentSize = contentSize;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    lc_pickerBottom.constant = 300;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    tbv.contentSize = contentSize;
    return YES;
}

- (void)textFiledValueChanged:(UITextField *)textField{
    switch (textField.tag) {
        case 0:{
            model.driveRealname = textField.text;
            break;
        }
        case 1:{
            Dlog(@"textfield.text = %@", textField.text);
            break;
        }
        case 2:{
            model.driveAddress = textField.text;
            break;
        }
        case 3:{
            model.driveNumber = textField.text;
            break;
        }
        case 4:{
            model.driveNation = textField.text;
            break;
        }
        case 5:{
            //出生日期
            break;
        }
        case 6:{
            model.driveVehicleType = textField.text;
            break;
        }
        case 7:{
            //有效期
            break;
        }
        case 8:{
            model.driveDataRecord = textField.text;
            break;
        }
        case 9:{
            //初次领证日期
            break;
        }
        case 10:{
            model.driveDataId = textField.text;
            break;
        }
            
        default:
            break;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 5 || textField.tag == 9 || textField.tag >= 70) {//时间选择器
        //收起键盘，弹出picker
        [self.view endEditing:YES];
        lc_pickerBottom.constant = 0;
        picker.tag = textField.tag;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        if (textField.tag == 9) {//靠底部了，contentsize拉长
            curTextFiled = textField;
            CGSize size = contentSize;
            size.height += 300;
            tbv.contentSize = size;
            [tbv setContentOffset:CGPointMake(0, size.height - CGRectGetHeight(tbv.frame)) animated:NO];
        }
        return NO;
    }
    //其他情况收起picker
    lc_pickerBottom.constant = 300;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag >= 8) {//靠底部了，contentSize拉长
        CGSize size = contentSize;
        size.height += 300;
        tbv.contentSize = size;
        [tbv setContentOffset:CGPointMake(0, size.height - CGRectGetHeight(tbv.frame)) animated:NO];
    }
}

- (IBAction)datepickerValueChanged:(UIDatePicker *)sender{
    if (sender.tag == 5) {
        model.driveBirthday = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
        [tbv reloadData];
    }
    if (sender.tag == 9) {
        model.driveFirstDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
        curTextFiled.text = model.driveFirstDate;
    }
    if (sender.tag == 70) {
        model.driveStartDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
        [tbv reloadData];
    }
    if (sender.tag == 71) {
        model.driveExpiryDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
        [tbv reloadData];
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
    return 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (HDIndexPath(0, 1)) {
        static NSString *str = @"HDClientSexCell";
        HDClientSexCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [HDClientSexCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.lb_title.text = @"性别";
        if (model.driveGender.length == 0) {
            cell.sex = @"";
        }else{
            cell.sex = [model.driveGender isEqualToString:@"男"]? @"1": @"0";
        }
        cell.chooseSex = ^(int s) {
            model.driveGender = s == 1? @"男": @"女";
        };
        return cell;
    }
    if (HDIndexPath(0, 7)) {
        static NSString *str = @"HDValidDateCell";
        HDValidDateCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [HDValidDateCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.lb_title.text = @"有效期";
        cell.tf_start.text  = model.driveStartDate;
        cell.tf_end.text    = model.driveExpiryDate;
        cell.tf_start.tag   = 70;
        cell.tf_end.tag     = 71;
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
    cell.imv_datePick.hidden = !(HDIndexPath(0, 5) || HDIndexPath(0, 7) || HDIndexPath(0, 9));
    cell.lb_title.text = @[@"姓名", @"性别", @"住址", @"证号", @"国籍", @"出生日期", @"准假车型", @"有效期", @"记录", @"初次领证", @"档案编号"][indexPath.row];
    cell.tf.placeholder = @[@"请输入姓名", @"性别", @"请输入住址", @"请输入驾驶证证号", @"请输入国籍", @"请选择出生日期", @"请输入准假车型", @"有效期", @"请输入记录", @"请选择初次领证日期", @"请输入档案编号"][indexPath.row];
    cell.tf.text = @[HDSTR(model.driveRealname), @"", HDSTR(model.driveAddress), HDSTR(model.driveNumber), HDSTR(model.driveNation), HDSTR(model.driveBirthday), HDSTR(model.driveVehicleType), @"", HDSTR(model.driveDataRecord), HDSTR(model.driveFirstDate), HDSTR(model.driveDataId)][indexPath.row];
    return cell;
}

#pragma mark - event
- (void)httpUploadImage:(UIImage *)img isFront:(BOOL)isFront{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    helper.parameters = @{@"dir": @"insureImage"};
    task = [helper postFilePath:@"upload/file" data:img finished:^(HDError *error, id object) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        if (isFront) {
            [frontView bringSubviewToFront:imv_front];
            imv_front.image         = img;
            btn_changeFront.hidden  = NO;
            imv_arrowFront.hidden   = NO;
            model.driveFront = JSON(object[@"url"]);
            [self httpGetInformationFromImage:model.driveFront isFront:YES];
        }else{
            [backView bringSubviewToFront:imv_back];
            imv_back.image          = img;
            btn_changeBack.hidden   = NO;
            imv_arrowBack.hidden    = NO;
            model.driveBack = JSON(object[@"url"]);
            [self httpGetInformationFromImage:model.driveBack isFront:NO];
        }
    }];
}

- (void)httpGetInformationFromImage:(NSString *)imgUrl isFront:(BOOL)isFront{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"智能识别中,请稍后..." on:self.view];
    helper.parameters = @{@"url": HDSTR(imgUrl), @"side": (isFront? @"face": @"back")};
    task = [helper postPath:@"/ocr/ios-driver" object:nil finished:^(HDError *error, id object, BOOL isLast, id data) {
        [hud hiden];
        if (error) {
            Dlog(@"-----OCR失败！------");
            if (error.code != -999) {
                [HDHelper say:HDFORMAT(@"智能识别失败(%@)，请重新尝试或手动输入驾驶证信息。", error.desc)];
            }
            return ;
        }
        Dlog(@"data = %@", data);
        if (isFront) {
            model.driveRealname     = JSON(data[@"name"]);
            model.driveAddress      = JSON(data[@"addr"]);
            model.driveNumber       = JSON(data[@"num"]);
            model.driveGender       = JSON(data[@"sex"]);
            model.driveVehicleType  = JSON(data[@"vehicle_type"]);
            NSDate *start = [HDDateHelper dateWithString:JSON(data[@"start_date"]) formate:@"yyyyMMdd"];
            model.driveFirstDate    = [HDDateHelper stringWithDate:start withFormat:@"yyyy-MM-dd"];
            model.driveStartDate    = model.driveFirstDate;
            NSDate *end             = [HDDateHelper dateWithString:JSON(data[@"end_date"]) formate:@"yyyyMMdd"];
            model.driveExpiryDate   = [HDDateHelper stringWithDate:end withFormat:@"yyyy-MM-dd"];
            
        }else{
            model.driveDataId = JSON(data[@"archive_no"]);
        }
        [tbv reloadData];
    }];
}

- (void)httpPost{
    if (hasPostedTheClient && self.saveSuccessAndNextBlock) {
        self.saveSuccessAndNextBlock(model);
        return;
    }
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
    task = [helper postPath:@"/member" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        
        hasPostedTheClient = YES;
        NSString *clientNo = JSON(json[@"id"]);
        model.id = clientNo;
        if (self.saveSuccessAndNextBlock) {
            self.saveSuccessAndNextBlock(model);
            return;
        }
        
    }];
}

- (IBAction)doAddIdCard:(UIButton *)sender{
    [[HDPhotoHelper instance] read:^(UIImage *image) {
        if (image) {
            [self httpUploadImage:image isFront:sender.tag == 0];
        }
    }];
}

- (IBAction)doNext:(id)sender{
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
    NSDate *startDate = [HDDateHelper dateWithString:model.driveStartDate formate:@"yyyy-MM-dd"];
    NSDate *endDate = [HDDateHelper dateWithString:model.driveExpiryDate formate:@"yyyy-MM-dd"];
    if ([startDate compare:endDate] == NSOrderedDescending) {
        [HDHelper say:@"起始时间不能大于结束时间"];
        return;
    }
    [self httpPost];
}

- (IBAction)doPickerButtonAction:(UIButton *)sender{
    if (sender.tag == 1) {
        NSString *date = [HDDateHelper stringWithDate:picker.date withFormat:@"yyyy-MM-dd"];
        if (picker.tag == 5) {
            model.driveBirthday = date;
        }
        if (picker.tag == 9) {
            model.driveFirstDate = date;
        }
        if (picker.tag == 70) {
            model.driveStartDate = date;
        }
        if (picker.tag = 71) {
            model.driveExpiryDate = date;
        }
        [tbv reloadData];
    }
    lc_pickerBottom.constant = 300.;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    tbv.contentSize = contentSize;
}

- (void)showImage:(UITapGestureRecognizer *)tap{
    UIImageView *imv = tap.view;
    [HDImageBrowser show:imv];
}

#pragma mark - setter
- (void)setup{
    frontView.layer.cornerRadius    = 5.;
    frontView.layer.masksToBounds   = YES;
    frontView.layer.borderColor     = HDCOLOR_GRAY.CGColor;
    frontView.layer.borderWidth     = 1.;
    
    backView.layer.cornerRadius     = 5.;
    backView.layer.masksToBounds    = YES;
    backView.layer.borderColor      = HDCOLOR_GRAY.CGColor;
    backView.layer.borderWidth      = 1.;
    
    btn_addBack.layer.cornerRadius  = 40.;
    btn_addBack.layer.masksToBounds = YES;
    btn_addBack.layer.borderColor   = HDCOLOR_GRAY.CGColor;
    btn_addBack.layer.borderWidth   = 1.;
    
    btn_addFront.layer.cornerRadius = 40.;
    btn_addFront.layer.masksToBounds= YES;
    btn_addFront.layer.borderColor  = HDCOLOR_GRAY.CGColor;
    btn_addFront.layer.borderWidth  = 1.;
    
    imv_back.layer.cornerRadius     = 5.;
    imv_back.layer.masksToBounds    = YES;
    
    imv_front.layer.cornerRadius    = 5.;
    imv_front.layer.masksToBounds   = YES;
    
    btn_next.layer.cornerRadius    = 5.;
    btn_next.layer.masksToBounds   = YES;
    
    btn_changeBack.hidden   = YES;
    btn_changeFront.hidden  = YES;
    imv_arrowBack.hidden         = YES;
    imv_arrowFront.hidden        = YES;
    
    lc_pickerBottom.constant = 300.;
    [self.view updateConstraints];
    
    hasPostedTheClient = NO;
    
    imv_front.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)];
    [imv_front addGestureRecognizer:tap];
    
    imv_back.userInteractionEnabled = YES;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)];
    [imv_back addGestureRecognizer:tap];
}

- (void)setPutModel:(HDClientModel *)putModel{
    _putModel = putModel;
    model = putModel;
    NSString *front  = model.driveFront;
    front = HDFORMAT(@"%@app%@", IP, front);
    [imv_front setImageWithURL:[NSURL URLWithString:front]];
    [frontView bringSubviewToFront:imv_front];
    btn_changeFront.hidden  = NO;
    imv_arrowFront.hidden   = NO;
    
    NSString *back = model.driveBack;
    back = HDFORMAT(@"%@app%@", IP, back);
    [imv_back setImageWithURL:[NSURL URLWithString:back]];
    tbv.tableFooterView = [UIView new];
    [backView bringSubviewToFront:imv_back];
    btn_changeBack.hidden  = NO;
    imv_arrowBack.hidden   = NO;
    [tbv reloadData];
}

- (void)setTableheader{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 550)];
    [v addSubview:headView];
    v.backgroundColor = [UIColor clearColor];
    [headView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(v);
        make.center.equalTo(v);
    }];
    tbv.tableHeaderView = v;
}

- (void)setTableFooter{
    if (_putModel || isAdd) {
        return;
    }
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
