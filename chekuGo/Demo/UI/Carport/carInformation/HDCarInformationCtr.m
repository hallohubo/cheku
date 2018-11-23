//
//  HDCarInformationCtr.m
//  Demo
//
//  Created by hufan on 2018/1/29.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDCarInformationCtr.h"
#import "HDCarInfoMainCell.h"
#import "HDCarInfoByworkCell.h"

#define AR_MAININFORMATION @[@[JSON(json[@"vehicleBrand"]), JSON(json[@"vehicleModel"]), JSON(json[@"vehicleVin"]),JSON(json[@"dateIssued"])], @[JSON(json[@"vehicleNumber"]), JSON(json[@"address"]), JSON(json[@"engineNumber"]), @""], @[JSON(json[@"own"]), JSON(json[@"basicProperties"]), JSON(json[@"createTime"]), @""]]

#define AR_BYWORK @[JSON(json[@"vehicleNumber"]), JSON(json[@"archivesNumber"]), JSON(json[@"personsInCab"]),JSON(json[@"vehicleWeight"]), JSON(json[@"curbWeight"]), JSON(json[@"ratedPayload"]), JSON(json[@"overallDimensions"]), JSON(json[@"tractionMass"]), JSON(json[@"note"]), JSON(json[@"checkLog"])]

@interface HDCarInformationCtr (){
    IBOutlet UITableView *tbv;
    NSURLSessionDataTask *task;
    HDHUD *hud;
    IBOutlet UIView *headView;
    IBOutlet UIView *footerView;
    IBOutlet HD3DScrollView *scv_banner;
    IBOutlet HD3DScrollView *scv_licenc;
    IBOutlet UILabel *lb_title;
    IBOutlet UILabel *lb_carNumber;
    IBOutlet UIButton *btn_used;
    NSString *carIdetifier;
    NSDictionary *dic_car;
    NSArray *ar_banner;
    NSArray *ar_mainInfo;
    NSArray *ar_byworkInfo;
    NSTimer *timer;
}

@end

@implementation HDCarInformationCtr

- (id)initWithCarId:(NSString *)carId{
    if (self = [super init]) {
        carIdetifier = carId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTableView];
    [self setFooterView];
    [self httpGetCarDetail];
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

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if ([scrollView isEqual:scv_banner]) {
        if (scv_banner.currentPage == ar_banner.count + 1) {
            [scv_banner loadPageIndex:1 animated:NO];
        }
        if (scv_banner.currentPage == 0) {
            [scv_banner loadPageIndex:ar_banner.count animated:NO];
        }
        return;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:scv_banner]) {
        if (scv_banner.currentPage == ar_banner.count + 1) {
            [scv_banner loadPageIndex:1 animated:NO];
        }
        if (scv_banner.currentPage == 0) {
            [scv_banner loadPageIndex:ar_banner.count animated:NO];
        }
        [self setAutoScrollStart];
        return;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    Dlog(@"123123123");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 87;
    }
    return 55;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 10;
    }
    if (section == 0) {
        return 4;
    }
    return 0;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 50)];
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 20)];
    line.backgroundColor = RGBCOLOR(226, 75, 59);
    [v addSubview:line];
    [line makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(v).offset(10);
        make.size.mas_equalTo(CGSizeMake(4, 16));
        make.centerY.equalTo(v);
    }];
    UILabel *lb_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
    lb_title.font = HDFONT;
    lb_title.textColor = RGBCOLOR(102, 102, 102);
    lb_title.text = @[@"主页信息", @"副业信息", @"行驶证照片"][section];
    [v addSubview:lb_title];
    [lb_title makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(line.right).offset(8);
        make.size.mas_equalTo(CGSizeMake(120, 20));
        make.centerY.equalTo(v);
    }];
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *str = @"HDCarInfoMainCell";
        HDCarInfoMainCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [HDCarInfoMainCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.lb_title0.text = @[@"品牌型号", @"车辆类型", @"车辆识别代码", @"发证日期"][indexPath.row];
        cell.lb_title1.text = @[@"车牌", @"住址", @"发动机号码", @""][indexPath.row];
        cell.lb_title2.text = @[@"所有人", @"使用性质", @"注册日期", @""][indexPath.row];
        NSArray *ar_desc0 = ar_mainInfo[0];
        NSArray *ar_desc1 = ar_mainInfo[1];
        NSArray *ar_desc2 = ar_mainInfo[2];
        cell.lb_desc0.text = ar_desc0[indexPath.row];
        cell.lb_desc1.text = ar_desc1[indexPath.row];
        cell.lb_desc2.text = ar_desc2[indexPath.row];
        cell.v1.hidden = indexPath.row == 3;
        cell.v2.hidden = indexPath.row == 3;
        return cell;
    }
    if (indexPath.section == 1) {
        static NSString *str = @"HDCarInfoByworkCell";
        HDCarInfoByworkCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [HDCarInfoByworkCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.lb_title.text = @[@"号牌号码", @"档案编号", @"核定载人数",
                               @"总质量", @"整备质量", @"核定质量",
                               @"外廓尺寸", @"准牵引总质量", @"备注",
                               @"检验记录"
                               ][indexPath.row];
        cell.lb_detail.text = ar_byworkInfo[indexPath.row];
        return cell;
    }
    return nil;
}

#pragma mark - event
- (void)httpGetCarDetail{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:HDFORMAT(@"/vehicle/%@", carIdetifier) object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        dic_car = json;
        ar_mainInfo = @[@[JSON(json[@"vehicleBrand"]), JSON(json[@"vehicleModel"]), JSON(json[@"vehicleVin"]),JSON(json[@"dateIssued"])],
                        @[JSON(json[@"vehicleNumber"]), JSON(json[@"address"]), JSON(json[@"engineNumber"]), @""],
                        @[JSON(json[@"own"]), JSON(json[@"basicProperties"]), JSON(json[@"createTime"]), @""]];
        
        ar_byworkInfo = @[JSON(json[@"vehicleNumber"]), JSON(json[@"archivesNumber"]), JSON(json[@"personsInCab"]),
                          JSON(json[@"vehicleWeight"]), JSON(json[@"curbWeight"]), JSON(json[@"ratedPayload"]),
                          JSON(json[@"overallDimensions"]), JSON(json[@"tractionMass"]), JSON(json[@"note"]),
                          JSON(json[@"checkLog"])
                          ];
        HDGI.carBrand = JSON(json[@"vehicleBrand"]);
        HDGI.carNumber = JSON(json[@"vehicleNumber"]);
        NSArray *ar_banners = [self getBannerUrls];
        NSArray *ar_licences = [self getLicenceUrls];
        ar_banner = ar_banners;
        [self setHeadData:ar_banner];
        [tbv reloadData];
        [self setFooterData:ar_licences];
    }];
}

- (IBAction)doLoadNextBanner:(UIButton *)sender{
    if (sender.tag == 0) {
        [scv_banner loadNextPage:YES];
    }else{
        [scv_banner loadPreviousPage:YES];
    }
}

- (IBAction)doLoadNextLicence:(UIButton *)sender{
    if (sender.tag == 0) {
        [scv_licenc loadNextPage:YES];
    }else{
        [scv_licenc loadPreviousPage:YES];
    }
}

#pragma mark - setter and getter
- (void)setup{
    self.title = @"";

}

- (NSArray *)getBannerUrls{
    NSArray *ar_banner = [JSON(dic_car[@"banner"]) componentsSeparatedByString:@","];
    NSMutableArray *mar = [NSMutableArray new];
    for (int i = 0; i < ar_banner.count; i++) {
        NSString *s = ar_banner[i];
        s = HDFORMAT(@"%@/app/%@", IP, s);
        [mar addObject:s];
    }
    return mar;
}

- (NSArray *)getLicenceUrls{
    NSString *licence0 = JSON(dic_car[@"vehicleTravelLicenseFront"]);
    NSString *licence1 = JSON(dic_car[@"vehicleTravelLicenseBack"]);
    NSString *UrlLicence0 = HDFORMAT(@"%@/app/%@", IP, licence0);
    NSString *UrlLicence1 = HDFORMAT(@"%@/app/%@", IP, licence1);
    return @[UrlLicence0, UrlLicence1];
}

- (void)setHeadData:(NSArray *)ar{
    if (ar.count == 0) {
        Dlog(@"Error:Banner count is 0!");
        return;
    }
    NSMutableArray *mar = [[NSMutableArray alloc] initWithArray:ar];
    [mar insertObject:[ar lastObject] atIndex:0];
    [mar addObject:[ar firstObject]];
    for (int i = 0; i < mar.count; i++) {
        NSString *s = mar[i];
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake((HDDeviceSize.width - 40) * i, 0, HDDeviceSize.width - 40, (HDDeviceSize.width - 40) * 192./340.)];
        [imv setImageWithURL:[NSURL URLWithString:s]];
        imv.contentMode     = UIViewContentModeScaleAspectFill;
        imv.clipsToBounds   = YES;
        imv.layer.cornerRadius  = 5.;
        imv.layer.masksToBounds = YES;
        [scv_banner addSubview:imv];
    }
    scv_banner.effect = HD3DScrollViewEffectNone;
    scv_banner.contentSize = CGSizeMake((HDDeviceSize.width - 40) * mar.count, 10);
    scv_banner.pagingEnabled = YES;
    [scv_banner loadPageIndex:1 animated:NO];
    [self setAutoScrollStart];
    //赋值其他label
    lb_title.text = JSON(dic_car[@"vehicleBrand"]);
    lb_carNumber.text = JSON(dic_car[@"vehicleNumber"]);
    NSString *str = JSON(dic_car[@"status"]);
    if (self.usingStateBlock) {
        self.usingStateBlock(str);
    }
    UIImage *img = [str isEqualToString:@"忙碌"] ? HDIMAGE(@"car_used"): HDIMAGE(@"car_unused");
    [btn_used setBackgroundImage:img forState:UIControlStateNormal];
}
      
- (void)setAutoScrollStart{
  if (timer) {
      [timer invalidate];
      timer = nil;
  }
  timer = [NSTimer scheduledTimerWithTimeInterval:5. target:self selector:@selector(bannerScroll) userInfo:nil repeats:YES];
}

- (void)bannerScroll{
    [scv_banner loadNextPage:YES];
}

- (void)setFooterData:(NSArray *)ar{
    for (int i = 0; i < ar.count; i++) {
        NSString *s = ar[i];
        UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake((HDDeviceSize.width - 40) * i, 0, HDDeviceSize.width - 40, (HDDeviceSize.width - 40) * 192./340.)];
        [imv setImageWithURL:[NSURL URLWithString:s]];
        imv.contentMode     = UIViewContentModeScaleAspectFill;
        imv.clipsToBounds   = YES;
        imv.layer.cornerRadius  = 5.;
        imv.layer.masksToBounds = YES;
        [scv_licenc addSubview:imv];
    }
    scv_licenc.effect = HD3DScrollViewEffectNone;
    scv_licenc.contentSize = CGSizeMake((HDDeviceSize.width - 40) * ar.count, 10);
    scv_licenc.pagingEnabled = YES;
}
- (void)setTableView{
    CGFloat height = HDDeviceSize.width * 192. / 340. + 20 * 2 + 18 * 3;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, height)];
    [v addSubview:headView];
    [headView makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(v);
        make.size.equalTo(v);
    }];
    tbv.tableHeaderView = v;
}

- (void)setFooterView{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, HDDeviceSize.width * 192. / 340. + 36)];
    [v addSubview:footerView];
    [footerView makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(v);
        make.size.equalTo(v);
    }];
    tbv.tableFooterView = v;
}

@end
