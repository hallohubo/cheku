//
//  HBContractCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/1/19.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBTaskCtr.h"
#import "HBTaskCtrCell.h"
#import "HBTaskDetailCtr.h"


@interface HBTaskCtr () {
    IBOutlet UITableView    *tbv;
    IBOutlet UIView         *headView;
    IBOutlet UITextField    *tf_search;
    IBOutlet UIView *searchBack;
    NSURLSessionDataTask    *task;
    HBTaskModel             *model;
    NSMutableArray          *mar_values;
    HDRefresh               *refresh;
    HDHUD                   *hud;
    BOOL isComplete;
    BOOL isExpired;
}

@end

@implementation HBTaskCtr

- (id)initWithTaskStatus:(BOOL)complete{
    if (self = [super init]) {
        isComplete = complete;
    }
    return self;
}

- (id)initWithTaskIsExpired:(BOOL)isExpired {
    if (self = [super init]) {
        isExpired = isExpired;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTableHeader];
    [self httpGetPackageList:1 search:nil];
    [refresh setHeadRefresh:tbv begin:^{
        [self httpGetPackageList:1 search:nil];
    }];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    model = mar_values[indexPath.section];
    HBTaskDetailCtr *ctr = [[HBTaskDetailCtr alloc] initWithString:model.id];
    [ctr setHBCancelBlock:^ {
        [self httpGetPackageList:1 search:nil];
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
    return mar_values.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *str1   = @"HBTaskCtrCell";
    HBTaskCtrCell *cell     = [tableView dequeueReusableCellWithIdentifier:str1];
    if(!cell){
        cell = [HBTaskCtrCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    model = mar_values[indexPath.section];
    cell.contentView.layer.cornerRadius     = 6.;
    cell.contentView.layer.masksToBounds    = YES;
    cell.lbMark.textColor                   = HDCOLOR_ORANGE;
    cell.lbMark.layer.borderColor           = HDCOLOR_ORANGE.CGColor;
    cell.lbMark.backgroundColor             = HDCOLOR_ORANGEBACK;
    cell.lbTaskName.text                    = model.taskTitle;
    cell.lbTaskTime.text                    = model.lastModifyTime;
    cell.lbtaskIsFinish.text                = model.taskStatus;
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
    helper.parameters = @{@"pageSize": @"10",
                          @"pageIndex": @(index).stringValue,
                          @"keyword": HDSTR(text)
                          };
    if (isComplete) {
       [helper.parameters setValue:HDFORMAT(@"%d", isComplete) forKey:@"taskStatus"];
    }
    if (isExpired) {
        [helper.parameters setValue:@"1" forKey:@"taskIsExpire"];
    }
    task = [helper getPath:@"company-task" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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
            HBTaskModel *model = [HDHttpHelper model:[HBTaskModel new] fromDictionary:d];
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


#pragma setter

- (void)setup {
    self.title = @"任务管理";
    refresh = [HDRefresh new];
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

@implementation HBTaskModel

@end


