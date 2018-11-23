//
//  HDCarportCtr.m
//  Demo
//
//  Created by hufan on 2018/1/18.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDCarportCtr.h"
#import "HDCarportCell.h"
#import "HDCarDetailCtr.h"
#import "HDCarInformationCtr.h"

@interface HDCarportCtr (){
    IBOutlet UITableView *tbv;
    IBOutlet UIView *v_searchBack;
    IBOutlet UITextField *tf_search;
    NSURLSessionDataTask *task;
    HDRefresh *refresh;
    HDHUD *hud;
    NSMutableArray *mar_values;
    BOOL isThisViewShowInTheWindow;
    NSString *typeCar;//首页车辆统计类别查询
    int      typeInt;//首页车辆统计类别查询
}

@end

@implementation HDCarportCtr

- (instancetype)initWithCarType:(NSString *)type_ companyId:(NSString *)companyIdenty {
    self = [super init];
    if(self)
    {
        typeCar = type_;
        typeInt = 1;
        _strCompanyId = companyIdenty;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpGetVehicles:1 keyWorld:@"" companyId:_strCompanyId companyEvenStatisticType:typeCar];
    [refresh setHeadRefresh:tbv begin:^{
        [self httpGetVehicles:1 keyWorld:@"" companyId:_strCompanyId companyEvenStatisticType:typeCar];
        }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationTapTabbarIndex:) name:HDNOTI_DID_TAP_TABBAR_INDEX object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    HDNavigationBarHidden = NO;
    task = nil;
    [hud hiden];
    hud = nil;
    _strCompanyId = @"";
    typeInt = @"0";
    [self httpGetVehicles:1 keyWorld:@"" companyId:_strCompanyId companyEvenStatisticType:typeCar];//重新进入页面时复位加载
}
- (void)viewWillAppear:(BOOL)animated{
    HDNavigationBarHidden = YES;
    if ([HDHelper isTimeToRefresh:@"HDCarportCtr"]) {
        [self httpGetVehicles:1 keyWorld:@"" companyId:_strCompanyId companyEvenStatisticType:typeCar];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    isThisViewShowInTheWindow = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    isThisViewShowInTheWindow = NO;
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
    NSDictionary *car = mar_values[indexPath.row];
    NSString *carId = car[@"id"];
    HDCarDetailCtr *ctr = [[HDCarDetailCtr alloc] initWithCarId:carId];
    if (typeCar.length > 0) {
        [self.navigationController pushViewController:ctr animated:YES];
        return;
    }
    [self.tabBarController.navigationController pushViewController:ctr animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 117.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return .1;
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
    static NSString *str = @"HDCarportCell";
    HDCarportCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HDCarportCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSDictionary *dic = mar_values[indexPath.row];
    cell.tv_title.text = JSON(dic[@"vehicleBrand"]);
    NSString *str_ = JSON(dic[@"status"]) ;
    BOOL isUsed = [str_ isEqualToString:@"忙碌"]? YES : NO;
    UIImage *img = isUsed? HDIMAGE(@"car_used"): HDIMAGE(@"car_unused");
    cell.imv.image = HDIMAGE(@"ad");
    NSString *cover = HDDIC(dic[@"cover"]);
    if (cover.length > 0) {
        [cell.imv setImageWithURL:[NSURL URLWithString:HDFORMAT(@"%@app%@", IP, cover)]];
    }
    
    [cell.btn_carStatus setBackgroundImage:img forState:UIControlStateNormal];
    [cell.btn_carNumber setTitle:JSON(dic[@"vehicleNumber"]) forState:UIControlStateNormal];
    return cell;
}

#pragma mark - event
- (void)httpGetVehicles:(int)index keyWorld:(NSString *)word companyId:(NSString *)companyCars companyEvenStatisticType:(NSString *)type{
    HDHttpHelper *helper = [HDHttpHelper instance];
    helper.parameters = @{@"pageIndex": @(index), @"pageSize": @"10", @"keyword": HDSTR(word),@"companyId":HDSTR(companyCars),HDSTR(type):@"1"};
    //NSString *str = HDFORMAT(@"vehicle?pageIndex=%d&pageSize=10&companyId=%@&%@=1",index,companyCars,type);
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:@"vehicle" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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
            [self httpGetVehicles:index + 1 keyWorld:word companyId:_strCompanyId companyEvenStatisticType:typeCar];
        }];
    }];
}
- (void)notificationTapTabbarIndex:(NSNotification *)noti{
    NSDictionary *userInfo = noti.userInfo;
    NSNumber *index = userInfo[@"index"];
    Dlog(@"index = %@", index);
    if (index.intValue == 1 && isThisViewShowInTheWindow) {
        [self httpGetVehicles:1 keyWorld:@"" companyId:_strCompanyId companyEvenStatisticType:typeCar];
    }
    NSArray *keys = [userInfo allKeys];
    for (NSString *key in keys) {//最高管理者在我的页面分公司管理点分公司列表项时 查看分公司车辆信息
        if ([key isEqualToString:@"strCompanyId"]) {
            _strCompanyId = userInfo[@"strCompanyId"];
            [self httpGetVehicles:1 keyWorld:@"" companyId:_strCompanyId companyEvenStatisticType:typeCar];
        }
    }
}

- (void)notificationTap:(NSNotification *)noti {
    NSDictionary *userInfo = noti.userInfo;
//    typeCar = userInfo[@"index"];
//    typeInt = 1;
    
}
- (IBAction)doSearch:(id)sender{
    [self.view endEditing:YES];
    NSString *keyWord = tf_search.text;
    if (keyWord.length == 0) {
        [HDHelper say:@"请输入搜索关键字"];
        return;
    }
    [self httpGetVehicles:1 keyWorld:keyWord companyId:_strCompanyId companyEvenStatisticType:typeCar];
}

#pragma mark - setter
- (void)setup{
    self.title = @"车库";
    mar_values = [NSMutableArray new];
    refresh = [HDRefresh new];
    v_searchBack.backgroundColor =HDCOLOR_GRAY;
    v_searchBack.layer.cornerRadius = 15.;
    v_searchBack.layer.masksToBounds = YES;
}

@end
