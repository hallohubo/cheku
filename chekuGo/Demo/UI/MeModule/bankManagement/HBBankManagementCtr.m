//
//  HBBankManagementCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/2/10.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBBankManagementCtr.h"
#import "HBBankManagementCell.h"
#import "HBEditBankCtr.h"

@interface HBBankManagementCtr () {
    IBOutlet UITableView    *tbv;
    IBOutlet UITextField    *tfSearch;
    NSURLSessionDataTask    *task;
    HDHUD                   *hud;
    HDRefresh               *refresh;
    NSMutableArray          *mar_values;
    HBBankManageModel       *model;
    UIBarButtonItem         *anotherButton;
    NSMutableArray          *marPackageList;
}

@end

@implementation HBBankManagementCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setRightItem];
    [self httpGetPackageList:1  search:tfSearch.text];
    [refresh setHeadRefresh:tbv begin:^{
        [self httpGetPackageList:1  search:tfSearch.text];
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

#pragma mark - UITextFieled delegate
#pragma mark

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.placeholder = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.placeholder = tfSearch.text.length > 0? @"": @"🔍 请输入关键字搜索";

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


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    model = marPackageList[indexPath.section];
    HBEditBankCtr *ctr = [[HBEditBankCtr alloc] initWithString:HDSTR(model.pkId)];
    [ctr setFinishUpBlock:^{
        [self httpGetPackageList:1 search:nil];
        [ctr.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5.;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([HDGI.loginUser.role isEqualToString:@"Main"]) {
        return  marPackageList.count > 0 ? marPackageList.count: 0;
    }else {
    model = marPackageList[0];
    return  (marPackageList.count > 0 && model.bankNo.length > 0) ? marPackageList.count: 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"HBBankManagementCell";
    HBBankManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HBBankManagementCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    model = marPackageList[indexPath.section];
    cell.layer.cornerRadius     = 10.f;
    cell.layer.masksToBounds    = YES;
    cell.lbCompany.text         = model.bankAccount;
    cell.lbBankName.text        = model.bankName;
    cell.lbBankCardNumber.text  = model.bankNo;
    return cell;
}


#pragma mark - event
- (void) httpGetPackageList:(int)index search:(NSString *)text {
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    [helper.parameters setValue:@(6).stringValue forKey:@"pageSize"];
    [helper.parameters setValue:@(index).stringValue forKey:@"pageIndex"];
    [helper.parameters setValue:HDSTR(tfSearch.text) forKey:@"keyword"];
    NSString *str = [HDGI.loginUser.role isEqualToString:@"Main"]? @"bank-data":@"my-bank-data";
    task = [helper getPath:str object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {//Main和最高管理者返回的数据格式不同
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
        NSMutableArray *mar = [NSMutableArray new];
        if (mar || mar.count > 0) {
            marPackageList = nil;
            model = nil;
        }
        int total = 0;
        
        if ([HDGI.loginUser.role isEqualToString:@"Main"]) {
            Dlog(@"userModel:%@",HDGI.loginUser);
            NSArray *content = json[@"content"];
            int number  = [HDDIC(json[@"pageSize"]) intValue];
            total   = [JSON(json[@"totalCount"]) intValue];
            for (int i = 0; i < content.count; i++) {
                NSDictionary *d = content[i];
                HBBankManageModel *model = [HDHttpHelper model:[HBBankManageModel new] fromDictionary:d];
                if (model) {
                    [mar addObject:model];
                }
            }
        }else {
            NSDictionary *d = json;
            model = [HDHttpHelper model:[HBBankManageModel new] fromDictionary:d];
            [mar addObject:model];
        }
        if (index == 1) {
            marPackageList = [[NSMutableArray alloc] initWithArray:mar];
        }else{
            [marPackageList addObjectsFromArray:mar];
        }
        if (marPackageList && marPackageList.count > 0) {
            model = marPackageList[0];
        }
        if (model && model.bankNo.length < 1 && [HDGI.loginUser.role isEqualToString:@"Filiale"]) {
            anotherButton.enabled = YES;
            anotherButton.title     = @"添加";
        }else{
            anotherButton.enabled = NO;
            anotherButton.title   = @"";
        }
        if (marPackageList.count > 0) {
            isLast = marPackageList.count < total? NO: YES;
        }else{
            isLast = YES;
        }
        [tbv reloadData];
        [refresh setFootRefresh:tbv isLast:isLast begin:^{
            [self httpGetPackageList:index + 1  search:text];
        }];
    }];
}

- (IBAction)editCell:(id)sender{
    if ([HDGI.loginUser.role isEqualToString:@"Filiale"]) {
        HBEditBankCtr *ctr = [[HBEditBankCtr alloc] init];
        [ctr setFinishUpBlock:^{
            [self httpGetPackageList:1 search:nil];
            [ctr.navigationController popViewControllerAnimated:YES];
        }];
        [self.navigationController pushViewController:ctr animated:YES];
    }else {
        [HDHelper say:@"需要最高管理者权限才能使用此功能！"];
    }
}

#pragma mark - setter

- (void)setRightItem {
    anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(editCell:)];
    [anotherButton setTintColor:HDCOLOR_DARKBLUE];
    self.navigationItem.rightBarButtonItem  = anotherButton;
    anotherButton.enabled = NO;
    anotherButton.title = @"";
}

- (void)setup {
    self.title = @"银行管理";
    refresh = [HDRefresh new];
}

@end


@implementation HBBankManageModel

@end
