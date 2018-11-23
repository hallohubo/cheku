//
//  HDCarPeccancyCtr.m
//  Demo
//
//  Created by hufan on 2018/1/31.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDCarPeccancyCtr.h"
#import "HDCarPeccancyCell.h"
#import "HDAddInsureCtr.h"
#import "HDAddInspectionCtr.h"
#import "HDAddMaintainCtr.h"
#import "HDAddAccidentCtr.h"
#import "HDAddInsureCtr.h"

@interface HDCarPeccancyCtr (){
    IBOutlet UITableView *tbv;
    IBOutlet UIButton *btn_add;
    IBOutlet NSLayoutConstraint *lc_menuTop;
    IBOutlet UIButton *btn_menu0;
    IBOutlet UIButton *btn_menu1;
    IBOutlet UIButton *btn_menu2;
    IBOutlet UIButton *btn_menu3;
    IBOutlet UIButton *btn_menu4;
    IBOutlet NSLayoutConstraint *lc_menuWith3;
    IBOutlet NSLayoutConstraint *lc_menuWith4;
    NSURLSessionDataTask *task;
    HDHUD *hud;
    HDRefresh *refresh;
    NSMutableArray *mar_values;
    NSString *carIdetifier;
    HDCarDetailType carDetailType;
}

@end

@implementation HDCarPeccancyCtr

- (id)initWithCarId:(NSString *)carId carDetailType:(HDCarDetailType)type{
    if (self = [super init]) {
        carIdetifier = carId;
        carDetailType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTypeUI];
    [self httpGetValues:1];
    [refresh setHeadRefresh:tbv begin:^{
        [self httpGetValues:1];
    }];
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

- (void)doTouchNullAction{
    [super doTouchNullAction];
    [self httpGetValues:1];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.view endEditing:NO];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (refresh.refreshHeader) {
        [refresh.refreshHeader egoRefreshScrollViewDidScroll:scrollView];
    }
    if (refresh.refreshFooter) {
        [refresh.refreshFooter egoRefreshScrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (refresh.refreshHeader) {
        [refresh.refreshHeader egoRefreshScrollViewDidEndDragging:scrollView];
    }
    if (refresh.refreshFooter) {
        [refresh.refreshFooter egoRefreshScrollViewDidEndDragging:scrollView];
    }
}
#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (carDetailType) {
        case HDCarDetailTypePeccancy:{
            
            break;
        }
        case HDCarDetailTypeInsure:{
            NSDictionary *dic = mar_values[indexPath.row];
            NSString *insureId = JSON(dic[@"id"]);
            HDAddInsureCtr *ctr = [[HDAddInsureCtr alloc] initWithInsureId:insureId];
            [self.navigationController pushViewController:ctr animated:YES];
            ctr.saveSuccessBlock = ^{
                [self httpGetValues:1];
                [self.navigationController popViewControllerAnimated:YES];
            };
            break;
        }
        case HDCarDetailTypeInspection:{
            NSDictionary *dic = mar_values[indexPath.row];
            NSString *inspectionId = JSON(dic[@"id"]);
            HDAddInspectionCtr *ctr = [[HDAddInspectionCtr alloc] initWithInspectionId:inspectionId];
            [self.navigationController pushViewController:ctr animated:YES];
            ctr.saveSuccessBlock = ^{
                [self httpGetValues:1];
                [self.navigationController popViewControllerAnimated:YES];
            };
            break;
        }
        case HDCarDetailTypeMaintain:{
            NSDictionary *dic = mar_values[indexPath.row];
            NSString *maintainId = JSON(dic[@"id"]);
            HDAddMaintainCtr *ctr = [[HDAddMaintainCtr alloc] initWithMaintainId:maintainId];
            [self.navigationController pushViewController:ctr animated:YES];
            ctr.saveSuccessBlock = ^{
                [self httpGetValues:1];
                [self.navigationController popViewControllerAnimated:YES];
            };
            break;
        }
        case HDCarDetailTypeAccident:{
            NSDictionary *dic = mar_values[indexPath.row];
            NSString *accidentId = JSON(dic[@"id"]);
            HDAddAccidentCtr *ctr = [[HDAddAccidentCtr alloc] initWithAccidentId:accidentId];
            [self.navigationController pushViewController:ctr animated:YES];
            ctr.saveSuccessBlock = ^{
                [self httpGetValues:1];
                [self.navigationController popViewControllerAnimated:YES];
            };
            break;
        }
        default:
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
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
    return mar_values.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"HDCarPeccancyCell";
    HDCarPeccancyCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HDCarPeccancyCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGFloat width = ((HDDeviceSize.width - 16.) / 5.);
        if (carDetailType == HDCarDetailTypePeccancy) {
            cell.lc_Width3.constant = width * 0.7;
            cell.lc_Width4.constant = width * 0.7;
        }
        if (carDetailType == HDCarDetailTypeInsure) {
            cell.lc_Width3.constant = ((HDDeviceSize.width - 16.) / 4.);
            cell.lc_Width4.constant = 0.;
            cell.lb4.hidden = YES;
        }
        if (carDetailType == HDCarDetailTypeInspection) {
            cell.lc_Width3.constant = 0.;
            cell.lc_Width4.constant = 0.;
            cell.lb3.hidden = YES;
            cell.lb4.hidden = YES;
        }
        if (carDetailType == HDCarDetailTypeMaintain) {
            cell.lc_Width3.constant = width;
            cell.lc_Width4.constant = width;
        }
        if (carDetailType == HDCarDetailTypeAccident) {
            cell.lc_Width3.constant = width;
            cell.lc_Width4.constant = width * 0.7;
        }
        [self.view updateConstraints];
    }
    switch (carDetailType) {
        case HDCarDetailTypePeccancy:{
            NSDictionary *dic = mar_values[indexPath.row];
            cell.lb0.text = JSON(dic[@"peccancyCode"]);
            cell.lb1.text = JSON(dic[@"peccancyDate"]);
            cell.lb2.text = JSON(dic[@"peccancyFine"]);
            cell.lb3.text = JSON(dic[@"peccancyScore"]);
            cell.lb4.text = JSON(dic[@"peccancyState"]);
            break;
        }
        case HDCarDetailTypeInsure:{
            NSDictionary *dic = mar_values[indexPath.row];
            cell.lb0.text = JSON(dic[@"insuranceNumber"]);
            cell.lb1.text = JSON(dic[@"insuranceDate"]);
            cell.lb2.text = JSON(dic[@"insuranceMoney"]);
            cell.lb3.text = JSON(dic[@"insurancePrice"]);
            cell.lb4.text = @"";
            break;
        }
        case HDCarDetailTypeInspection:{
            NSDictionary *dic = mar_values[indexPath.row];
            cell.lb0.text = JSON(dic[@"workUser"]);
            cell.lb1.text = JSON(dic[@"yearlyDate"]);
            cell.lb2.text = JSON(dic[@"lastModifyTime"]);
            cell.lb3.text = @"";
            cell.lb4.text = @"";
            break;
        }
        case HDCarDetailTypeMaintain:{
            NSDictionary *dic = mar_values[indexPath.row];
            cell.lb0.text = JSON(dic[@"lastDate"]);
            cell.lb1.text = JSON(dic[@"vkt"]);
            cell.lb2.text = JSON(dic[@"workUser"]);
            cell.lb3.text = JSON(dic[@"expense"]);
            cell.lb4.text = JSON(dic[@"lastModifyTime"]);
            break;
        }
        case HDCarDetailTypeAccident:{
            NSDictionary *dic = mar_values[indexPath.row];
            cell.lb0.text = JSON(dic[@"litigant"]);
            cell.lb1.text = JSON(dic[@"accidentDate"]);
            cell.lb2.text = JSON(dic[@"expense"]);
            cell.lb3.text = JSON(dic[@"responsibilityTyoe"]);
            cell.lb4.text = JSON(dic[@"liaisonOfficer"]);
            break;
        }
        default:
            break;
    }
    
    return cell;
}

#pragma mark - event
- (void)httpGetValues:(int)index{
    HDHttpHelper *helper = [HDHttpHelper instance];
    helper.parameters = @{@"vehicleId": HDSTR(carIdetifier), @"pageIndex": @(index), @"pageSize": @"10"};
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    NSArray *pathes = @[@"vehicle-peccancy", @"vehicle-insurance", @"vehicle-yearly", @"vehicle-maintain", @"vehicle-accident"];
    task = [helper getPath:pathes[carDetailType] object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        [refresh finishReloadingData];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        NSArray *ar = json[@"content"];
        if (index == 1) {
            mar_values = [[NSMutableArray alloc] initWithArray:ar];
        }else{
            [mar_values addObjectsFromArray:ar];
        }
        tbv.hidden = mar_values.count == 0;
        [tbv reloadData];
        BOOL isLastPage = mar_values.count >= JSON(json[@"totalCount"]).intValue;
        [refresh setFootRefresh:tbv isLast:isLastPage begin:^{
            [self httpGetValues:index + 1];
        }];
    }];
}

- (IBAction)doAdd:(UIButton *)sender{
    BOOL isExecutor = [HDGI.loginUser.role isEqualToString:@"Executor"];
    if (!isExecutor) {
        NSArray *ar = @[@"", @"保险", @"年检", @"保养", @"事故"];
        [HDHelper say:HDFORMAT(@"抱歉，您没有添加%@的权限", ar[carDetailType])];
        sender.enabled = NO;
        [sender setAlpha:0.5];
        return;
    }
    switch (carDetailType) {
        case HDCarDetailTypeInsure:{//新增保险
            HDAddInsureCtr *ctr = [[HDAddInsureCtr alloc] initWithCarIdentifier:carIdetifier];
            ctr.saveSuccessBlock = ^{
                [self.navigationController popViewControllerAnimated:YES];
                [self httpGetValues:1];
            };
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
        case HDCarDetailTypeInspection:{//新增年检
            HDAddInspectionCtr *ctr = [[HDAddInspectionCtr alloc] initWithCarIdentifier:carIdetifier];
            ctr.saveSuccessBlock = ^{
                [self.navigationController popViewControllerAnimated:YES];
                [self httpGetValues:1];
            };
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
        case HDCarDetailTypeMaintain:{//新增保养
            HDAddMaintainCtr *ctr = [[HDAddMaintainCtr alloc] initWithCarIdentifier:carIdetifier];
            ctr.saveSuccessBlock = ^{
                [self.navigationController popViewControllerAnimated:YES];
                [self httpGetValues:1];
            };
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
        case HDCarDetailTypeAccident:{//新增事故
            HDAddAccidentCtr *ctr = [[HDAddAccidentCtr alloc] initWithCarIdentifier:carIdetifier];
            ctr.saveSuccessBlock = ^{
                [self.navigationController popViewControllerAnimated:YES];
                [self httpGetValues:1];
            };
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
        default:
            break;
    }
}
#pragma mark - setter
- (void)setup{
    self.title = @"";
    btn_add.layer.cornerRadius = 18.;
    btn_add.layer.masksToBounds = YES;
    btn_add.layer.borderWidth = 1.;
    btn_add.layer.borderColor = RGB(226, 75, 59).CGColor;
    refresh = [HDRefresh new];
}

- (void)setTypeUI{
    btn_add.hidden = carDetailType == HDCarDetailTypePeccancy;
    lc_menuTop.constant = carDetailType == HDCarDetailTypePeccancy? 10.: 60.;
    NSString *title = @[@"", @"+添加新保险", @"+添加新年检", @"+添加新保养", @"+添加新事故"][carDetailType];
    [btn_add setTitle:title forState:UIControlStateNormal];
    
    NSString *menu0 = @[@"违章编号", @"保险单号", @"经办人", @"保养时间", @"经办人"][carDetailType];
    NSString *menu1 = @[@"违章时间", @"保险时间", @"年检时间", @"当前公里", @"事故时间"][carDetailType];
    NSString *menu2 = @[@"金额", @"保险费用", @"记录时间", @"经办人", @"处理费用"][carDetailType];
    NSString *menu3 = @[@"扣分", @"保险金额", @"", @"保养费用", @"责任类型"][carDetailType];
    NSString *menu4 = @[@"状态", @"", @"", @"记录时间", @"对接人"][carDetailType];
    [btn_menu0 setTitle:menu0 forState:UIControlStateNormal];
    [btn_menu1 setTitle:menu1 forState:UIControlStateNormal];
    [btn_menu2 setTitle:menu2 forState:UIControlStateNormal];
    [btn_menu3 setTitle:menu3 forState:UIControlStateNormal];
    [btn_menu4 setTitle:menu4 forState:UIControlStateNormal];
    CGFloat width = ((HDDeviceSize.width - 16.) / 5.);
    if (carDetailType == HDCarDetailTypePeccancy) {
        lc_menuWith3.constant = width * 0.7;
        lc_menuWith4.constant = width * 0.7;
    }
    if (carDetailType == HDCarDetailTypeInsure) {
        lc_menuWith3.constant = ((HDDeviceSize.width - 16.) / 4.);
        lc_menuWith4.constant = 0.;
    }
    if (carDetailType == HDCarDetailTypeInspection) {
        lc_menuWith3.constant = 0.;
        lc_menuWith4.constant = 0.;
    }
    if (carDetailType == HDCarDetailTypeMaintain) {
        lc_menuWith3.constant = width;
        lc_menuWith4.constant = width;
    }
    if (carDetailType == HDCarDetailTypeAccident) {
        lc_menuWith3.constant = width;
        lc_menuWith4.constant = width * 0.7;
    }
    [self.view updateConstraints];
}
@end
