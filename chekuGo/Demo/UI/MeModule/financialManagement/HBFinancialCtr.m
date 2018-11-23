//
//  HBFinancialCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/2/2.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HBFinancialCtr.h"
#import "HBFinancialtCell.h"
#import "HBFinancialDetailCtr.h"

@interface HBFinancialCtr (){
    IBOutlet UITableView    *tbv;
    IBOutlet UITextField    *tfSearch;
    NSURLSessionDataTask    *task;
    NSMutableArray          *marPackageList;
    HBFinancialtModel      *model;
    HDHUD                   *hud;
    HDRefresh               *refresh;
    NSString                *strStatus;//筛选用
    int                     sizeTotal;
    NSString                *orderStatus;//model中的订单状态，点cell时装用
    NSString                *strbargainId;
    BOOL                    *isHiddenAssociateBtn;
}

@end

@implementation HBFinancialCtr

- (id)initWithBargainId:(NSString *)bargainId {
    if (self = [super init]) {
        strbargainId = bargainId;
        isHiddenAssociateBtn = YES;
    }
    return self;
}

- (id)initWithStatus:(NSString *)status{
    if (self = [super init]) {
        strStatus = status;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setRightItem];
    [self httpGetPackageList:1  search:tfSearch.text statusChoose:strStatus];
    [refresh setHeadRefresh:tbv begin:^{
        [self httpGetPackageList:1  search:tfSearch.text statusChoose:strStatus];
    }];
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
    HBFinancialDetailCtr *ctr =  [[HBFinancialDetailCtr alloc] initWithOrderNo:model.id company:model.companyId showAssociatedBtn:isHiddenAssociateBtn];
    [ctr setCancelBlock:^{
        [self httpGetPackageList:1  search:tfSearch.text statusChoose:orderStatus];
    }];
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
    
    static NSString *str1    = @"HBFinancialtCell";
    HBFinancialtCell *cell   = [tableView dequeueReusableCellWithIdentifier:str1];
    if(!cell){
        cell = [HBFinancialtCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    model = marPackageList[indexPath.section];
    cell.contentView.layer.cornerRadius     = 6.;
    cell.contentView.layer.masksToBounds    = YES;
    cell.lbNumber.text   = model.id;
    cell.lbName.text     = model.memberRealname;
    cell.lbAcount.text   = model.ordersMoney;
    cell.lbState.text    = model.status;
    return cell;
}

#pragma mark - event
#pragma mark

- (IBAction)editCell:(id)sender {
    HDHelper *help = [HDHelper instance];
    [help showSheetWithTitle:@"筛选" first:@"已支付" seconed:@"未支付" third:@"已作废" showIn:self.view finished:^(UIActionSheet *sheet, int index) {
        switch (index) {
            case 0:{
                strStatus = @"已支付";
                break;
            }
            case 1:{
                strStatus = @"未支付";
                break;
            }
            case 2:{
                strStatus = @"已作废";
                break;
            }
            case 3:{
                strStatus = @"";
                break;
            }

            default:
                break;
        }
        [self httpGetPackageList:1 search:tfSearch.text statusChoose:strStatus];
    }];
}


- (void)httpGetPackageList:(int)index  search:(NSString *)text statusChoose:(NSString *)status{
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    [helper.parameters setValue:@(6).stringValue forKey:@"pageSize"];
    [helper.parameters setValue:@(index).stringValue forKey:@"pageIndex"];
    [helper.parameters setValue:HDSTR(text) forKey:@"keyword"];
    [helper.parameters setValue:HDSTR(status) forKey:@"status"];
    if (strbargainId.length > 1) {
    [helper.parameters setValue:HDSTR(strbargainId) forKey:@"bargainId"];
    }
    
    task = [helper getPath:@"member-rent-orders" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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
            HBFinancialtModel *model = [HDHttpHelper model:[HBFinancialtModel new] fromDictionary:d];
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
    textField.placeholder = tfSearch.text.length > 0? @"": @"🔍 请输入合同订单号搜索";

    [self httpGetPackageList:1 search:tfSearch.text statusChoose:strStatus];
}

#pragma setter

- (void)setRightItem {
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(editCell:)];
    [anotherButton setImage:HDIMAGE(@"screening")];
    self.navigationItem.rightBarButtonItem  = anotherButton;
}

- (void)setup {
    self.title = @"财务管理";
    refresh = [HDRefresh new];
}

@end
@implementation HBFinancialtModel



@end
