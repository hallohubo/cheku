//
//  HDStepFourCtr.m
//  Demo
//
//  Created by hufan on 2018/2/10.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDStepFourCtr.h"
#import "HDAddCarDetailCell.h"
#import "HDClientSexCell.h"
#import "HDTableView.h"
#import "HDValidDateCell.h"
#import "HBFinancialDetailCtr.h"
#import "HDPayWayCell.h"

@interface HDStepFourCtr (){
    IBOutlet UITableView *tbv;
    NSURLSessionDataTask *task;
    HDHUD *hud;
    
    IBOutlet UIView *footView;
    IBOutlet UIButton *btn_complete;

    CGSize contentSize;
    UITextField *curTextFiled;
    HDBargainModel *bargainModel;
    HDClientModel *clientModel;
    int payWay;
}

@end

@implementation HDStepFourCtr

- (id)initWithBargainModel:(HDBargainModel *)bargain clientModel:(HDClientModel *)client{
    if (self = [super init]) {
        clientModel     = client;
        bargainModel    = bargain;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTitleView];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return 2;
    }
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (HDIndexPath(1, 1)) {
        static NSString *str = @"HDPayWayCell";
        HDPayWayCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [HDPayWayCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    
    if (HDIndexPath(0, 8)) {
        static NSString *str = @"HDValidDateCell";
        HDValidDateCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [HDValidDateCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.lb_title.text = @"合同日期";
        cell.tf_start.text  = bargainModel.startDate;
        cell.tf_end.text    = bargainModel.endDate;
        return cell;
    }
    static NSString *str = @"HDAddCarDetailCell";
    HDAddCarDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HDAddCarDetailCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.tf.userInteractionEnabled = NO;
    cell.tf.textColor = [UIColor blackColor];
    if (HDIndexPath(0, 6) || HDIndexPath(0, 7)) {
        cell.tf.textColor = [UIColor blueColor];
    }
    if (HDIndexPath(1, 0)) {
        cell.tf.textColor = RGB(251, 174, 55);
    }
    cell.lb_title.text = @[@[@"订单编号", @"签约人", @"身份证", @"合同类型", @"车牌号", @"品牌型号", @"押金", @"租金", @"合同日期"], @[@"订单总金额", @"支付方式"]][indexPath.section][indexPath.row];
    NSString *deposit = bargainModel.deposit;
    NSString *rent = bargainModel.rent;
    CGFloat totle = deposit.floatValue + rent.floatValue;
    [btn_complete setTitle:HDFORMAT(@"立即支付%0.f元", totle) forState:UIControlStateNormal];
    cell.tf.text = @[@[HDSTR(bargainModel.id), HDSTR(bargainModel.signRealname), HDSTR(bargainModel.signCardId), HDSTR(bargainModel.bargainType), HDSTR(bargainModel.vehicleNo), HDSTR(bargainModel.vehicleBrand), HDFORMAT(@"%@元", deposit), HDFORMAT(@"%@元", rent), HDSTR(@"")], @[HDFORMAT(@"%0.f元", totle), @"支付方式"]][indexPath.section][indexPath.row];
    return cell;
}

#pragma mark - event
- (void)httpPost{
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    NSDictionary *dic = @{@"driveDataRecord": HDSTR(@"")
                          };
    task = [helper postPath:@"" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
            }
            return ;
        }
    }];
}

- (IBAction)doNext:(id)sender{
    NSDate *start = [HDDateHelper dateWithString:bargainModel.startDate formate:@"yyyy-MM-dd"];
    NSDate *end = [HDDateHelper dateWithString:bargainModel.endDate formate:@"yyyy-MM-dd"];
    if ([start compare:end] == NSOrderedDescending) {
        [HDHelper say:@"起始时间不能大于结束时间"];
        return;
    }
    HBFinancialDetailCtr *ctr = [[HBFinancialDetailCtr alloc] initWithOrderNo:bargainModel.id company:nil showAssociatedBtn:NO];
    [HDGI.nav popToRootViewControllerAnimated:NO];
    [HDGI.nav pushViewController:ctr animated:YES];
}

#pragma mark - setter
- (void)setup{
    btn_complete.layer.cornerRadius = 5.;
    btn_complete.layer.masksToBounds = YES;
}
- (void)setTitleView{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width * 0.5, 44)];
    UILabel *lb_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    lb_title.textAlignment = NSTextAlignmentCenter;
    lb_title.font = [UIFont systemFontOfSize:17];
    lb_title.text = @"第四步";
    if (self.title.length > 0) {
        lb_title.text = self.title;
    }
    [v addSubview:lb_title];
    [lb_title makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(v);
        make.centerY.equalTo(v).offset(-10);
        make.size.mas_equalTo(CGSizeMake(60, 20));
    }];
    UILabel *lb_sub = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    lb_sub.textAlignment = NSTextAlignmentCenter;
    lb_sub.font = [UIFont systemFontOfSize:12];
    lb_sub.textColor = RGB(224., 70, 56);
    lb_sub.text = @"确认订单";
    [v addSubview:lb_sub];
    [lb_sub makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(v);
        make.centerY.equalTo(v).offset(10);
        make.size.mas_equalTo(CGSizeMake(180, 20));
    }];
    self.navigationItem.titleView = v;
}

- (void)setTableFooter{
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

