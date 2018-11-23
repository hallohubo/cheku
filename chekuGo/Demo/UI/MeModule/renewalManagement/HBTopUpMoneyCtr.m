//
//  HBTopUpMoneyCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/2/3.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBTopUpMoneyCtr.h"
#import "HBRenewalCell.h"
#import "HBTopUpDetailCtr.h"
#import "HBRenewalTopUpCtr.h"
#import "HDRefresh.h"

@interface HBTopUpMoneyCtr () {
    IBOutlet UITableView    *tbv;
    IBOutlet UITextField    *tfSearch;
    NSURLSessionDataTask    *task;
    HDHUD                   *hud;
    HDRefresh               *refresh;
    NSMutableArray          *mar_values;
    HBChargeModel           *model;
}
@end

@implementation HBTopUpMoneyCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setRightItem];
    [self httpGetPackageList:1 search:tfSearch.text];
    [refresh setHeadRefresh:tbv begin:^{
        [self httpGetPackageList:1 search:nil];
    }];
    // Do any additional setup after loading the view from its nib.
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    model = mar_values[indexPath.section];
    HBTopUpDetailCtr *ctr = [[HBTopUpDetailCtr alloc] initWithTitle:model.id];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return mar_values.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"HBRenewalCell";
    HBRenewalCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HBRenewalCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    model = mar_values[indexPath.section];
    cell.contentView.layer.cornerRadius     = 6.;
    cell.contentView.layer.masksToBounds    = YES;
    cell.lbNumber.text  = model.id;;
    cell.lbAcount.text  = model.ordersMoney;
    cell.lbState.text   = model.payStatus;
    cell.lbName.text    = [model.payMethod isEqualToString:@"UnionPay"]? @"银行卡支付" : model.payMethod;//支付方式
    return cell;
}

#pragma mark UIScrollViewDelegate

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

#pragma mark - UITextFieled delegate
#pragma mark

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    [self httpGetPackageList:1 search:tfSearch.text];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.placeholder = @"";
    textField.text  = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.placeholder = tfSearch.text.length > 0? @"": @"🔍 请输入关键字搜索";
    [self httpGetPackageList:1 search:tfSearch.text];
}

#pragma mark - event
#pragma mark

- (void)httpGetPackageList:(int)index search:(NSString *)text{
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    [helper.parameters setValue:@(7).stringValue forKey:@"pageSize"];
    [helper.parameters setValue:@(index).stringValue forKey:@"pageIndex"];
    [helper.parameters setValue:HDSTR(text) forKey:@"keyword"];
    task = [helper getPath:@"company-renew" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [refresh finishReloadingData];
        [hud hiden];
        hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        NSArray *content = json[@"content"];
        int total   = [JSON(json[@"totalCount"]) intValue];
        NSMutableArray *mar = [NSMutableArray new];
        for (int i = 0; i < content.count; i++) {
            NSDictionary *d = content[i];
            HBChargeModel *model = [HDHttpHelper model:[HBChargeModel new] fromDictionary:d];
            if (model) {
                [mar addObject:model];
            }
        }
        if (index == 1) {
            mar_values = [[NSMutableArray alloc] initWithArray:mar];
        }else{
            [mar_values addObjectsFromArray:mar];
        }
        [tbv reloadData];
        isLast = mar_values.count >= total;
        [refresh setFootRefresh:tbv isLast:isLast begin:^{
            [self httpGetPackageList:index + 1 search:text];
        }];
    }];
}

- (IBAction)editCell:(id)sender {
    if ([@"Main" isEqualToString:HDGI.loginUser.role]) {
        HBRenewalTopUpCtr *ctr = [[HBRenewalTopUpCtr alloc] init];
        [ctr setBackBlock:^{
            [self httpGetPackageList:1 search:tfSearch.text];
        }];
        [self.navigationController pushViewController:ctr animated:YES];
    }else {
        [HDHelper say:@"需要主账户权限才能使用此功能!"];
    }
}

#pragma mark - setter

- (void)setup {
    self.title = @"续费记录";
    refresh = [HDRefresh new];
}

- (void)setRightItem {
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"充值" style:UIBarButtonItemStylePlain target:self action:@selector(editCell:)];
    [anotherButton setTintColor:HDCOLOR_DARKBLUE];
    self.navigationItem.rightBarButtonItem  = anotherButton;
}
@end
@implementation HBChargeModel
@end
