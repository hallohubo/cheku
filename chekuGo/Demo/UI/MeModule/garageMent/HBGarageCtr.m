//
//  HBContractCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/1/19.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBGarageCtr.h"
#import "HBGarageCell.h"
#import "HDCarDetailCtr.h"
#import "HDCarportCell.h"
#import "HDAddCarCtr.h"

@interface HBGarageCtr () {
    IBOutlet UITableView    *tbv;
    IBOutlet UITextField    *tf_search;
    IBOutlet UIView         *searchBack;
    IBOutlet UIView         *headView;
    HDRefresh               *refresh;
    NSURLSessionDataTask    *task;
    NSMutableArray          *mar_values;
    NSString                *title;
    HDGarageScreenType      screenType;
    UIBarButtonItem         *anotherButton;
}

@end

@implementation HBGarageCtr

- (id)initWithScreenType:(HDGarageScreenType)type{
    if (self = [super init]) {
        screenType = type;
    }
    return self;
}

- (id)initWithTitle:(NSString *)t{
    if (self = [super init]) {
        title = t;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setRightItem];
    [self setTableHeader];
    [self httpGetVehicles:1];
    [refresh setHeadRefresh:tbv begin:^{
        [self httpGetVehicles:1];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    NSString *keyWord = tf_search.text;
    if (keyWord.length == 0) {
        [HDHelper say:@"请输入搜索关键字"];
        return YES;
    }
    [self httpGetVehicles:1];
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    HDCarModel *car = mar_values[indexPath.row];
    if (self.chooseCarBlock) {
        self.chooseCarBlock(car);
        return;
    }
    HDAddCarCtr *ctr = [[HDAddCarCtr alloc] initWithCarId:car.id];
    [self.navigationController pushViewController:ctr animated:YES];
    ctr.saveSuccessBlock = ^{
        [HDHelper mbSay:@"更新成功"];
        [self.navigationController popViewControllerAnimated:YES];
        [self httpGetVehicles:1];
    };
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
    HDCarModel *model = mar_values[indexPath.row];
    cell.tv_title.text = model.vehicleBrand; //JSON(dic[@"vehicleBrand"]);
    NSString *str_ = model.status;
    BOOL isUsed = [str_ isEqualToString:@"忙碌"]? YES : NO;
    UIImage *img = isUsed? HDIMAGE(@"car_used"): HDIMAGE(@"car_unused");
    cell.imv.image = HDIMAGE(@"ad");
    if (model.cover.length > 0) {
        [cell.imv setImageWithURL:[NSURL URLWithString:HDFORMAT(@"%@app%@", IP, model.cover)]];
    }
    [cell.btn_carStatus setBackgroundImage:img forState:UIControlStateNormal];
    [cell.btn_carNumber setTitle:model.vehicleNumber forState:UIControlStateNormal];
    return cell;
}

#pragma mark - event
- (void)httpGetVehicles:(int)index{
    HDHttpHelper *helper = [HDHttpHelper instance];
    //NSString *key = nil;
    NSString *key = @"peccancyIsExpire";
    NSArray *ar = @[@"peccancyIsExpire", @"insureanceIsExpire", @"yearlyIsExpire", @"maintainIsExpire"];
    if (screenType - 1 < 4) {
        key = ar[screenType - 1];
        anotherButton.title     = @"";
        anotherButton.enabled   = NO;
    }
//    helper.parameters = @{@"pageIndex": @(index), @"pageSize": @"10", @"companyId": HDSTR(HDGI.loginUser.companyId)};
    NSString *key1 = [[NSString alloc] initWithString:@""];//默认为空
    if (screenType > 0) {
        //[helper.parameters setObject:@"1" forKey:HDSTR(key)];
        key1 = @"1";
    }
    NSString *strCompanyId = [HDGI.loginUser.role isEqualToString:@"Main"]? @"": HDGI.loginUser.companyId;//主账号传空
    NSString *str = HDFORMAT(@"vehicle/?pageIndex=%@&pageSize=%@&companyId=%@&%@=%@",@(index),@"10",strCompanyId,key,key1);
    //采用get query 查询方式
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:str object:[HDCarModel new] finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        [refresh finishReloadingData];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        NSArray *ar = object;
        if (index == 1) {
            mar_values = [[NSMutableArray alloc] initWithArray:ar];
        }else{
            [mar_values addObjectsFromArray:ar];
        }
        tbv.hidden = mar_values.count == 0;
        [tbv reloadData];
        [refresh setFootRefresh:tbv isLast:isLast begin:^{
            [self httpGetVehicles:index + 1];
        }];
    }];
}

- (void)addCar:(UIButton *)sender{
    HDAddCarCtr *ctr = [[HDAddCarCtr alloc] init];
    [self.navigationController pushViewController:ctr animated:YES];
    ctr.saveSuccessBlock = ^{
        [HDHelper mbSay:@"保存成功"];
        [self.navigationController popViewControllerAnimated:YES];
        [self httpGetVehicles:1];
    };
}

#pragma setter

- (void)setup {
    self.title = @"车库管理";
    if (title) {
        self.title = title;
    }
    refresh = [HDRefresh new];
    searchBack.layer.cornerRadius = 18.;
    searchBack.layer.masksToBounds = YES;
}

- (void)setRightItem {
    anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addCar:)];
    [anotherButton setTintColor:RGB(74, 148, 249)];
    self.navigationItem.rightBarButtonItem  = anotherButton;
    NSString *role = HDGI.loginUser.role;
    if (!([role isEqualToString:@"Filiale"] || [role isEqualToString:@"Executor"])) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)setTableHeader{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 56)];
    [v addSubview:headView];
    [headView makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(v);
        make.center.equalTo(v);
    }];
    tbv.tableHeaderView = v;
}

@end

@implementation HDCarModel

@end


