//
//  HBBranchManageCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/1/26.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HBBranchManageCtr.h"
#import "HBBranchManageCell.h"
#import "HDCarportCtr.h"

@interface HBBranchManageCtr (){
    IBOutlet UITextField    *tf_search;
    IBOutlet UIView *searchBack;
    IBOutlet UIView *headView;
    IBOutlet UITableView    *tbv;
    NSURLSessionDataTask    *task;
    HBBranchModel           *model;
    NSMutableArray          *mar_values;
    HDRefresh               *refresh;
    HDHUD                   *hud;
}

@end

@implementation HBBranchManageCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTableHeader];
    [self httpGetPackageList:1 search:@""];
    [refresh setHeadRefresh:tbv begin:^{
        [self httpGetPackageList:1 search:@""];
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
    
    NSArray *ary = [HDGI.nav viewControllers];
    UIViewController *vc = ary[0];
    UITabBarController *tab = vc;
    if (tab){
        NSLog(@"I have a tab bar");
        [tab setSelectedIndex:1];
        [self.navigationController popToViewController:tab animated:NO];
        model = mar_values[indexPath.section];
        NSString *str = HDSTR(model.id);
        [[NSNotificationCenter defaultCenter] postNotificationName:HDNOTI_DID_TAP_TABBAR_INDEX object:nil userInfo:@{@"strCompanyId": str, @"index":@"1"}];
    }
    else{
        NSLog(@"I don't have");
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
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
    return mar_values.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"HBBranchManageCell";
    HBBranchManageCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HBBranchManageCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    model = mar_values[indexPath.section];
    cell.contentView.layer.cornerRadius = 10.f;
    cell.contentView.layer.masksToBounds = YES;
    cell.lbCompany.text     = model.companyName;
    cell.lbManName.text     = model.contactsName;
    cell.lbphoneNum.text    = model.contactsPhone;
    cell.lbMemberNum.text   = model.userNum;
    cell.lbAssetsNum.text   = HDFORMAT(@"%@/%@",model.assetsUsed,model.assetsCount);
    NSRange rang1 = [cell.lbAssetsNum.text rangeOfString:model.assetsUsed];
    [self changedLabel:cell.lbAssetsNum fontNumber:[UIFont systemFontOfSize:14.] andRange:rang1 andColor:HDCOLOR_ORANGE];
    return cell;
}

#pragma mark - UITextFieled delegate
#pragma mark

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    [self httpGetPackageList:1 search:tf_search.text ];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.placeholder = @"";
    textField.text  = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.placeholder = tf_search.text.length > 0? @"": @"🔍 请输入关键字搜索";
    [self httpGetPackageList:1 search:tf_search.text];
}


#pragma mark - event

- (void)httpGetPackageList:(int)index search:(NSString *)text {
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    [helper.parameters setValue:@(6).stringValue forKey:@"pageSize"];
    [helper.parameters setValue:@(index).stringValue forKey:@"pageIndex"];
    [helper.parameters setValue:HDSTR(text) forKey:@"keyword"];
    task = [helper getPath:@"company" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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
            HBBranchModel *model = [HDHttpHelper model:[HBBranchModel new] fromDictionary:d];
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

#pragma mark - setter

- (void)changedLabel:(UILabel *)lb fontNumber:(id)font andRange:(NSRange)range andColor:(UIColor *)col {
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:lb.text];
    [str addAttribute:NSFontAttributeName value:font range:range];
    [str addAttribute:NSForegroundColorAttributeName value:col range:range];
    lb.attributedText = str;
}


- (void)setup {
    self.title = @"分公司管理";
    refresh =  [HDRefresh new];
    searchBack.layer.cornerRadius = 18.;
    searchBack.layer.masksToBounds = YES;
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

@implementation HBBranchModel

@end


