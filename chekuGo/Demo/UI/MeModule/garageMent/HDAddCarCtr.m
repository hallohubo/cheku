//
//  HDAddCarCtr.m
//  Demo
//
//  Created by hufan on 2018/2/19.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDAddCarCtr.h"
#import "HDAddCarDetailCell.h"
#import "HDPhotoHelper.h"
#import "HDImageBrowser.h"
#import "HDTableView.h"

#define HEADER_HEIGHT [self getArriginalHeaderHeight]
#define imgWidth 100.

#define AR_KEYS @[@"vehicleBrand", @"vehicleModel", @"address", @"vehicleVin", @"engineNumber", @"regDate", @"vehicleWeight", @"ratedPayload", @"tractionMass", @"vehicleNumber", @"own", @"basicProperties", @"dateIssued", @"archivesNumber", @"personsInCab", @"curbWeight", @"overallDimensions", @"maintainHint"]

#define AR_TITLE @[@"品牌型号", @"车辆类型", @"住址", @"车辆识别代码", @"发动机号码", @"注册日期",@"总质量", @"核定载质量", @"准牵引总质量", @"号牌号码", @"所有人", @"使用性质", @"发证日期", @"档案编号", @"核定载人数", @"整备质量", @"外廓尺寸", @"保养公里提醒"]

@interface HDAddCarCtr (){
    IBOutlet HDTableView *tbv;
    IBOutlet UIView *headView;
    IBOutlet UIView *headOtherView;
    IBOutlet UIView *footerView;
    IBOutlet UIButton *btn_addCover;
    IBOutlet UIButton *btn_addBanner;
    IBOutlet UIDatePicker *picker;
    IBOutlet NSLayoutConstraint *lc_pickerBottom;
    IBOutlet NSLayoutConstraint *lc_addBannerLeading;
    IBOutlet NSLayoutConstraint *lc_addBannerTop;
    IBOutlet NSLayoutConstraint *lc_licenseHeight;
    
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
    
//    NSMutableArray *mar_cover;
    NSMutableArray *mar_license;
//    NSMutableArray *mar_banner;
    NSMutableArray *mar_coverUrl;
    NSMutableArray *mar_bannerUrl;
    NSURLSessionDataTask *task;
    HDHUD *hud;
    CGFloat contentSizeHeight;
    HDCarModel *model;
    NSString *carNo;
}

@end

@implementation HDAddCarCtr

- (id)initWithCarId:(NSString *)car{
    if (self = [super init]) {
        carNo = car;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTableHeader:HEADER_HEIGHT];
    [self setTableFooter];
    [self httpGetVehicle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated{
    contentSizeHeight = tbv.contentSize.height;
}
- (void)viewWillDisappear:(BOOL)animated {
    task = nil;
    [hud hiden];
    hud = nil;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    lc_pickerBottom.constant = -300;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    tbv.contentSize = CGSizeMake(HDDeviceSize.width, contentSizeHeight);
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    lc_pickerBottom.constant = -300;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    tbv.contentSize = CGSizeMake(HDDeviceSize.width, contentSizeHeight);
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag == 5 || textField.tag == 12) {//选择时间日期，日期选择器显示
        [self.view endEditing:YES];
        lc_pickerBottom.constant = 0;
        picker.tag = textField.tag;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        return NO;
    }
    //时间选择器收起来
    lc_pickerBottom.constant = -300;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField.tag >= 15) {//靠底部了，contentSize拉长
        CGSize size = CGSizeMake(HDDeviceSize.width, contentSizeHeight);;
        size.height += 350;
        tbv.contentSize = size;
        [tbv setContentOffset:CGPointMake(0, size.height - CGRectGetHeight(tbv.frame)) animated:NO];
    }
}

- (IBAction)datepickerValueChanged:(UIDatePicker *)sender{
    if (sender.tag == 5) {
        model.regDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
    }
    if (sender.tag == 12) {
        model.dateIssued = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
    }
    [tbv reloadData];
}

- (void)textFiledValueChanged:(UITextField *)textField{
    NSArray *ar = AR_KEYS;
    int tag = textField.tag;
    if (tag < ar.count) {
        [model setValue:textField.text forKey:ar[textField.tag]];
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
    return 18;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"HDAddCarDetailCell";
    HDAddCarDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HDAddCarDetailCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.imv_datePick.hidden = !(HDIndexPath(0, 12) || HDIndexPath(0, 5));
    NSString *title = AR_TITLE[indexPath.row];
    cell.lb_title.text = title;
    NSString *placeHolder = HDFORMAT(@"请输入%@", title);
    cell.tf.placeholder = placeHolder;
    NSString *key = [AR_KEYS objectAtIndex:indexPath.row];
    cell.tf.text = [model valueForKey:key];
    cell.tf.tag = indexPath.row;
    cell.tf.delegate = self;
    [cell.tf addTarget:self action:@selector(textFiledValueChanged:) forControlEvents:UIControlEventAllEditingEvents];
    cell.tf.keyboardType = UIKeyboardTypeDefault;
    if (indexPath.row == 14 || indexPath.row == 17) {
        cell.tf.keyboardType = UIKeyboardTypeNumberPad;
    }
    return cell;
}

#pragma mark - event
- (void)httpGetVehicle{
    if (carNo.length == 0) {//新增的情况，跳出
        return;
    }
    HDHttpHelper *helper = [HDHttpHelper instance];
    NSString *key = nil;
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:HDFORMAT(@"vehicle/%@", carNo) object:[HDCarModel new] finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        model = object;
        NSArray *ar_cover = @[HDSTR(model.cover)];
        mar_coverUrl = [[NSMutableArray alloc] initWithArray:ar_cover];
        [self setCoverImages:ar_cover];
        NSArray *ar_license = @[HDSTR(model.vehicleTravelLicenseFront), HDSTR(model.vehicleTravelLicenseBack)];
        NSArray *ar_banner =[model.banner componentsSeparatedByString:@","];
        mar_bannerUrl = [[NSMutableArray alloc] initWithArray:ar_banner];
        [self setBannerImags:ar_banner];
        if (model.vehicleTravelLicenseFront.length > 0) {
            [imv_front setImageWithURL:[NSURL URLWithString:HDFORMAT(@"%@app%@", IP, model.vehicleTravelLicenseFront)]];
            [frontView bringSubviewToFront:imv_front];
            btn_changeFront.hidden  = NO;
            imv_arrowFront.hidden   = NO;
        }
        if (model.vehicleTravelLicenseBack.length > 0) {
            [imv_back setImageWithURL:[NSURL URLWithString:HDFORMAT(@"%@app%@", IP, model.vehicleTravelLicenseBack)]];
            [backView bringSubviewToFront:imv_back];
            btn_changeBack.hidden  = NO;
            imv_arrowBack.hidden   = NO;
        }
        [tbv reloadData];
    }];
}
- (void)httpPut{//更新
    if (carNo.length == 0) {//新增的情况，跳出
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
    NSString *cover = mar_coverUrl[0];
    [mdc setValue:HDSTR(cover) forKey:@"cover"];
    NSString *banner = mar_bannerUrl[0];
    for (int i = 1; i < mar_bannerUrl.count; i++) {
        banner = HDFORMAT(@"%@,%@", banner, mar_bannerUrl[i]);
    }
    [mdc setValue:HDSTR(banner) forKey:@"banner"];
    helper.parameters = mdc;
    task = [helper putPath:HDFORMAT(@"vehicle/%@", carNo) object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        if (self.saveSuccessBlock) {
            self.saveSuccessBlock();
        }
    }];
}

- (void)httpPost{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    NSArray *ar = [HDHttpHelper allProperties:model];
    NSMutableDictionary *mdc = [NSMutableDictionary new];
    for (int i = 0; i < ar.count; i++) {
        NSString *key = ar[i];
        NSString *value = [model valueForKey:key];
        [mdc setValue:HDSTR(value) forKey:key];
    }
    NSString *cover = mar_coverUrl[0];
    [mdc setValue:HDSTR(cover) forKey:@"cover"];
    NSString *banner = mar_bannerUrl[0];
    for (int i = 1; i < mar_bannerUrl.count; i++) {
        banner = HDFORMAT(@"%@,%@", banner, mar_bannerUrl[i]);
    }
    [mdc setValue:HDSTR(banner) forKey:@"banner"];
    helper.parameters = mdc;
    task = [helper postPath:@"/vehicle" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        if (self.saveSuccessBlock) {
            self.saveSuccessBlock();
        }
    }];
}

- (void)httpUploadImage:(UIImage *)img isFront:(BOOL)isFront{//上传行驶证正反面
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
            model.vehicleTravelLicenseFront = JSON(object[@"url"]);
            [self httpGetInformationFromImage:model.vehicleTravelLicenseFront isFront:YES];
        }else{
            [backView bringSubviewToFront:imv_back];
            imv_back.image          = img;
            btn_changeBack.hidden   = NO;
            imv_arrowBack.hidden    = NO;
            model.vehicleTravelLicenseBack = JSON(object[@"url"]);
            [self httpGetInformationFromImage:model.vehicleTravelLicenseBack isFront:NO];
        }
    }];
}

- (void)httpGetInformationFromImage:(NSString *)imgUrl isFront:(BOOL)isFront{//智能识别图片
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"智能识别中,请稍后..." on:self.view];
    helper.parameters = @{@"url": HDSTR(imgUrl), @"side": (isFront? @"face": @"back")};
    task = [helper postPath:@"/ocr/ios-vehicle" object:nil finished:^(HDError *error, id object, BOOL isLast, id data) {
        [hud hiden];
          if (error || !data || [data isEqual:[NSNull null]]) {
            Dlog(@"-----OCR失败！------");
            if (error.code != -999) {
                [HDHelper say:HDFORMAT(@"智能识别失败(%@)，请重新尝试或手动输入驾驶证信息。", error.desc)];
            }
            return ;
        }
        Dlog(@"data = %@", data);
        if (isFront) {
            model.engineNumber      = JSON(data[@"engine_num"]);
            model.vehicleBrand      = JSON(data[@"model"]);
            model.vehicleModel      = JSON(data[@"vehicle_type"]);
            model.address           = JSON(data[@"addr"]);
            model.vehicleVin        = JSON(data[@"vin"]);
            NSDate *registerDate    = [HDDateHelper dateWithString:JSON(data[@"register_date"]) formate:@"yyyyMMdd"];
            model.regDate           = [HDDateHelper stringWithDate:registerDate withFormat:@"yyyy-MM-dd"];
            NSDate *dateIssued      = [HDDateHelper dateWithString:JSON(data[@"issue_date"]) formate:@"yyyyMMdd"];
            model.dateIssued        = [HDDateHelper stringWithDate:dateIssued withFormat:@"yyyy-MM-dd"];
            model.own               = JSON(data[@"owner"]);
            model.vehicleNumber     = JSON(data[@"plate_num"]);
            model.basicProperties   = JSON(data[@"use_character"]);
        }else{
            model.personsInCab      = JSON(data[@"appproved_passenger_capacity"]);
            model.ratedPayload      = JSON(data[@"approved_load"]);
            model.archivesNumber    = JSON(data[@"file_no"]);
            model.overallDimensions = JSON(data[@"overall_dimension"]);
            model.vehicleNumber     = JSON(data[@"plate_num"]);
            model.vehicleWeight     = JSON(data[@"gross_mass"]);
            model.tractionMass      = JSON(data[@"traction_mass"]);
            model.curbWeight        = JSON(data[@"unladen_mass"]);
        }
        [tbv reloadData];
    }];
}
- (void)httpUploadImage:(UIImage *)img buttonIndex:(int)tag{//上传封面和banner图片
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
        if (tag == 0) {//封面
            NSString *path = JSON(object[@"url"]);
            [mar_coverUrl addObject:path];
//            [mar_cover addObject:img];
            btn_addCover.hidden = YES;
            [self setCoverImages:mar_coverUrl];
            return;
        }
        //banner图片
        NSString *path = JSON(object[@"url"]);
        [mar_bannerUrl addObject:path];
        [self setBannerImags:mar_bannerUrl];
    }];
}

- (IBAction)doAddLisenceCard:(UIButton *)sender{
    [[HDPhotoHelper instance] read:^(UIImage *image) {
        if (image) {
            [self httpUploadImage:image isFront:sender.tag == 0];
        }
    }];
}

- (IBAction)doAddImage:(UIButton *)sender{//封面图片和banner图片
    [[HDPhotoHelper instance] read:^(UIImage *image) {
        if (!image) {
            [HDHelper say:@"读取图片失败"];
            return ;
        }
        [self httpUploadImage:image buttonIndex:sender.tag];
    }];
}

- (IBAction)doSave:(UIButton *)sender{
    NSArray *ar = AR_KEYS;
    if (sender.tag < ar.count) {
        NSString *key = AR_KEYS[sender.tag];
        NSString *prompt = AR_TITLE[sender.tag];
        prompt = HDFORMAT(@"请输入%@", prompt);
        NSString *value = [model valueForKey:key];
        if (value.length == 0 || value.length > 30) {
            [HDHelper say:prompt];
            return;
        }
    }
    if (mar_bannerUrl.count == 0 || mar_bannerUrl.count > 9) {
        [HDHelper say:@"请选择车辆图片"];
        return;
    }
    if (model.vehicleTravelLicenseBack.length == 0 || model.vehicleTravelLicenseFront.length == 0) {
        [HDHelper say:@"请选择行驶证正反面照片"];
        return;
    }
    if (mar_coverUrl.count == 0) {
        [HDHelper say:@"请选择封面图片"];
        return;
    }
    if (carNo.length > 0) {
        [self httpPut];
        return;
    }
    [self httpPost];
}

- (IBAction)doPickerButtonAction:(UIButton *)sender{
    if (sender.tag == 1) {
        NSString *date = [HDDateHelper stringWithDate:picker.date withFormat:@"yyyy-MM-dd"];
        if (picker.tag == 5) {
            model.regDate = date;
        }
        if (picker.tag == 12) {
            model.dateIssued = date;
        }
        [tbv reloadData];
    }
    lc_pickerBottom.constant = -300.;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    tbv.contentSize = CGSizeMake(HDDeviceSize.width, contentSizeHeight);
}

- (void)showImage:(UIGestureRecognizer *)tap{
    int tag = tap.view.tag;
    [[HDHelper instance] showSheetWithTitle:@"请选择" first:@"浏览" seconed:@"删除" showIn:self.view finished:^(UIActionSheet *sheet, int index) {
        if (index == 2) {
            return ;
        }
        if (index == 0) {
            UIImageView *imv = tap.view;
            [HDImageBrowser show:imv];
        }
        if (index == 1) {
            if (tag < 10) {//cover
                if (tag < mar_coverUrl.count) {
                    [mar_coverUrl removeObjectAtIndex:tag];
                }
                for (UIView *v in btn_addCover.superview.subviews) {
                    if ([v isKindOfClass:[UIImageView class]] && v.tag < 10) {
                        [v removeFromSuperview];
                    }
                }
                btn_addCover.hidden = NO;
            }else{
                if (tag - 100 < mar_bannerUrl.count) {
                    [mar_bannerUrl removeObjectAtIndex:tag - 100];
                }
                [self setBannerImags:mar_bannerUrl];
            }
            
        }
    }];
}

#pragma mark - setter
- (void)setup{
    self.title = @"新增车辆";
    if (carNo.length > 0) {
        self.title = @"编辑车辆";
    }
    if (!model) {
        model = [HDCarModel new];
    }
    lc_pickerBottom.constant = -300;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    btn_addCover.layer.cornerRadius   = 5.;
    btn_addCover.layer.masksToBounds  = YES;
    btn_addCover.layer.borderColor    = HDCOLOR_GRAY.CGColor;
    btn_addCover.layer.borderWidth    = 1.;

    btn_addBanner.layer.cornerRadius   = 5.;
    btn_addBanner.layer.masksToBounds  = YES;
    btn_addBanner.layer.borderColor    = HDCOLOR_GRAY.CGColor;
    btn_addBanner.layer.borderWidth    = 1.;
    
    mar_license     = [NSMutableArray new];
    mar_coverUrl    = [NSMutableArray new];
    mar_bannerUrl   = [NSMutableArray new];
    
    //set lisence model UI
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
    btn_changeBack.hidden   = YES;
    btn_changeFront.hidden  = YES;
    imv_arrowBack.hidden         = YES;
    imv_arrowFront.hidden        = YES;
    
    imv_front.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)];
    [imv_front addGestureRecognizer:tap];
    
    imv_back.userInteractionEnabled = YES;
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)];
    [imv_back addGestureRecognizer:tap];
}

- (void)setTableHeader:(CGFloat)height{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, height)];
    [v addSubview:headView];
    [headView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(v);
        make.center.equalTo(v);
    }];
    tbv.tableHeaderView = v;
}

- (void)setTableFooter{
    if ([HDGI.loginUser.role isEqualToString:@"Main"]) {
        return;
    }
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 80)];
    [v addSubview:footerView];
    [footerView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(v);
        make.center.equalTo(v);
    }];
    tbv.tableFooterView = v;
}

- (void)setCoverImages:(NSArray *)images{
    if (images.count == 0) {
        Dlog(@"Error:Cover image is nil");
        return;
    }
    id obj = images[0];
    UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    if ([obj isKindOfClass:[UIImage class]]) {
        [imv setImage:(UIImage *)obj];
    }else{
        NSString *path = HDFORMAT(@"%@app%@", IP, obj);
        [imv setImageWithURL:[NSURL URLWithString:path]];
    }
    [btn_addCover.superview addSubview:imv];
    [imv makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(btn_addCover);
        make.center.equalTo(btn_addCover);
    }];
    imv.contentMode = UIViewContentModeScaleAspectFill;
    imv.clipsToBounds = YES;
    imv.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)];
    [imv addGestureRecognizer:tap];
}

- (void)setBannerImags:(NSArray *)images{
    for (int i = 0; i < headOtherView.subviews.count; i++) {
        UIView *v = headOtherView.subviews[i];
        if ([v isKindOfClass:[UIImageView class]] && v.tag >= 100) {
            [v removeFromSuperview];
            i = 0;
            continue;
        }
    }
    CGFloat x = 10;
    CGFloat y = 220.;
    CGFloat height = HEADER_HEIGHT;
    for (int i = 0; i < images.count; i++) {
        if (x + 10 + imgWidth >= HDDeviceSize.width) {
            y = y + imgWidth + 10;
            x = 10;
            height = height + imgWidth + 10;
        }
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, imgWidth, imgWidth)];
        imv.contentMode = UIViewContentModeScaleAspectFill;
        imv.tag = i + 100;
        imv.clipsToBounds = YES;
        imv.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)];
        [imv addGestureRecognizer:tap];
        [headOtherView addSubview:imv];
        id obj = images[i];
        if ([obj isKindOfClass:[UIImage class]]) {
            imv.image = obj;
        }else{
            NSString *path = HDFORMAT(@"%@app%@", IP, obj);
            [imv setImageWithURL:[NSURL URLWithString:path]];
        }
        x = x + 10 + imgWidth;
    }
    if (images.count == 9) {
        btn_addBanner.hidden = YES;
        [self setTableHeader:height];
        return;
    }
    if (x + 10 + imgWidth >= HDDeviceSize.width) {
        y = y + imgWidth + 10;
        x = 10;
        height = height + imgWidth + 10;
    }
    lc_addBannerTop.constant = y ;
    lc_addBannerLeading.constant = x;
    [self setTableHeader:height];
}

- (CGFloat)getArriginalHeaderHeight{
    CGFloat lisenceHeight = 50 + 50 + (HDDeviceSize.width - 20) * 0.6 * 2;
    lc_licenseHeight.constant = lisenceHeight;
    [self.view updateConstraints];
    CGFloat otherHeight = 220 + 100 + 20;//add banner top + add banner height + bottom
    return lisenceHeight + otherHeight;
}

@end

