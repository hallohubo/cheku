//
//  HDClientInfoCtr.m
//  Demo
//
//  Created by hufan on 2018/2/4.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDClientInfoCtr.h"
#import "HDPhotoHelper.h"
#import "HDImageBrowser.h"
#import "HDAddCarDetailCell.h"
#import "HDClientSexCell.h"
#import "HDTableView.h"
#import "HDValidDateCell.h"
#import "HDStepTwoCtr.h"
#import "IDCardViewController.h"
#import "HDImageHelper.h"

@interface HDClientInfoCtr (){
    IBOutlet HDTableView *tbv;
    IBOutlet UIView *headView;
    IBOutlet UIView *footView;
    IBOutlet UIButton *btn_next;
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
    IBOutlet UIDatePicker *picker;
    IBOutlet NSLayoutConstraint *lc_pickerBottom;
    NSURLSessionDataTask *task;
    CGSize contentSize;
    UITextField *tf_valid;
    HDHUD *hud;
    BOOL isStep;   //第一步新增客户
    BOOL isAdd;    //新增客户
    HDClientModel *model;
}

@end

@implementation HDClientInfoCtr

- (id)initWithAddClient:(HDClientModel *)m{
    if (self = [super init]) {
        isAdd = YES;
        model = m;
    }
    return self;
}

- (id)initWithStepClient{
    if (self = [super init]) {
        isStep = YES;
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
            model.phone = textField.text;
            break;
        }
        case 1:{
            model.realname = textField.text;
            break;
        }
        case 2:{
            Dlog(@"textfield.text = %@", textField.text);
            break;
        }
        case 3:{
            model.birthday = textField.text;
            break;
        }
        case 4:{
            model.cardId = textField.text;
            break;
        }
        case 5:{
            model.nation = textField.text;
            break;
        }
        case 6:{
            model.address = textField.text;;
            break;
        }
        case 7:{
            model.office = textField.text;
            break;
        }
            
        default:
            break;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 3 || textField.tag >= 80) {//时间选择器
        [self.view endEditing:YES];
        lc_pickerBottom.constant = 0;
        picker.tag = textField.tag;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        if (textField.tag >= 80) {
            tf_valid = textField;
            CGSize size = contentSize;
            size.height += 300;
            tbv.contentSize = size;
            [tbv setContentOffset:CGPointMake(0, size.height - CGRectGetHeight(tbv.frame)) animated:NO];
        }
        return NO;
    }
    lc_pickerBottom.constant = 300;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag >= 6) {
        CGSize size = contentSize;
        size.height += 300;
        tbv.contentSize = size;
        [tbv setContentOffset:CGPointMake(0, size.height - CGRectGetHeight(tbv.frame)) animated:NO];
    }
}

- (IBAction)datepickerValueChanged:(UIDatePicker *)sender{
    if (sender.tag == 3) {
         model.birthday = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
        [tbv reloadData];
    }
    if (sender.tag == 80) {
        model.startDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
        tf_valid.text = model.startDate;
    }
    if (sender.tag == 81) {
        model.endDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
        tf_valid.text = model.endDate;
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
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (HDIndexPath(0, 2)) {
        static NSString *str = @"HDClientSexCell";
        HDClientSexCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [HDClientSexCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.lb_title.text = @"性别";
        if (model.gender.length == 0) {
            cell.sex = @"";
        }else{
            cell.sex = [model.gender isEqualToString:@"男"]? @"1": @"0";
        }
        cell.chooseSex = ^(int s) {
            model.gender = s? @"男": @"女";
        };
        return cell;
    }
    if (HDIndexPath(0, 8)) {
        static NSString *str = @"HDValidDateCell";
        HDValidDateCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [HDValidDateCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.tf_start.text  = model.startDate;
        cell.tf_end.text    = model.endDate;
        cell.tf_start.tag   = 80;
        cell.tf_end.tag     = 81;
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
    cell.imv_datePick.hidden = !HDIndexPath(0, 2);
    cell.lb_title.text = @[@"手机号", @"姓名", @"性别", @"出生日期", @"身份证号码", @"民族", @"住址", @"签发机关", @"有效期"][indexPath.row];
    cell.tf.placeholder = @[@"请输入手机号", @"请输入姓名", @"", @"请选择出生日期", @"请输入身份证号码", @"请输入民族", @"请输入住址", @"请输入签发机关", @""][indexPath.row];
    NSString *text = @[HDSTR(model.phone), HDSTR(model.realname), @"", HDSTR(model.birthday), HDSTR(model.cardId), HDSTR(model.nation), HDSTR(model.address), HDSTR(model.office), @""][indexPath.row];
    cell.tf.text = text;
    return cell;
}

#pragma mark - event
- (void)httpUploadImage:(UIImage *)img isFront:(BOOL)isFront isFromCamera:(BOOL)isCamera{
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
        if (isCamera) {//如果是拍照，已经本地识别，不用传回服务器识别
            if (isFront) {
                model.cardFront = JSON(object[@"url"]);
            }else{
                model.cardBack = JSON(object[@"url"]);
            }
            return;
        }
        if (isFront) {
            [frontView bringSubviewToFront:imv_front];
            imv_front.image         = img;
            btn_changeFront.hidden  = NO;
            imv_arrowFront.hidden   = NO;
            model.cardFront = JSON(object[@"url"]);
            [self httpGetInformationFromImage:model.cardFront isFront:YES];
        }else{
            [backView bringSubviewToFront:imv_back];
            imv_back.image          = img;
            btn_changeBack.hidden   = NO;
            imv_arrowBack.hidden    = NO;
            model.cardBack = JSON(object[@"url"]);

            [self httpGetInformationFromImage:model.cardBack isFront:NO];
        }
    }];
}

- (void)httpGetInformationFromImage:(NSString *)imgUrl isFront:(BOOL)isFront{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"智能识别中,请稍后..." on:self.view];
    helper.parameters = @{@"url": HDSTR(imgUrl), @"side": (isFront? @"face": @"back")};
    task = [helper postPath:@"/ocr/ios-idcard" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            Dlog(@"-----OCR失败！------");
            if (error.code != -999) {
                [HDHelper say:@"智能识别失败，请尝试“拍照识别”或手动输入身份证信息"];
            }
            return ;
        }
        Dlog(@"json = %@", json);
        if (isFront) {
            model.address       = JSON(json[@"address"]);
            NSData *birth       = [HDDateHelper dateWithString:JSON(json[@"birth"]) formate:@"yyyyMMdd"];
            model.birthday      = [HDDateHelper stringWithDate:birth withFormat:@"yyyy-MM-dd"];
            model.realname      = JSON(json[@"name"]);
            model.cardId        = JSON(json[@"num"]);
            model.nation        = JSON(json[@"nationality"]);
            model.gender        = JSON(json[@"sex"]);
        }else{
            NSData *start       = [HDDateHelper dateWithString:JSON(json[@"start_date"]) formate:@"yyyyMMdd"];
            model.startDate     = [HDDateHelper stringWithDate:start withFormat:@"yyyy-MM-dd"];
            NSData *end         = [HDDateHelper dateWithString:JSON(json[@"end_date"]) formate:@"yyyyMMdd"];
            model.endDate       = [HDDateHelper stringWithDate:end withFormat:@"yyyy-MM-dd"];
            model.office        = JSON(json[@"issue"]);
        }
        [tbv reloadData];
    }];
}

- (void)next{
    HDStepTwoCtr *ctr = [[HDStepTwoCtr alloc] initWithClient:model];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (IBAction)doAddIdCard:(UIButton *)sender{
    [[HDHelper instance] showSheetWithTitle:@"请选择" first:@"拍一张" seconed:@"从相册选择" showIn:self.navigationController.view finished:^(UIActionSheet *sheet, int index) {
        if (index == 2) {
            return ;
        }
        if (index == 0) {
            IDCardViewController *ctr = [IDCardViewController new];
            [self.navigationController presentViewController:ctr animated:YES completion:nil];
            [ctr setScanFinishdBlock:^(IdInfo *info, UIImage *image) {
                [ctr dismissViewControllerAnimated:YES completion:nil];
                UIImage *img = [HDImageHelper image:image rotation:UIImageOrientationDown];
                [self httpUploadImage:img isFront:!sender.tag isFromCamera:YES];
                if (sender.tag == 0) {//正面
                    [frontView bringSubviewToFront:imv_front];
                    imv_front.image         = img;
                    btn_changeFront.hidden  = NO;
                    imv_arrowFront.hidden   = NO;
                    model.realname  = info.name;
                    model.gender    = info.gender;
                    model.address   = info.address;
                    model.nation    = info.nation;
                    model.cardId    = info.code;
                    if (model.cardId.length > 12) {
                        NSString *birth = [model.cardId substringWithRange:NSMakeRange(6, 8)];
                        NSDate *date = [HDDateHelper dateWithString:birth formate:@"yyyyMMdd"];
                        model.birthday = [HDDateHelper stringWithDate:date withFormat:@"yyyy-MM-dd"];
                    }
                    [tbv reloadData];
                    return ;
                }
                //反面
                [backView bringSubviewToFront:imv_back];
                imv_back.image          = img;
                imv_arrowBack.hidden    = NO;
                btn_changeBack.hidden   = NO;
                model.office = info.issue;
                NSArray *ar = [info.valid componentsSeparatedByString:@"-"];
                if (ar.count == 2) {
                    NSString *start = ar[0];
                    NSString *end   = ar[1];
                    NSDate *date = [HDDateHelper dateWithString:start formate:@"yyyyMMdd"];
                    model.startDate = [HDDateHelper stringWithDate:date withFormat:@"yyyy-MM-dd"];
                    date = [HDDateHelper dateWithString:end formate:@"yyyyMMdd"];
                    model.endDate = [HDDateHelper stringWithDate:date withFormat:@"yyyy-MM-dd"];
                }
                [tbv reloadData];
            }];
            
        }
        if (index == 1) {
            [[HDPhotoHelper instance] readCardId:^(UIImage *image) {
                if (image) {
                    [self httpUploadImage:image isFront:!sender.tag isFromCamera:NO];
                }
            }];
        }
    }];
}

- (IBAction)doNext:(id)sender{
    if (model.cardFront.length == 0) {
        [HDHelper say:@"请选择身份证正面"];
        return;
    }
    if (model.cardBack.length == 0) {
        [HDHelper say:@"请选择身份证背面"];
        return;
    }
    if (model.realname.length == 0) {
        [HDHelper say:@"请输入姓名"];
        return;
    }
    if (model.realname.length > 20) {
        [HDHelper say:@"请输入20字以内姓名"];
        return;
    }
    if (model.gender.length == 0) {
        [HDHelper say:@"请选择性别"];
        return;
    }
    if (model.birthday.length == 0) {
        [HDHelper say:@"请输入出生日期"];
        return;
    }
    if (model.cardId.length == 0) {
        [HDHelper say:@"请输入身份证号码"];
        return;
    }
    if (model.cardId.length > 20) {
        [HDHelper say:@"请输入正确身份证号码"];
        return;
    }
    if (model.nation.length == 0) {
        [HDHelper say:@"请输入民族"];
        return;
    }
    if (model.nation.length > 20) {
        [HDHelper say:@"请输入正确民族"];
        return;
    }
    if (model.address.length == 0) {
        [HDHelper say:@"请输入住址"];
        return;
    }
    if (model.address.length > 30) {
        [HDHelper say:@"请输入正确住址"];
        return;
    }
    if (model.office.length == 0) {
        [HDHelper say:@"请输入签发机关"];
        return;
    }
    if (model.office.length > 20) {
        [HDHelper say:@"请输入正确签发机关"];
        return;
    }
    if (model.startDate.length == 0) {
        [HDHelper say:@"请输入有效期起始日期"];
        return;
    }
    if (model.endDate.length == 0) {
        [HDHelper say:@"请输入有效期结束日期"];
        return;
    }
    if (![HDHelper isValidateMobile:model.phone]) {
        [HDHelper say:@"请输入正确手机号码"];
        return;
    }
    NSDate *startDate = [HDDateHelper dateWithString:model.startDate formate:@"yyyy-MM-dd"];
    NSDate *endDate = [HDDateHelper dateWithString:model.endDate formate:@"yyyy-MM-dd"];
    if ([startDate compare:endDate] == NSOrderedDescending) {
        [HDHelper say:@"起始时间不能大于结束时间"];
        return;
    }
    [self next];
}

- (IBAction)doPickerButtonAction:(UIButton *)sender{
    if (sender.tag == 1) {
        NSString *date = [HDDateHelper stringWithDate:picker.date withFormat:@"yyyy-MM-dd"];
        if (picker.tag == 3) {
            model.birthday = date;
        }
        if (picker.tag == 80) {
            model.startDate = date;
        }
        if (picker.tag == 81) {
            model.endDate = date;
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
    if (!model) {
        model = [HDClientModel new];
    }
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
    NSString *front  = model.cardFront;
    front = HDFORMAT(@"%@app%@", IP, front);
    [imv_front setImageWithURL:[NSURL URLWithString:front]];
    [frontView bringSubviewToFront:imv_front];
    btn_changeFront.hidden  = NO;
    imv_arrowFront.hidden   = NO;
    
    NSString *back = model.cardBack;
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
    if (_putModel || isAdd) {//客户详情页，非新增用户
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

