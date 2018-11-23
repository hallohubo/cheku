//
//  HDMainViewCtr.m
//  Demo
//
//  Created by hufan on 2017/3/1.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import "HDMainViewCtr.h"
#import "HBGarageCtr.h"
#import "HDContractViewCtr.h"
#import "HBFinancialCtr.h"
#import "HBTaskCtr.h"
#import "HBClientCtr.h"
#import "HDCarDetailCtr.h"
#import "HDCarportCtr.h"
#import "HBFinancialCtr.h"

@interface HDMainViewCtr (){
    IBOutlet UILabel *lb_price0;
    IBOutlet UILabel *lb_price1;
    IBOutlet UILabel *lb_price2;
    IBOutlet UILabel *lb_price3;
    IBOutlet UILabel *lb_price4;
    IBOutlet UILabel *lb_price5;
    IBOutlet UILabel *lb_detail0;
    IBOutlet UILabel *lb_detail1;
    IBOutlet UILabel *lb_detail2;
    IBOutlet UILabel *lb_detail3;
    IBOutlet UILabel *lb_detail4;
    IBOutlet UILabel *lb_detail5;
    IBOutlet UILabel *lb_remain0;
    IBOutlet UILabel *lb_remain1;
    IBOutlet UILabel *lb_remain2;
    IBOutlet UILabel *lb_remain3;
    IBOutlet UILabel *lb_remain4;
    IBOutlet UILabel *lb_remain5;
    IBOutlet UILabel *lb_remain6;
    IBOutlet UILabel *lb_remain7;
    IBOutlet UILabel *lb_remain8;
    IBOutlet NSLayoutConstraint *lc_scvTop;
    IBOutlet NSLayoutConstraint *lc_tbvTop;
    IBOutlet UITableView *tbv;
    IBOutlet UIScrollView *scv;
    IBOutlet UIPageControl *pageControl;
    IBOutlet UIView *vHead;
    IBOutlet UIButton *btn0;
    IBOutlet UIButton *btn1;
    IBOutlet UIButton *btn2;
    IBOutlet UIButton *btn3;
    IBOutlet UIButton *btn4;
    IBOutlet UIButton *btn5;
    NSTimer *timer;
    NSArray *ar_bannerList;
    UIViewController *webViewCtr;
    NSURLSessionDataTask *task;
    BOOL isThisViewShowInTheWindow;
}

@end

@implementation HDMainViewCtr

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTableHead];
    [self setTipCorner];
    HDBannerModel *model = [HDBannerModel new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationTapTabbarIndex:) name:HDNOTI_DID_TAP_TABBAR_INDEX object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated{
    HDNavigationBarHidden = YES;
    if ([HDHelper isTimeToRefresh:@"HDMainViewCtr"]) {
        [self httpGetStatistics];
        [self httpGetBanners];
        [self httpGetTips];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    isThisViewShowInTheWindow = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    HDNavigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    isThisViewShowInTheWindow = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    webViewCtr.title = title;
}

#pragma mark - UIScrollViewDelegate
#pragma mark --
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int i = pageControl.currentPage;
    if ([scrollView isEqual:tbv]) {
        CGFloat y = -tbv.contentOffset.y;
//        Dlog(@"y = %f", y);
        CGFloat safeHeight = isRetina5_8? 44: 20;
        if (y > safeHeight) {
            self.tabBarController.tabBar.hidden = NO;
            lc_scvTop.constant = -y + safeHeight;
            [self.view updateConstraints];
            [self.view layoutIfNeeded];     //告知页面布局立刻更新
            [scv setContentSize:CGSizeMake(HDDeviceSize.width * ar_bannerList.count, 0)];
            scv.contentOffset = CGPointMake(HDDeviceSize.width * i, 0);
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [timer invalidate];
    timer = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:5. target:self selector:@selector(scroll) userInfo:nil repeats:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([scrollView isEqual:tbv]) {
        return;
    }
    [timer invalidate];
    timer = nil;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:tbv]) {
        return;
    }
    int i = scv.contentOffset.x / HDDeviceSize.width;
    [pageControl setCurrentPage:i];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if ([scrollView isEqual:tbv]) {
        self.tabBarController.tabBar.hidden = NO;
        return;
    }
    int i = scv.contentOffset.x / HDDeviceSize.width;
    [pageControl setCurrentPage:i];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"HDTableViewCell";
    HDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HDTableViewCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

#pragma mark - event

- (void)httpGetStatistics{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:@"/index/statistics" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        NSDictionary *data = json;
        NSArray *ar_count = @[HDFORMAT(@"保养%@次", JSON(data[@"maintainCount"])),
                              HDFORMAT(@"事故%@次", JSON(data[@"accidentCount"])),
                              HDFORMAT(@"总违章%@次", JSON(data[@"peccancyCount"])),
                              HDFORMAT(@"总订单%@个", JSON(data[@"totalOrdersCount"])),
                              HDFORMAT(@"保险%@份", JSON(data[@"insuranceCount"]))];
        NSArray *ar_money = @[HDFORMAT(@"%@元", JSON(data[@"maintainMoney"])),
                              HDFORMAT(@"%@元", JSON(data[@"accidentMoney"])),
                              HDFORMAT(@"%@元", JSON(data[@"peccancyMoney"])),
                              HDFORMAT(@"%@元", JSON(data[@"totalOrdersMoney"])),
                              HDFORMAT(@"%@元", JSON(data[@"insuranceMoney"]))];
        NSString *assets = HDFORMAT(@"%@/%@", JSON(data[@"assetsUsed"]), JSON(data[@"assetsCount"]));
        [self setStatistics:@{@"count": ar_count,
                              @"money": ar_money,
                              @"assets": assets}];
    }];
}

- (void)httpGetBanners{
    HDHttpHelper *helper = [HDHttpHelper instance];
    helper.parameters = @{@"pageIndex": @"1", @"pageSize": @"5"};
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:@"/banner" object:[HDBannerModel new] finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        NSArray *content = json[@"content"];
        ar_bannerList = object;
        [self setBannerView:ar_bannerList];
    }];
}

- (void)httpGetTips{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:@"/index/tips" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        NSDictionary *data = json;
        NSArray *ar = @[JSON(data[@"rentNum"]), JSON(data[@"bargainNum"]), JSON(data[@"peccancyNum"]),
                        JSON(data[@"insuranceNum"]), JSON(data[@"yearlyNum"]), JSON(data[@"maintainNum"]),
                        JSON(data[@"taskNum"]), JSON(data[@"cardNum"]), JSON(data[@"driveNum"])
                        ];
        [self setTips:ar];
    }];
}
- (void)notificationTapTabbarIndex:(NSNotification *)noti{
    NSDictionary *userInfo = noti.userInfo;
    NSNumber *index = userInfo[@"index"];
    Dlog(@"index = %@", index);
    if (index.intValue == 0 && isThisViewShowInTheWindow) {
        [self httpGetStatistics];
        [self httpGetBanners];
        [self httpGetTips];
    }
}

- (IBAction)goTips:(UIButton *)sender{
    switch (sender.tag) {
        case 0:{//未付租金，订单
            HBFinancialCtr *ctr = [[HBFinancialCtr alloc] initWithStatus:@"未支付"];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            break;
        }
        case 1:{//合同，合同列表
            HDContractViewCtr *ctr = [[HDContractViewCtr alloc] initWithIsExpire:YES];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            break;
        }
        case 2:{//违章，车库管理列表
            HBGarageCtr *ctr = [[HBGarageCtr alloc] initWithScreenType:HDGarageScreenTypePeccancy];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            ctr.chooseCarBlock = ^(HDCarModel *carInfo) {
                HDCarDetailCtr *ctr = [[HDCarDetailCtr alloc] initWithCarId:carInfo.id];
                [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            };
            break;
        }
        case 3:{//保险，车库管理列表
            HBGarageCtr *ctr = [[HBGarageCtr alloc] initWithScreenType:HDGarageScreenTypeInsure];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            ctr.chooseCarBlock = ^(HDCarModel *carInfo) {
                HDCarDetailCtr *ctr = [[HDCarDetailCtr alloc] initWithCarId:carInfo.id];
                [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            };
            break;
        }
        case 4:{//年检，车库管理列表
            HBGarageCtr *ctr = [[HBGarageCtr alloc] initWithScreenType:HDGarageScreenTypeInspection];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            ctr.chooseCarBlock = ^(HDCarModel *carInfo) {
                HDCarDetailCtr *ctr = [[HDCarDetailCtr alloc] initWithCarId:carInfo.id];
                [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            };
            break;
        }
        case 5:{//保养，车库管理列表
            HBGarageCtr *ctr = [[HBGarageCtr alloc] initWithScreenType:HDGarageScreenTypeMaintain];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            ctr.chooseCarBlock = ^(HDCarModel *carInfo) {
                HDCarDetailCtr *ctr = [[HDCarDetailCtr alloc] initWithCarId:carInfo.id];
                [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            };
            break;
        }
        case 6:{//代办任务，任务列表
            HBTaskCtr *ctr = [[HBTaskCtr alloc] initWithTaskIsExpired:YES];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            break;
        }
        case 7:{//身份证，
            HBClientCtr *ctr = [[HBClientCtr alloc] initWithIdCardIsExpire:YES];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            break;
        }
        case 8:{//驾驶证
            HBClientCtr *ctr = [[HBClientCtr alloc] initWithDriveIsExpire:YES];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            break;
        }
        default:
            break;
    }
}

- (IBAction)goStatisticsLink:(UIButton *)sender {
    NSString *strCompanyId = HDGI.loginUser.companyId;
    switch (sender.tag) {
            case 0://保养
        {
            NSString *str = [[NSString alloc] initWithString:@"qureyMaintain"];
            HDCarportCtr *ctr = [[HDCarportCtr alloc] initWithCarType:str companyId:strCompanyId];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            break;
        }
            case 1://事故
        {
            NSString *str = [[NSString alloc] initWithString:@"qureyAccident"];
            HDCarportCtr *ctr = [[HDCarportCtr alloc] initWithCarType:str companyId:strCompanyId];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            break;
        }
            case 2://违章
        {
            NSString *str = [[NSString alloc] initWithString:@"qureyPeccancy"];
            HDCarportCtr *ctr = [[HDCarportCtr alloc] initWithCarType:str companyId:strCompanyId];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            break;
        }
            case 3:
        {
            HBFinancialCtr *ctr = [[HBFinancialCtr alloc] initWithStatus:@"已支付"];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            break;
        }
            case 4://保险
        {
            NSString *str = [[NSString alloc] initWithString:@"qureyInsurance"];
            HDCarportCtr *ctr = [[HDCarportCtr alloc] initWithCarType:str companyId:strCompanyId];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            
            break;
        }
            case 5:
        {
            HDCarportCtr *ctr = [[HDCarportCtr alloc] init];
            [self.tabBarController.navigationController pushViewController:ctr animated:YES];
            break;
        }
        default:
            break;
    }
}

- (void)scroll{
    int i = scv.contentOffset.x / HDDeviceSize.width;
    if (i == ar_bannerList.count - 1) {
        i = 0;
    }else{
        i = i + 1;
    }
    [scv setContentOffset:CGPointMake(HDDeviceSize.width * i, 0) animated:YES];
}

- (void)goBannerDetail:(UITapGestureRecognizer *)tap{
    UIView *v = tap.view;
    NSURL *url = nil;
    if (v.tag < ar_bannerList.count) {
        HDBannerModel *bannerModel = ar_bannerList[v.tag];
        if (bannerModel.url.length > 0) {
            url = [NSURL URLWithString:bannerModel.url];
        }else{
            url = [NSURL URLWithString:@"http://www.baidu.com"];
        }
    }
    if (url) {
        webViewCtr = [UIViewController new];
        UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        web.scalesPageToFit = YES;
        [webViewCtr.view addSubview:web];
        [web makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(webViewCtr.view);
            make.size.equalTo(webViewCtr.view);
        }];
        [web loadRequest:[NSURLRequest requestWithURL:url]];
        web.delegate = self;
        [self.tabBarController.navigationController pushViewController:webViewCtr animated:YES];
    }
}

#pragma mark - setter
- (void)setup{
    self.title = @"主页";
    lc_tbvTop.constant = isRetina5_8? -44.: -20.;
    [self.view updateConstraints];
}

- (void)setTableHead{
    CGFloat scvHeight = isRetina5_8? (150 + 44): (150 + 20);
    CGFloat height = HDDeviceSize.width * (181. / 374. + 222. / 380.) + scvHeight + 40.;
    CGRect frame = CGRectMake(0, 0, HDDeviceSize.width, height);
    UIView *v = [[UIView alloc] initWithFrame:frame];
    [v addSubview:vHead];
    [vHead makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(v);
        make.center.equalTo(v);
    }];
    tbv.tableHeaderView = v;
}

- (void)setBannerView:(NSArray *)ar{
    for (int i = 0; i < scv.subviews.count; i++) {
        UIView *v = scv.subviews[i];
        [v removeFromSuperview];
        i = 0;
    }
    CGFloat height = 137;
    pageControl.numberOfPages = ar.count;
    pageControl.hidesForSinglePage = YES;
    for (int i = 0; i < ar.count; i++) {
        HDBannerModel *m = ar[i];
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(HDDeviceSize.width * i, 0, HDDeviceSize.width, height)];
        if ([m.imgUrl isEqualToString:@"local"]) {//取写死本地的数据
            UIImage *img = isRetina5_8? HDIMAGE(@"adX"): HDIMAGE(@"ad");
            [imv setImage:img];
        }else{
            NSString *url = HDFORMAT(@"%@%@", IP, m.imgUrl);
            [imv setImageWithURL:[NSURL URLWithString:url]];
        }
        [imv setClipsToBounds:YES];
        [imv setContentMode:UIViewContentModeScaleAspectFill];
        imv.userInteractionEnabled = YES;
        imv.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBannerDetail:)];
        [imv addGestureRecognizer:tap];
        [scv addSubview:imv];
        [imv makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(scv).offset(HDDeviceSize.width * i);
            make.top.equalTo(scv);
            make.bottom.equalTo(scv);
            make.width.mas_equalTo(HDDeviceSize.width);
            make.height.equalTo(scv);
        }];
    }
    [self.view updateConstraints];
    scv.contentSize = CGSizeMake(HDDeviceSize.width * ar.count, 10.);
    [timer invalidate];
    timer = nil;
    timer = [NSTimer scheduledTimerWithTimeInterval:5. target:self selector:@selector(scroll) userInfo:nil repeats:YES];
}

- (void)setTipCorner{
    NSArray *ar = @[lb_remain0, lb_remain1, lb_remain2, lb_remain3, lb_remain4, lb_remain5, lb_remain6, lb_remain7, lb_remain8];
    for (int i = 0; i < ar.count; i++) {
        UILabel *lb = ar[i];
        lb.layer.cornerRadius    = 8.;
        lb.layer.masksToBounds   = YES;
    }
}
- (void)setTips:(NSArray *)ar_tips{
    NSArray *ar = @[lb_remain0, lb_remain1, lb_remain2, lb_remain3, lb_remain4, lb_remain5, lb_remain6, lb_remain7, lb_remain8];
    if (ar_tips.count < ar.count) {
        Dlog(@"Error:tips count is wrong!");
        return;
    }
    for (int i = 0; i < ar.count; i++) {
        UILabel *lb = ar[i];
        lb.layer.cornerRadius    = 8.;
        lb.layer.masksToBounds   = YES;
        NSString *tip = ar_tips[i];
        lb.text = tip;
    }
}

- (void)setStatistics:(NSDictionary *)dic{
    NSArray *ar_count   = dic[@"count"];
    NSArray *ar_money   = dic[@"money"];
    NSString *assets    = dic[@"assets"];
    if ([dic allKeys].count != 3 || ar_count.count != 5 || ar_money.count != 5) {
        Dlog(@"Error:statistic is wrong!");
        return;
    }
    NSArray *ar_prices = @[lb_price0, lb_price1, lb_price2, lb_price3, lb_price4];
    NSArray *ar_details = @[lb_detail0, lb_detail1, lb_detail2, lb_detail3, lb_detail4];
    for (int i = 0; i < 5; i++) {
        UILabel *lb_price = ar_prices[i];
        UILabel *lb_detail = ar_details[i];
        NSString *count = ar_count[i];
        NSString *money = ar_money[i];
        lb_price.text = money;
        NSRange range = [HDStringHelper searchNumberFromString:count];
        NSMutableAttributedString *mastr = [[NSMutableAttributedString alloc] initWithString:count];
        [mastr setAttributes:@{NSForegroundColorAttributeName: [UIColor redColor]} range:range];
        lb_detail.attributedText = mastr;
    }
    lb_price5.text = assets;
}
@end


@implementation HDBannerModel

@end









