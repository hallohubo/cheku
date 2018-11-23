//
//  HDAddInsureCtr.m
//  Demo
//
//  Created by hufan on 2018/2/1.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDAddInsureCtr.h"
#import "HDAddCarDetailCell.h"
#import "HDTableView.h"
#import "HDPhotoHelper.h"
#import "HDImageBrowser.h"

#define imgWidth 100.

@interface HDAddInsureCtr ()<UITextFieldDelegate>{
    IBOutlet HDTableView *tbv;
    IBOutlet UIView *headView;
    IBOutlet UIButton *btn_addPicture;
    IBOutlet NSLayoutConstraint *lc_addLeading;
    IBOutlet NSLayoutConstraint *lc_addTop;
    IBOutlet UIDatePicker *picker;
    IBOutlet NSLayoutConstraint *lc_pickerBottom;
    IBOutlet UIButton *btn_save;
    NSURLSessionDataTask *task;
    HDHUD *hud;
    NSString *vehicleId;
    NSString *insureId;
    NSString *insuranceNumber;
    NSString *insuranceDate;
    NSString *insurancePrice;
    NSString *insuranceMoney;
    NSString *insureanceExpiryDate;
    NSMutableArray *mar_pictures;
    NSMutableArray *mar_urls;
}

@end

@implementation HDAddInsureCtr
- (id)initWithCarIdentifier:(NSString *)identifier{
    if (self = [super init]) {
        vehicleId = identifier;
    }
    return self;
}

- (id)initWithInsureId:(NSString *)insure{
    if (self = [super init]) {
        insureId = insure;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpGetInsureModel];
    [self setTableFooter:300];
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
    if (textField.tag == 1 || textField.tag == 4) {
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
- (void)textFiledValueChanged:(UITextField *)textField{
    switch (textField.tag) {
        case 0:{
            insuranceNumber = textField.text;
            break;
        }
        case 1:{
//            insuranceDate = textField.text;
            break;
        }
        case 2:{
            insurancePrice = textField.text;
            break;
        }
        case 3:{
            insuranceMoney = textField.text;
            break;
        }
        case 4:{
            
            break;
        }
        default:
            break;
    }
}

- (IBAction)datepickerValueChanged:(UIDatePicker *)sender{
    NSString *date = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
    if (sender.tag == 1) {
        insuranceDate = date;
    }
    if (sender.tag == 4) {
        insureanceExpiryDate = date;
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
    cell.lb_title.text = @[@"保单编号", @"保险时间", @"保险金额", @"保险费用", @"保险到期时间"][indexPath.row];
    cell.tf.placeholder = @[@"请输入保单编号", @"请输入保险时间", @"请输入保险金额", @"请输入保险费用", @"请输入保险到期时间"][indexPath.row];
    cell.tf.tag = indexPath.row;
    cell.tf.text = @[HDSTR(insuranceNumber), HDSTR(insuranceDate), HDSTR(insurancePrice), HDSTR(insuranceMoney), HDSTR(insureanceExpiryDate)][indexPath.row];
    BOOL isFiliale = [HDGI.loginUser.role isEqualToString:@"Filiale"];
    BOOL isExcutor = [HDGI.loginUser.role isEqualToString:@"Executor"];
    cell.tf.userInteractionEnabled = (isFiliale && insureId.length > 0) || (isExcutor && insureId.length == 0);
    cell.tf.delegate = self;
    cell.tf.keyboardType = HDIndexPath(0, 2) || HDIndexPath(0, 3)? UIKeyboardTypeNumbersAndPunctuation: UIKeyboardTypeDefault;
    [cell.tf addTarget:self action:@selector(textFiledValueChanged:) forControlEvents:UIControlEventAllEditingEvents];
    return cell;
}

#pragma mark - event

- (void)httpGetInsureModel{
    if (insureId.length == 0) {
        return;
    }
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:HDFORMAT(@"/vehicle-insurance/%@", insureId) object:nil finished:^(HDError *error, id object, BOOL isLast, id data) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        NSDictionary *dic = data;
        insuranceNumber = JSON(dic[@"insuranceNumber"]);
        insuranceDate = JSON(dic[@"insuranceDate"]);
        insuranceMoney = JSON(dic[@"insuranceMoney"]);
        insurancePrice = JSON(dic[@"insurancePrice"]);
        insureanceExpiryDate = JSON(dic[@"insureanceExpiryDate"]);
        NSArray *ar = [JSON(dic[@"insuranceImage"]) componentsSeparatedByString:@","];
        mar_urls = [[NSMutableArray alloc] initWithArray:ar];
        [self setImages:mar_urls];
        [tbv reloadData];
    }];
}

- (void)httpUploadImage:(UIImage *)img{
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
        [mar_pictures addObject:img];
        [self setImages:mar_pictures];
        NSString *path = JSON(object[@"url"]);
        [mar_urls addObject:path];
    }];
}

- (void)httpPut{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    NSString *imgUrl = mar_urls[0];
    for (int i = 1; i < mar_urls.count; i++) {
        NSString *s = mar_urls[i];
        imgUrl = HDFORMAT(@"%@,%@", imgUrl, s);
    }
    helper.parameters = @{@"vehicleId": HDSTR(vehicleId),
                          @"insuranceNumber": HDSTR(insuranceNumber),
                          @"insuranceDate": HDSTR(insuranceDate),
                          @"insuranceMoney": HDSTR(insuranceMoney),
                          @"insurancePrice": HDSTR(insurancePrice),
                          @"insureanceExpiryDate": HDSTR(insureanceExpiryDate),
                          @"insuranceImage": HDSTR(imgUrl)
                          };
    task = [helper putPath:HDFORMAT(@"/vehicle-insurance/%@", insureId) object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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

- (void)httpPost{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    NSString *imgUrl = mar_urls[0];
    for (int i = 1; i < mar_urls.count; i++) {
        NSString *s = mar_urls[i];
        imgUrl = HDFORMAT(@"%@,%@", imgUrl, s);
    }
    helper.parameters = @{@"vehicleId": HDSTR(vehicleId),
                          @"insuranceNumber": HDSTR(insuranceNumber),
                          @"insuranceDate": HDSTR(insuranceDate),
                          @"insuranceMoney": HDSTR(insuranceMoney),
                          @"insurancePrice": HDSTR(insurancePrice),
                          @"insureanceExpiryDate": HDSTR(insureanceExpiryDate),
                          @"insuranceImage": HDSTR(imgUrl)
                          };
    task = [helper postPath:@"/vehicle-insurance" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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
    if (insuranceNumber.length == 0) {
        [HDHelper say:@"请输入保险单号"];
        return;
    }
    if (insuranceNumber.length > 30) {
        [HDHelper say:@"请输入正确保险单号"];
        return;
    }
    if (insuranceDate.length == 0) {
        [HDHelper say:@"请输入保险时间"];
        return;
    }
    if (insuranceDate.length > 20) {
        [HDHelper say:@"请输入正确保险时间"];
        return;
    }
    if (insurancePrice.length == 0) {
        [HDHelper say:@"请输入保险金额"];
        return;
    }
    if (insurancePrice.length > 20) {
        [HDHelper say:@"请输入正确保险金额"];
        return;
    }
    if (insuranceMoney.length == 0) {
        [HDHelper say:@"请输入保险费用"];
        return;
    }
    if (insuranceMoney.length > 20) {
        [HDHelper say:@"请输入正确保险费用"];
        return;
    }
    if (mar_urls.count == 0) {
        [HDHelper say:@"请选择保单照片"];
        return;
    }
    if (insureId.length > 0) {
        [self httpPut];
        return;
    }
    [self httpPost];
}

- (IBAction)doAddPicture:(id)sender{
    if (mar_pictures.count == 9) {
        [HDHelper say:@"最多只能添加9张"];
        return;
    }
    [[HDPhotoHelper instance] read:^(UIImage *image) {
        if (image) {
            [self httpUploadImage:image];
        }
    }];
    
}

- (IBAction)doPickerButtonAction:(UIButton *)sender{
    if (sender.tag == 1) {
        NSString *date = [HDDateHelper stringWithDate:picker.date withFormat:@"yyyy-MM-dd"];
        if (picker.tag == 1) {
            insuranceDate = date;
        }
        if (picker.tag == 4) {
            insureanceExpiryDate = date;
        }
        [tbv reloadData];
    }
    lc_pickerBottom.constant = -210.;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
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
            if (tag < mar_pictures.count) {
                [mar_pictures removeObjectAtIndex:tag];
            }
            if (tag < mar_urls.count) {
                [mar_urls removeObjectAtIndex:tag];
            }
            [self setImages:mar_pictures.count > 0? mar_pictures: mar_urls];
        }
    }];
}

#pragma mark - setter
- (void)setup{
    self.title = @"保单录入";
    btn_addPicture.layer.cornerRadius   = 5.;
    btn_addPicture.layer.masksToBounds  = YES;
    btn_addPicture.layer.borderColor    = HDCOLOR_GRAY.CGColor;
    btn_addPicture.layer.borderWidth    = 1.;
    mar_pictures = [NSMutableArray new];
    mar_urls = [NSMutableArray new];
    lc_pickerBottom.constant = -210.;
    [self.view updateConstraints];
}

- (void)setImages:(NSArray *)images{
    for (int i = 0; i < headView.subviews.count; i++) {
        UIView *v = headView.subviews[i];
        if ([v isKindOfClass:[UIImageView class]]) {
            [v removeFromSuperview];
            i = 0;
            continue;
        }
    }
    CGFloat x = 10;
    CGFloat y = 70.;
    CGFloat tableFooterHeight = 300.;
    for (int i = 0; i < images.count; i++) {
        if (x + 10 + imgWidth >= HDDeviceSize.width) {
            y = y + imgWidth + 10;
            x = 10;
            tableFooterHeight = tableFooterHeight + imgWidth + 10;
        }
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, imgWidth, imgWidth)];
        imv.contentMode = UIViewContentModeScaleAspectFill;
        imv.tag = i;
        imv.clipsToBounds = YES;
        imv.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)];
        [imv addGestureRecognizer:tap];
        [headView addSubview:imv];
        id img = images[i];
        if ([img isKindOfClass:[UIImage class]]) {
            imv.image = img;
        }else{
            [imv setImageWithURL:[NSURL URLWithString:HDFORMAT(@"%@app%@", IP, img)]];
        }
        x = x + 10 + imgWidth;
    }
    if (x + 10 + imgWidth >= HDDeviceSize.width) {
        y = y + imgWidth + 10;
        x = 10;
        tableFooterHeight = tableFooterHeight + imgWidth + 10;
    }
    lc_addTop.constant = y;
    lc_addLeading.constant = x;
    [self setTableFooter:tableFooterHeight];
}

- (void)setTableFooter:(CGFloat)height{
    BOOL isFiliale = [HDGI.loginUser.role isEqualToString:@"Filiale"];
    BOOL isExcutor = [HDGI.loginUser.role isEqualToString:@"Executor"];
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, height)];
    [v addSubview:headView];
    v.backgroundColor = [UIColor clearColor];
    [headView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(v);
        make.center.equalTo(v);
    }];
    tbv.tableFooterView = v;
    btn_save.hidden = YES;
    //最高管理员可以修改，但不能添加；执行者可以添加，但不能修改；其他看
    if ((isFiliale && insureId.length > 0) || (isExcutor && insureId.length == 0)) {//有修改的情况
        btn_save.hidden = NO;
    }
}
@end

@implementation HDInsureModel

@end
