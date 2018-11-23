//
//  HDContractViewCtr.m
//  Demo
//
//  Created by hufan on 2018/2/1.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HDContractViewCtr.h"
#import "HBContractCell.h"
#import "HBContractDetailedCtr.h"

@interface HDContractViewCtr (){
    IBOutlet UITableView    *tbv;
    IBOutlet UITextField    *tfSearch;
    NSURLSessionDataTask    *task;
    HDHUD                   *hud;
    HDRefresh               *refresh;
    NSMutableArray          *mar_values;
    BOOL                    isExpire;
}

@end

@implementation HDContractViewCtr

- (id)initWithIsExpire:(BOOL)expire{
    if (self = [super init]) {
        isExpire = expire;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpGetPackageList:1 search:tfSearch.text expired:isExpire?@"1" : nil];
    [refresh setHeadRefresh:tbv begin:^{
        [self httpGetPackageList:1 search:tfSearch.text expired:isExpire?@"1" : nil];
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
    [self httpGetPackageList:1 search:tfSearch.text expired:isExpire?@"1" : nil];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.placeholder = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.placeholder = tfSearch.text.length > 0? @"": @"🔍 请输入关键字搜索";
    [self httpGetPackageList:1 search:tfSearch.text expired:isExpire?@"1" : nil];
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
    HBInformationModel *mode = mar_values[indexPath.section];
    HBContractDetailedCtr *ctr = [[HBContractDetailedCtr alloc] initWithString:mode.id];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
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
    return mar_values.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"HBContractCell";
    HBContractCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HBContractCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    HBInformationModel *model = mar_values[indexPath.section];
    cell.contentView.layer.cornerRadius     = 6.;
    cell.contentView.layer.masksToBounds    = YES;
    cell.lbMark.text = [model.bargainType hasPrefix:@"经"]? @"经租": @"融租";
    UIColor *color = [cell.lbMark.text isEqualToString:@"融租"]? HDCOLOR_ORANGE: HDCOLOR_DARKBLUE;
    UIColor *colorForBackgroun = [cell.lbMark.text isEqualToString:@"融租"]? HDCOLOR_ORANGEBACK: HDCOLOR_DARKBLUEBACK;
    cell.lbMark.textColor = color;
    cell.lbMark.layer.borderColor   = color.CGColor;
    cell.lbMark.backgroundColor     = colorForBackgroun;
    cell.lbName.text = model.signRealname;
    cell.lbContractTime.text = model.createTime;
    cell.lbContractNumber.text   = model.bargainNo;

    return cell;
}

#pragma mark - event

- (void)httpGetPackageList:(int)index search:(NSString *)text expired:(NSString *)IsExpired{
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
//    //helper.parameters = @{@"pageSize": @"10",
//                          @"pageIndex": @(index).stringValue,
//                          @"keyword": HDSTR(text),
//                          @"isExpire": HDFORMAT(@"%d", IsExpired)
//                          };//member-bargain?pageIndex=1
    //NSString *strNumber = HDFORMAT(@"%d",index);
    NSString *str = HDFORMAT(@"member-bargain?pageIndex=%@&pageSize=%@&keyword=%@&isExpire=%@",@(index).stringValue, @"10", HDSTR(text), HDSTR(IsExpired));
    task = [helper getPath:str object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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
            HBInformationModel *model = [HDHttpHelper model:[HBInformationModel new] fromDictionary:d];
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
            [self httpGetPackageList:index + 1 search:text expired:isExpire?@"1" : nil];
        }];
    }];
}


#pragma mark - setter
- (void)setup{
    self.title = @"合同管理";
    refresh = [HDRefresh new];
}

@end


@implementation HBInformationModel

@end
