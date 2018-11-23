//
//  HDAddAccidentCtr.m
//  Demo
//
//  Created by hufan on 2018/2/1.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDAddAccidentCtr.h"
#import "HDAddCarDetailCell.h"
#import "HDTableView.h"
#import "UITextView+Placeholder.h"
#import "HDPhotoHelper.h"
#import "HDImageBrowser.h"

#define FOOTER_HEIGHT 1100.
#define imgWidth 100.

@interface HDAddAccidentCtr (){
    IBOutlet HDTableView *tbv;
    IBOutlet UIView *footerView;
    IBOutlet UIDatePicker *picker;
    IBOutlet NSLayoutConstraint *lc_pickerBottom;
    IBOutlet UIButton *btn_addBill;
    IBOutlet UIButton *btn_addAccidentImage;
    IBOutlet NSLayoutConstraint *lc_addBillBtnTop;
    IBOutlet NSLayoutConstraint *lc_addBillBtnLeading;
    IBOutlet NSLayoutConstraint *lc_addAccidentBtnTop;
    IBOutlet NSLayoutConstraint *lc_addAccidentBtnLeading;
    IBOutlet UITextView *tv_remark;
    IBOutlet UILabel *lb_chooseAccidentBlock;
    NSMutableArray *mar_billImage;
    NSMutableArray *mar_billUrl;
    NSMutableArray *mar_accidentImage;
    NSMutableArray *mar_accidentUrl;
    NSMutableArray *mar_accidentBlocks;
    NSURLSessionDataTask *task;
    HDHUD *hud;
    NSString *vehicleId;
    NSString *litigant;//当事人
    NSString *accidentDate;
    NSString *expense;
    NSString *responsibilityTyoe;
    NSString *liaisonOfficer;//对接人
    CGFloat billHeight;
    CGFloat accidentHeight;
    NSString *accidentId;
    
    IBOutlet UIButton *btn0;
    IBOutlet UIButton *btn1;
    IBOutlet UIButton *btn2;
    IBOutlet UIButton *btn3;
    IBOutlet UIButton *btn4;
    IBOutlet UIButton *btn5;
    IBOutlet UIButton *btn6;
    IBOutlet UIButton *btn7;
    IBOutlet UIButton *btn8;
    IBOutlet UIButton *btn9;
    IBOutlet UIButton *btn10;
    IBOutlet UIButton *btn11;
    IBOutlet UIButton *btn12;
    IBOutlet UIButton *btn13;
    IBOutlet UIButton *btn14;
    IBOutlet UIButton *btn15;
    IBOutlet UIButton *btn16;
    IBOutlet UIButton *btn17;
    
    IBOutlet UIButton *btn_save;
}

@end

@implementation HDAddAccidentCtr

- (id)initWithCarIdentifier:(NSString *)identifier{
    if (self = [super init]) {
        vehicleId = identifier;
    }
    return self;
}

- (id)initWithAccidentId:(NSString *)accident{
    if (self = [super init]) {
        accidentId = accident;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpGet];
    [self setTableFooter:FOOTER_HEIGHT];
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

#pragma mark - UITExtViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    CGSize size = tbv.contentSize;
    size.height += 300;
    tbv.contentSize = size;
    [tbv setContentOffset:CGPointMake(0, size.height - CGRectGetHeight(tbv.frame))];
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    CGSize size = tbv.contentSize;
    size.height -= 300;
    tbv.contentSize = size;
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    
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
    if (textField.tag == 1) {//事故时间
        [self.view endEditing:YES];
        lc_pickerBottom.constant = 0;
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
        return NO;
    }
    if (textField.tag == 3) {//责任类型
        [[HDHelper instance] showSheetWithTitle:@"请选择责任类型" first:@"全责" seconed:@"同责" third:@"对方责" showIn:self.navigationController.view finished:^(UIActionSheet *sheet, int index) {
            Dlog(@"index = %d", index);
            if (index == 3) {//取消
                return ;
            }
            responsibilityTyoe = @[@"全责", @"同责", @"对方责"][index];
            [tbv reloadData];
        }];
        return NO;
    }
    lc_pickerBottom.constant = -210;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    return YES;
}
- (IBAction)datepickerValueChanged:(UIDatePicker *)sender{
    accidentDate = [HDDateHelper stringWithDate:sender.date withFormat:@"yyyy-MM-dd"];
    [tbv reloadData];
}

- (void)textFiledValueChanged:(UITextField *)textField{
    switch (textField.tag) {
        case 0:{
            litigant = textField.text;
            break;
        }
        case 1:{
            
            break;
        }
        case 2:{
            expense = textField.text;
            break;
        }
        case 3:{
            responsibilityTyoe = textField.text;
            break;
        }
        case 4:{
            liaisonOfficer = textField.text;
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
    cell.lb_title.text = @[@"当事人", @"事故时间", @"维修费用", @"责任类型", @"对接人"][indexPath.row];
    cell.tf.placeholder = @[@"请输入当事人", @"请输入事故时间", @"请输入维修费用", @"请输入责任类型", @"请输入对接人"][indexPath.row];
    cell.tf.text = @[HDSTR(litigant), HDSTR(accidentDate), HDSTR(expense), HDSTR(responsibilityTyoe), HDSTR(liaisonOfficer)][indexPath.row];
    cell.tf.tag = indexPath.row;
    cell.tf.keyboardType = HDIndexPath(0, 2)? UIKeyboardTypeNumbersAndPunctuation: UIKeyboardTypeDefault;
    cell.tf.delegate = self;
    BOOL isFiliale = [HDGI.loginUser.role isEqualToString:@"Filiale"];
    BOOL isExcutor = [HDGI.loginUser.role isEqualToString:@"Executor"];
    cell.tf.userInteractionEnabled = (isFiliale && accidentId.length > 0) || (isExcutor && accidentId.length == 0);
    [cell.tf addTarget:self action:@selector(textFiledValueChanged:) forControlEvents:UIControlEventAllEditingEvents];
    return cell;
}


#pragma mark - event

- (void)httpGet{
    if (!accidentId || accidentId.length == 0) {
        return;
    }
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:HDFORMAT(@"/vehicle-accident/%@", accidentId) object:nil finished:^(HDError *error, id object, BOOL isLast, id data) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        NSDictionary *dic = data;
        liaisonOfficer = JSON(dic[@"liaisonOfficer"]);
        expense = JSON(dic[@"expense"]);
        responsibilityTyoe = JSON(dic[@"responsibilityTyoe"]);
        litigant = JSON(dic[@"litigant"]);
        tv_remark.text = JSON(dic[@"note"]);
        accidentDate = JSON(dic[@"accidentDate"]);
        NSString *accidentImg = JSON(dic[@"accidentImg"]);
        NSString *compensateImg = JSON(dic[@"compensateImg"]);
        NSString *accidentModel = JSON(dic[@"accidentModel"]);
        lb_chooseAccidentBlock.text = accidentModel;
        NSArray *ar = [accidentImg componentsSeparatedByString:@","];
        mar_accidentUrl = [[NSMutableArray alloc] initWithArray:ar];
        [self setAccidentImags:mar_accidentUrl];
        
        NSArray *ar_ompensate = [compensateImg componentsSeparatedByString:@","];
        mar_billUrl = [[NSMutableArray alloc] initWithArray:ar_ompensate];
        [self setBillImags:mar_billUrl];
        
        NSArray *ar_btns = @[btn0, btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9, btn10, btn11, btn12, btn13, btn14, btn15, btn16, btn17];
        NSArray *ar_model = [accidentModel componentsSeparatedByString:@","];
        mar_accidentBlocks = [[NSMutableArray alloc] initWithArray:ar_model];
        for (int i = 0; i < ar_btns.count; i++) {
            UIButton *btn = ar_btns[i];
            NSString *title = btn.titleLabel.text;
            for (int j = 0; j < ar_model.count; j++) {
                NSString *model = ar_model[j];
                if ([title isEqualToString:model]) {
                    btn.selected = YES;
                    break;
                }
            }
        }
        [tbv reloadData];
    }];
}
- (void)httpPost{
    NSString *compensateImg = mar_billUrl[0];
    for (int i = 1; i < mar_billUrl.count; i++) {
        NSString *url = mar_billUrl[i];
        compensateImg = HDFORMAT(@"%@,%@", compensateImg, url);
    }
    NSString *accidentImg = mar_accidentUrl[0];
    for (int i = 1; i < mar_accidentUrl.count; i++) {
        NSString *url = mar_accidentUrl[i];
        accidentImg = HDFORMAT(@"%@,%@", accidentImg, url);
    }
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    helper.parameters = @{@"vehicleId": HDSTR(vehicleId),
                          @"expense": HDSTR(expense),
                          @"liaisonOfficer": HDSTR(liaisonOfficer),
                          @"responsibilityTyoe": HDSTR(responsibilityTyoe),
                          @"litigant": HDSTR(litigant),
                          @"accidentDate": HDSTR(accidentDate),
                          @"note": HDSTR(tv_remark.text),
                          @"accidentModel": HDSTR(lb_chooseAccidentBlock.text),
                          @"descImg": HDSTR(@""),
                          @"accidentImg": HDSTR(accidentImg),
                          @"compensateImg": HDSTR(compensateImg)
                          };
    task = [helper postPath:@"/vehicle-accident" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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
    NSString *compensateImg = mar_billUrl[0];
    for (int i = 1; i < mar_billUrl.count; i++) {
        NSString *url = mar_billUrl[i];
        compensateImg = HDFORMAT(@"%@,%@", compensateImg, url);
    }
    NSString *accidentImg = mar_accidentUrl[0];
    for (int i = 1; i < mar_accidentUrl.count; i++) {
        NSString *url = mar_accidentUrl[i];
        accidentImg = HDFORMAT(@"%@,%@", accidentImg, url);
    }
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    helper.parameters = @{@"vehicleId": HDSTR(vehicleId),
                          @"expense": HDSTR(expense),
                          @"liaisonOfficer": HDSTR(liaisonOfficer),
                          @"responsibilityTyoe": HDSTR(responsibilityTyoe),
                          @"litigant": HDSTR(litigant),
                          @"accidentDate": HDSTR(accidentDate),
                          @"note": HDSTR(tv_remark.text),
                          @"accidentModel": HDSTR(lb_chooseAccidentBlock.text),
                          @"descImg": HDSTR(@""),
                          @"accidentImg": HDSTR(accidentImg),
                          @"compensateImg": HDSTR(compensateImg)
                          };
    task = [helper putPath:HDFORMAT(@"/vehicle-accident/%@", accidentId) object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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

- (void)httpUploadImage:(UIImage *)img buttonIndex:(int)tag{
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
        if (tag == 0) {
            [mar_billImage addObject:img];
            [self setBillImags:mar_billImage];
            NSString *path = JSON(object[@"url"]);
            [mar_billUrl addObject:path];
            return;
        }
        [mar_accidentImage addObject:img];
        [self setAccidentImags:mar_accidentImage];
        NSString *path = JSON(object[@"url"]);
        [mar_accidentUrl addObject:path];
    }];
}

- (IBAction)doSave:(id)sender{
    if (litigant.length == 0) {
        [HDHelper say:@"请输入当事人姓名"];
        return;
    }
    if (litigant.length > 20) {
        [HDHelper say:@"请输入小于20个字当事人姓名"];
        return;
    }
    if (expense.length > 10) {
        [HDHelper say:@"请输入正确维修费用"];
        return;
    }
    if (expense.length == 0) {
        [HDHelper say:@"请输入维修费用"];
        return;
    }
    if (responsibilityTyoe.length > 10) {
        [HDHelper say:@"请输入正确责任类型"];
        return;
    }
    if (responsibilityTyoe.length == 0) {
        [HDHelper say:@"请输入责任类型"];
        return;
    }
    if (liaisonOfficer.length > 20) {
        [HDHelper say:@"请输入20字以内对接人姓名"];
        return;
    }
    if (liaisonOfficer.length == 0) {
        [HDHelper say:@"请输入对接人姓名"];
        return;
    }
    if (mar_billUrl.count == 0) {
        [HDHelper say:@"请添加理赔单据图片"];
        return;
    }
    if (mar_accidentUrl.count == 0) {
        [HDHelper say:@"请添加事故照片"];
        return;
    }
    if (lb_chooseAccidentBlock.text.length == 0) {
        [HDHelper say:@"请选择事故车辆解剖模块！"];
        return;
    }
    if (accidentId.length > 0) {
        [self httpPut];
        return;
    }
    [self httpPost];
}


- (IBAction)doPickerButtonAction:(UIButton *)sender{
    if (sender.tag == 1) {
        NSString *date = [HDDateHelper stringWithDate:picker.date withFormat:@"yyyy-MM-dd"];
        accidentDate = date;
        [tbv reloadData];
    }
    lc_pickerBottom.constant = -210.;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)doAddBillImage:(UIButton *)sender{
    if (mar_billImage.count == 9) {
        [HDHelper say:@"最多只能添加9张"];
        return;
    }
    [[HDPhotoHelper instance] read:^(UIImage *image) {
        if (image) {
            [self httpUploadImage:image buttonIndex:sender.tag];
        }
    }];
}

- (IBAction)doAddAccidentImage:(UIButton *)sender{
    if (mar_accidentImage.count == 9) {
        [HDHelper say:@"最多只能添加9张"];
        return;
    }
    [[HDPhotoHelper instance] read:^(UIImage *image) {
        if (image) {
            [self httpUploadImage:image buttonIndex:sender.tag];
        }
    }];
}

- (IBAction)doChooseCarAccidentBlock:(UIButton *)sender{
    Dlog(@"sender.title = %@", sender.titleLabel.text);
    sender.selected = !sender.selected;
    if (!sender.selected) {
        for (int i = 0; i < mar_accidentBlocks.count; i++) {
            NSString *block = mar_accidentBlocks[i];
            if ([block isEqualToString:sender.titleLabel.text]) {
                [mar_accidentBlocks removeObjectAtIndex:i];
            }
        }
    }else{
        [mar_accidentBlocks addObject:sender.titleLabel.text];
    }
    //设置选择后的模块字符串显示于label中
    NSString *block = @"";
    for (int i = 0; i < mar_accidentBlocks.count; i++) {
        NSString *s = mar_accidentBlocks[i];
        block = HDFORMAT(@"%@,%@", block, s);
    }
    if ([block hasPrefix:@","]) {
        block = [block substringFromIndex:1];
    }
    lb_chooseAccidentBlock.text = block;
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
            if (tag < 10) {
                if (tag < mar_billImage.count) {
                    [mar_billImage removeObjectAtIndex:tag];
                }
                if (tag < mar_billUrl.count) {
                    [mar_billUrl removeObjectAtIndex:tag];
                }
                [self setBillImags:mar_billImage];
            }else{
                if (tag < mar_accidentImage.count) {
                    [mar_accidentImage removeObjectAtIndex:tag];
                }
                if (tag < mar_accidentUrl.count) {
                    [mar_accidentUrl removeObjectAtIndex:tag];
                }
                [self setAccidentImags:mar_accidentImage];
            }
            
        }
    }];
}

#pragma mark - setter
- (void)setup{
    self.title = @"事故录入";
    if (accidentId.length > 0) {
        self.title = @"事故详情";
    }
    lc_pickerBottom.constant = -210;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    btn_addBill.layer.cornerRadius   = 5.;
    btn_addBill.layer.masksToBounds  = YES;
    btn_addBill.layer.borderColor    = HDCOLOR_GRAY.CGColor;
    btn_addBill.layer.borderWidth    = 1.;
    btn_addAccidentImage.layer.cornerRadius   = 5.;
    btn_addAccidentImage.layer.masksToBounds  = YES;
    btn_addAccidentImage.layer.borderColor    = HDCOLOR_GRAY.CGColor;
    btn_addAccidentImage.layer.borderWidth    = 1.;
    tv_remark.placeholder = @"请输入说明备注";
    
    mar_accidentUrl = [NSMutableArray new];
    mar_accidentImage = [NSMutableArray new];
    mar_billUrl = [NSMutableArray new];
    mar_billImage = [NSMutableArray new];
    mar_accidentBlocks = [NSMutableArray new];
    
    accidentHeight = 0.;
    billHeight = 0.;
}
- (void)setTableFooter:(CGFloat)height{
    NSString *role = HDGI.loginUser.role;
    BOOL isFiliale = [role isEqualToString:@"Filiale"];
    BOOL isExcutor = [role isEqualToString:@"Executor"];
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, height)];
    [v addSubview:footerView];
    v.backgroundColor = [UIColor clearColor];
    [footerView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(v);
        make.center.equalTo(v);
    }];
    tbv.tableFooterView = v;
    v.userInteractionEnabled = NO;
    if ((isFiliale && accidentId.length > 0) || (isExcutor && accidentId.length == 0)) {
        v.userInteractionEnabled = YES;
    }
}

- (void)setBillImags:(NSArray *)images{
    for (int i = 0; i < footerView.subviews.count; i++) {
        UIView *v = footerView.subviews[i];
        if ([v isKindOfClass:[UIImageView class]] && v.tag < 10) {
            [v removeFromSuperview];
            i = 0;
            continue;
        }
    }
    CGFloat x = 10;
    CGFloat y = 70.;
    CGFloat height = FOOTER_HEIGHT + accidentHeight;
    for (int i = 0; i < images.count; i++) {
        if (x + 10 + imgWidth >= HDDeviceSize.width) {
            y = y + imgWidth + 10;
            x = 10;
            height = height + imgWidth + 10;
        }
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, imgWidth, imgWidth)];
        imv.contentMode = UIViewContentModeScaleAspectFill;
        imv.tag = i;
        imv.clipsToBounds = YES;
        imv.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)];
        [imv addGestureRecognizer:tap];
        [footerView addSubview:imv];
        id img = images[i];
        if ([img isKindOfClass:[UIImage class]]) {
            [imv setImage:img];
        }else{
            [imv setImageWithURL:[NSURL URLWithString:HDFORMAT(@"%@app%@", IP, img)]];
        }
        x = x + 10 + imgWidth;
    }
    if (x + 10 + imgWidth >= HDDeviceSize.width) {
        y = y + imgWidth + 10;
        x = 10;
        height = height + imgWidth + 10;
    }
    lc_addBillBtnTop.constant = y;
    lc_addBillBtnLeading.constant = x;
    //    btn_addPicture.frame = CGRectMake(x, y, imgWidth, imgWidth);
    [self setTableFooter:height];
    billHeight = height - FOOTER_HEIGHT - accidentHeight;
    [self setAccidentImags:mar_accidentImage.count > 0? mar_accidentImage: mar_accidentUrl];
}

- (void)setAccidentImags:(NSArray *)images{
    for (int i = 0; i < footerView.subviews.count; i++) {
        UIView *v = footerView.subviews[i];
        if ([v isKindOfClass:[UIImageView class]] && v.tag >= 10) {
            [v removeFromSuperview];
            i = 0;
            continue;
        }
    }
    CGFloat x = 10;
    CGFloat y = 230 + billHeight;
    CGFloat height = FOOTER_HEIGHT + billHeight;
    for (int i = 0; i < images.count; i++) {
        if (x + 10 + imgWidth >= HDDeviceSize.width) {
            y = y + imgWidth + 10;
            x = 10;
            height = height + imgWidth + 10;
        }
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, imgWidth, imgWidth)];
        imv.contentMode = UIViewContentModeScaleAspectFill;
        imv.tag = i + 10;
        imv.clipsToBounds = YES;
        imv.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)];
        [imv addGestureRecognizer:tap];
        [footerView addSubview:imv];
        id img = images[i];
        if ([img isKindOfClass:[UIImage class]]) {
            [imv setImage:img];
        }else{
            [imv setImageWithURL:[NSURL URLWithString:HDFORMAT(@"%@app%@", IP, img)]];
        }
        x = x + 10 + imgWidth;
    }
    if (x + 10 + imgWidth >= HDDeviceSize.width) {
        y = y + imgWidth + 10;
        x = 10;
        height = height + imgWidth + 10;
    }
    lc_addAccidentBtnTop.constant = y - (210 + billHeight);
    lc_addAccidentBtnLeading.constant = x;
    //    btn_addPicture.frame = CGRectMake(x, y, imgWidth, imgWidth);
    [self setTableFooter:height];
    accidentHeight = height - FOOTER_HEIGHT - billHeight;
}
@end
