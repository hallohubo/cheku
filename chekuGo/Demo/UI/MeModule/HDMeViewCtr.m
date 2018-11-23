//
//  HDMeViewCtr.m
//  Demo
//
//  Created by hufan on 2017/2/28.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import "HDMeViewCtr.h"
#import "HDLoginViewCtr.h"
#import "HBFinancialCtr.h"
#import "HBTopUpMoneyCtr.h"
#import "HBWithGetMoneyCtr.h"
#import "HBBranchManageCtr.h"
#import "HBTaskCtr.h"
#import "HBGarageCtr.h"
#import "HBClientCtr.h"
#import "HDContractViewCtr.h"
#import "HBMeCell.h"
#import "HBBankManagementCtr.h"
#import "HBChangePasswordCtr.h"
#import "HDStepThreeCtr.h"

//定义cell标题
#define titleForMain @[@[@"分公司管理", @"任务管理", @"车库管理", @"客户管理"], @[@"合同管理", @"财务管理"], @[@"续费管理", @"提现管理", @"银行管理"]]
#define titleForFiliale @[@[@"任务管理", @"车库管理", @"客户管理"], @[@"合同管理", @"财务管理"], @[@"提现管理", @"银行管理"]]

#define titleForVehicle     @[@[@"车库管理"]]
#define titleForFinance     @[@[@"任务管理", @"财务管理", @"银行管理"]]
#define titleForExecutor    @[@[@"任务管理", @"客户管理", @"财务管理",@"车库管理"], @[@"合同管理", @"银行管理"]]
//定义cell图片
#define imageForMain @[@[@"branchManagement", @"taskManagement", @"garageManagement", @"clientManagement"], @[@"contract", @"financial"], @[@"renewal", @"withdrawal", @"bankMe"]]
#define imageForFiliale @[@[@"taskManagement", @"garageManagement", @"clientManagement"], @[@"contract", @"financial"], @[@"withdrawal", @"bankMe"]]
#define imageForVehicle     @[@[@"garageManagement"]]
#define imageForFinance     @[@[@"taskManagement", @"financial", @"bankMe"]]
#define imageForExecutor    @[@[@"taskManagement", @"clientManagement", @"financial", @"garageManagement"], @[@"contract", @"bankMe"]]
//
@interface HDMeViewCtr () {
    IBOutlet UIView             *vhead;
    IBOutlet UIView             *vBottom;
    IBOutlet UIImageView        *imvPhoto;
    IBOutlet UILabel            *lbAccount;
    IBOutlet UILabel            *lbRole;
    IBOutlet UIButton           *btnModifyPassword;
    IBOutlet UIButton           *btnBranchManagement;
    IBOutlet UIButton           *btnTaskManagement;
    IBOutlet UIButton           *btnGarageManagement;
    IBOutlet UIButton           *btnCustomerManagement;
    IBOutlet UILabel            *lbBranchAmount;
    IBOutlet UILabel            *lbTaskAmount;
    IBOutlet UILabel            *lbGarageAmount;
    IBOutlet UILabel            *lbCustomerAmount;
    IBOutlet UITableView        *tbv;
    IBOutlet NSLayoutConstraint *lcTop;
    IBOutlet UIButton           *btnLonginOut;
    BOOL                        *isHiddenForCell;
    NSMutableArray              *marForTitle;
    NSMutableArray              *marForImage;
    NSMutableArray              *marForRightTitle;
    NSURLSessionDataTask        *task;
    HDHUD                       *hud;
   
}

@end

@implementation HDMeViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTitleForInitial];
    [self setNavigationBarStyle];
    [self setNavigationbarAppearence];
    [self httpGetManageInformation];
}

- (void)viewWillAppear:(BOOL)animated{
    HDNavigationBarHidden = YES;
    [self httpGetManageInformation];
}

- (void)viewWillDisappear:(BOOL)animated{
    HDNavigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollviewDelegate
#pragma mark -

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([scrollView isEqual:tbv]) {
        CGFloat y = -tbv.contentOffset.y;
        if (y > 0) {
            lcTop.constant = -y;
            [self.view updateConstraints];
        }
    }
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *s = ((HBMeCell *)[tableView cellForRowAtIndexPath:indexPath]).lbTitle.text;
    if ([s isEqualToString:@"分公司管理"]) {
        [self.tabBarController.navigationController pushViewController:[HBBranchManageCtr new] animated:YES];
    }
    if ([s isEqualToString:@"任务管理"]) {
        [self.tabBarController.navigationController pushViewController:[HBTaskCtr new] animated:YES];
    }
    if ([s isEqualToString:@"车库管理"]) {
        [self.tabBarController.navigationController pushViewController:[HBGarageCtr new] animated:YES];
    }
    if ([s isEqualToString:@"客户管理"]) {
        [self.tabBarController.navigationController pushViewController:[HBClientCtr new] animated:YES];
    }
    if ([s isEqualToString:@"合同管理"]) {
        [self.tabBarController.navigationController pushViewController:[HDContractViewCtr new] animated:YES];
    }
    if ([s isEqualToString:@"财务管理"]) {
        [self.tabBarController.navigationController pushViewController:[HBFinancialCtr new] animated:YES];
    }
    if ([s isEqualToString:@"续费管理"]) {
        [self.tabBarController.navigationController pushViewController:[HBTopUpMoneyCtr new] animated:YES];
    }
    if ([s isEqualToString:@"提现管理"]) {
        [self.tabBarController.navigationController pushViewController:[HBWithGetMoneyCtr new] animated:YES];
    }
    if ([s isEqualToString:@"银行管理"]) {
        [self.tabBarController.navigationController pushViewController:[HBBankManagementCtr new] animated:YES];//HDStepThreeCtr  HBBankManagementCtr
    }


}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5.;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return marForTitle.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *ar = marForTitle[section];
    return ar.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *str1   = @"HBMeCell";
    HBMeCell *cell   = [tableView dequeueReusableCellWithIdentifier:str1];
    if(!cell){
        cell = [HBMeCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.lbTitle.text     = marForTitle[indexPath.section][indexPath.row];
    cell.imvHead.image    = HDIMAGE(marForImage[indexPath.section][indexPath.row]);
    if (marForRightTitle && marForRightTitle.count > 0) {
        [cell.btn setTitle:marForRightTitle[indexPath.section][indexPath.row] forState:UIControlStateNormal];
        
    }
    NSString *str = HDGI.loginUser.role;
    return cell;
}

#pragma mark - event

- (void)httpGetManageInformation {
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    task = [helper getPath:@"my/manage-info" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        NSDictionary *mar = json;
        if (mar && mar.count == 4) {
            NSString *strFiliale = HDFORMAT((@"%@个"),   mar[@"filialeNum"]);
            NSString *strMember  = HDFORMAT((@"%@个"),   mar[@"memberNum"]);
            NSString *strTask    = HDFORMAT((@"%@个"),   mar[@"taskNum"]);
            NSString *strVehicle = HDFORMAT((@"%@个"),   mar[@"vehicleNum"]);

            if ([HDGI.loginUser.role isEqualToString:@"Main"]) {
                marForRightTitle = [[NSMutableArray alloc] initWithObjects:@[strFiliale,strTask,strVehicle,strMember],@[@"", @""],@[@"", @"", @""], nil];
            }else if ([HDGI.loginUser.role isEqualToString:@"Filiale"]){
                marForRightTitle = [[NSMutableArray alloc] initWithObjects:@[strTask,strVehicle,strMember],@[@"", @""],@[@"", @""], nil];

            }else if ([HDGI.loginUser.role isEqualToString:@"Vehicle"]){
                marForRightTitle = [[NSMutableArray alloc] initWithObjects:@[strVehicle], nil];
                
            }else if ([HDGI.loginUser.role isEqualToString:@"Finance"]){
                marForRightTitle = [[NSMutableArray alloc] initWithObjects:@[strTask, @"", @""],nil];
            }else if ([HDGI.loginUser.role isEqualToString:@"Executor"]){
                marForRightTitle = [[NSMutableArray alloc] initWithObjects:@[strTask, strMember, @"", strVehicle],@[@"", @""], nil];
            }
        }
        
        [tbv reloadData];
    }];
    
}

- (IBAction)changePassword:(id)sender {
    [self.tabBarController.navigationController pushViewController:[HBChangePasswordCtr new] animated:YES];
}

- (IBAction)btnLoginOut:(UIButton *)sender {
    HDHelper *help  = [HDHelper instance];
    [help say:@"确定退出吗？" confirm:@"确定" cancel:@"取消" finished:^(UIAlertView *alertView, int index) {
        Dlog(@"resultIndex = %d", index);
        if (index == 1) {
            HDLoginViewCtr *ctr = [HDLoginViewCtr new];
            [HDGI.nav presentViewController:ctr animated:YES completion:^{
                [HDLoginUserModel clearFromLocal];
                [HDAppHelper clearTokenFromLocal];
                [HDHelper clearTimeToRefreshFlag:nil];
                HDGI.loginUser  = nil;
                HDGI.token      = nil;
                HDGI.nav        = nil;
            }];
        }
        return ;
    }];

}

#pragma setter

- (void)setNavigationBarStyle {
    [self.navigationController.navigationBar setBackgroundImage:HDIMAGE(@"theme") forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:14.0f], NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:dic];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)setNavigationbarAppearence{
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]  forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [UIColor whiteColor], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:14.0f], NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:dic];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

- (void)setup {
    self.title = @"我的";
    vhead.frame = CGRectMake(0, 0, HDDeviceSize.width, 120.);
    vhead.backgroundColor = [UIColor colorWithPatternImage:HDIMAGE(@"theme")];
    [tbv setTableHeaderView:vhead];
    imvPhoto.layer.cornerRadius             = 40.f;
    imvPhoto.layer.masksToBounds            = YES;
    btnModifyPassword.layer.cornerRadius    = 13.f;
    btnModifyPassword.layer.masksToBounds   = YES;
    vBottom.frame = CGRectMake(0, 0, HDDeviceSize.width, 55);
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 70)];
    [v addSubview:vBottom];
    [vBottom makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(v);
        make.center.equalTo(v);
    }];
    tbv.tableFooterView = v;
    lbRole.text = HDGI.loginUser.realname;
    lbAccount.text = HDGI.loginUser.username;
}

-(void)setTitleForInitial {
    NSString *strHDGI = HDGI.loginUser.role;
    //NSString *strHDGI = @"Filiale";
    if ([strHDGI isEqualToString:@"Main"]) {
        marForTitle = titleForMain;
        marForImage = imageForMain;
    }else if ([strHDGI isEqualToString:@"Vehicle"]){
        marForTitle = titleForVehicle;
        marForImage = imageForVehicle;
    }else if ([strHDGI isEqualToString:@"Finance"]){
        marForTitle = titleForFinance;
        marForImage = imageForFinance;
    }else if ([strHDGI isEqualToString:@"Executor"]){
        marForTitle = titleForExecutor;
        marForImage = imageForExecutor;
    }else {
        marForTitle = titleForFiliale;
        marForImage = imageForFiliale;
    }
}

@end
