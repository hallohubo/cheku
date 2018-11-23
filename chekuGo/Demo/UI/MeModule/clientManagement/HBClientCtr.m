//
//  HBContractCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/1/19.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBClientCtr.h"
#import "HBClientCell.h"
#import "HBClientDetailCtr.h"


@interface HBClientCtr () {
    IBOutlet UITextField    *tf_search;
    IBOutlet UIView *searchBack;
    IBOutlet UIView *headView;
    IBOutlet UITableView    *tbv;
    HDRefresh *refresh;
    NSURLSessionDataTask *task;
    NSMutableArray *mar_values;
    BOOL isIdCardExpire;
    BOOL isDriveExpire;
}

@end

@implementation HBClientCtr

- (id)initWithIdCardIsExpire:(BOOL)expire{
    if (self = [super init]) {
        isIdCardExpire = expire;
    }
    return self;
}

- (id)initWithDriveIsExpire:(BOOL)expire{
    if (self = [super init]) {
        isDriveExpire = expire;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setRightItem];
    [self setTableHeader];
    [self httpGetClients:1 keyWorld:@""];
    [refresh setHeadRefresh:tbv begin:^{
        [self httpGetClients:1 keyWorld:@""];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    NSString *keyWord = tf_search.text;
    if (keyWord.length == 0) {
        [HDHelper say:@"请输入搜索关键字"];
        return YES;
    }
    [self httpGetClients:1 keyWorld:keyWord];
    return YES;
}

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    HDClientModel *m = mar_values[indexPath.section];
    if (self.chooseClientBlock) {
        self.chooseClientBlock(m);
        return;
    }
    HBClientDetailCtr * ctr = [[HBClientDetailCtr alloc] initWithClientId:m.id];
    [self.navigationController pushViewController:ctr animated:YES];
    ctr.saveSucessBlock = ^{
        [self httpGetClients:1 keyWorld:tf_search.text];
    };
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 74;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 5.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5.;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return mar_values.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str1 = @"HBClientCell";
    HBClientCell *cell   = [tableView dequeueReusableCellWithIdentifier:str1];
    if(!cell){
        cell = [HBClientCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.contentView.layer.cornerRadius     = 6.;
        cell.contentView.layer.masksToBounds    = YES;
        cell.lb_phone.textColor = RGB(74, 148, 249);
    }
    HDClientModel *m = mar_values[indexPath.section];
    cell.lb_name.text = m.realname;
    cell.lb_phone.text = m.phone;
    cell.lb_contractCount.text = HDFORMAT(@"%d", m.bargainNum.intValue);
    return cell;
}

#pragma mark - event

- (void)httpGetClients:(int)index keyWorld:(NSString *)word{
    HDHttpHelper *helper = [HDHttpHelper instance];
    helper.parameters = @{@"pageIndex": @(index), @"pageSize": @"10", @"keyword": HDSTR(word)};
    if (isIdCardExpire) {
        [helper.parameters setValue:@"1" forKey:@"idcardIsExpire"];
    }
    if (isDriveExpire) {
        [helper.parameters setValue:@"1" forKey:@"driverIsExpire"];
    }
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:@"member" object:[HDClientModel new] finished:^(HDError *error, id object, BOOL isLast, id json) {
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
            [self httpGetClients:index + 1 keyWorld:word];
        }];
    }];
}

- (void)addClient:(UIButton *)sender{
    HBClientDetailCtr *ctr = [[HBClientDetailCtr alloc] init];
    [self.navigationController pushViewController:ctr animated:YES];
    ctr.saveSucessBlock = ^{
        [self httpGetClients:1 keyWorld:tf_search.text];
    };
}

#pragma setter

- (void)setup {
    self.title = @"客户管理";
    searchBack.layer.cornerRadius = 18.;
    searchBack.layer.masksToBounds = YES;
    refresh = [HDRefresh new];
}

- (void)setRightItem {
    if ([HDGI.loginUser.role isEqualToString:@"Main"]) {
        return;
    }
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addClient:)];
    [anotherButton setTintColor:RGB(74, 148, 249)];
    self.navigationItem.rightBarButtonItem  = anotherButton;
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

@implementation HDClientModel

@end
