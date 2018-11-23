//
//  HBWithGetMoneyCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/2/7.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBWithGetMoneyCtr.h"
#import "HBWithdrawalRecordCell.h"
#import "HBWithdrawalDetailCtr.h"
#import "HBWithdrawalCtr.h"

@interface HBWithGetMoneyCtr () {
    IBOutlet UITableView    *tbv;
    IBOutlet UITextField    *tfSearch;
    HDRefresh               *refresh;
    HDHUD                   *hud;
    NSURLSessionDataTask    *task;
    HBWithdrawalRecordModel *model;
    NSMutableArray          *marPackageList;
    NSString                *strStatus;
}

@end

@implementation HBWithGetMoneyCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setRightItem];
    [self httpGetPackageList:1  search:tfSearch.text statusChoose:strStatus];
    [refresh setHeadRefresh:tbv begin:^{
        [self httpGetPackageList:1  search:tfSearch.text statusChoose:strStatus];
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    model = marPackageList[indexPath.section];
    HBWithdrawalDetailCtr *ctr = [[HBWithdrawalDetailCtr alloc] initWithCompanyId:model.id];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 94;
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
    return marPackageList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *str1    = @"HBWithdrawalRecordCell";
    HBWithdrawalRecordCell *cell   = [tableView dequeueReusableCellWithIdentifier:str1];
    if(!cell){
        cell = [HBWithdrawalRecordCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    model = marPackageList[indexPath.section];
    cell.contentView.layer.cornerRadius = 6.;
    cell.contentView.layer.masksToBounds = YES;
    //cell.lbOrderTime.text = model.companyName;
    cell.lbOrderTime.text   = model.createTime;
    cell.lbAcount.text  = model.widthdrawMoney;
    cell.lbOrderState.text   = model.status;
    cell.lbNumber.text  = model.id;
    [cell updateConstraints];
    
    return cell;
}

- (void)httpGetPackageList:(int)index  search:(NSString *)text statusChoose:(NSString *)status{
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    [helper.parameters setValue:@(6).stringValue forKey:@"pageSize"];
    [helper.parameters setValue:@(index).stringValue forKey:@"pageIndex"];
    [helper.parameters setValue:HDSTR(text) forKey:@"keyword"];
    [helper.parameters setValue:HDSTR(status) forKey:@"keyword"];

    task = [helper getPath:@"company-withdraw-cash" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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
        int number  = [HDDIC(json[@"pageSize"]) intValue];;
        int total   = [JSON(json[@"totalCount"]) intValue];
        NSMutableArray *mar = [NSMutableArray new];
        for (int i = 0; i < content.count; i++) {
            NSDictionary *d = content[i];
            HBWithdrawalRecordModel *model = [HDHttpHelper model:[HBWithdrawalRecordModel new] fromDictionary:d];
            if (model) {
                [mar addObject:model];
            }
        }
        if (index == 1) {
            marPackageList = [[NSMutableArray alloc] initWithArray:mar];
        }else{
            [marPackageList addObjectsFromArray:mar];
        }
        isLast = marPackageList.count < total? NO: YES;
        [tbv reloadData];
        [refresh setFootRefresh:tbv isLast:isLast begin:^{
            [self httpGetPackageList:index + 1  search:text statusChoose:strStatus];
        }];
    }];
}

#pragma mark - UITextFieled delegate
#pragma mark

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    [self httpGetPackageList:1 search:tfSearch.text statusChoose:strStatus];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.placeholder = @"";
    textField.text  = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.placeholder = tfSearch.text.length > 0? @"": @"🔍 请输入关键字搜索";
    [self httpGetPackageList:1 search:tfSearch.text statusChoose:strStatus];
}


#pragma mark - event

- (IBAction)editCell:(id)sender{
    if ([HDGI.loginUser.role isEqualToString:@"Filiale"]) {
        HBWithdrawalCtr *ctr = [[HBWithdrawalCtr alloc] init];
        [ctr setCancelBlock:^{
            [self httpGetPackageList:1  search:tfSearch.text statusChoose:strStatus];
        }];
        [self.navigationController pushViewController:ctr animated:YES];
    }else {
        [HDHelper say:@"需要管理者权限才能使用此功能！"];
       
    }
}

#pragma setter

- (void)setRightItem {
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"提现" style:UIBarButtonItemStylePlain target:self action:@selector(editCell:)];
    [anotherButton setTintColor:HDCOLOR_DARKBLUE];
    UIBarButtonItem *secondButton = [[UIBarButtonItem alloc]
                                     initWithTitle:@""
                                     style:UIBarButtonItemStyleBordered
                                     target:self
                                     action:@selector(AcionSecond:)];
    [secondButton setImage:HDIMAGE(@"screening")];
    self.navigationItem.rightBarButtonItems= [NSArray arrayWithObjects:secondButton,anotherButton,nil];
    
}

- (void)AcionSecond:(id)sender {
    HDHelper *help = [HDHelper instance];
    [help showSheetWithTitle:@"筛选" first:@"未处理" seconed:@"已处理"  showIn:self.view finished:^(UIActionSheet *sheet, int index) {
        switch (index) {
            case 0:{
                strStatus = @"未处理";
                break;
            }
            case 1:{
                strStatus = @"已处理";
                break;
            }
            case 2:{
                strStatus = @"";
                break;
            }
                
            default:
                break;
        }
        [self httpGetPackageList:1 search:tfSearch.text statusChoose:strStatus];
    }];
}


- (void)setup {
    self.title = @"提现管理";
    refresh = [HDRefresh new];
}
@end
@implementation HBWithdrawalRecordModel

@end
