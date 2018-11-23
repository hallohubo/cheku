//
//  HBTaskDetailCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/1/26.
//Copyright © 2018年 hufan. All rights reserved.
//

#import "HBTaskDetailCtr.h"
#import "HBReviewStatusCell.h"
#import "HBTaskDetailCell.h"
#import "HBModifyMyInformationCtr.h"

#define cellTitle @[@"发起人",@"任务标题",@"指派人",@"开始时间",@"预计时间",@"审核人",@"任务状态",@"完成时间",@"详细描述"]

@interface HBTaskDetailCtr ()<UITextFieldDelegate>{
    IBOutlet NSLayoutConstraint *lcLeftConstraint;
    IBOutlet NSLayoutConstraint *lcTop;
    IBOutlet UIButton           *btnDetailDescribtion;
    IBOutlet UIButton           *btnReviewStatus;
    IBOutlet UIButton           *btnReviewApproved;
    IBOutlet UIButton           *btnReviewFailure;
    IBOutlet UIButton           *btnAchieveTask;
    IBOutlet UIView             *vTaskDetail;
    IBOutlet UIView             *vShort;
    IBOutlet UITableView        *tbv;
    IBOutlet NSLayoutConstraint *lcBottomViewHeight;
    NSURLSessionDataTask        *task;
    BOOL                        IsChange;
    HDHUD                       *hud;
    NSString                    *strId;                //公司Id
    HBTaskDetailModel           *detailModel;
    HBTaskReviewModel           *reviewModel;
    NSMutableArray              *marReview;
    UITextField                 *tfDescript;
    NSString                    *strExecuteDescription;//执行者描述
    NSString                    *strExamineDescription;//审核结果描述
    NSString                    *strExamineResult;//审核结果标识，只有success和fail
    HDRefresh                   *refresh;
}

@end

@implementation HBTaskDetailCtr

- (instancetype)initWithString:(NSString *)str {
    if (self = [super init]) {
        strId = str;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self getTaskDescriptHttp];
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

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!IsChange) {
        return vTaskDetail;
    }
    return nil;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *str0 = [[NSString alloc] init];
    NSString *str1 = [[NSString alloc] init];
    for (UITableViewCell *cell in [tableView visibleCells]) {
        if ([cell.reuseIdentifier isEqualToString:@"HBReviewStatusCell"]) {
            str1 = ((HBReviewStatusCell *)[tableView cellForRowAtIndexPath:indexPath]).lbHead3.text;
        }
        if ([cell.reuseIdentifier isEqualToString:@"HBTaskDetailCell"]) {
            str0 = ((HBTaskDetailCell *)[tableView cellForRowAtIndexPath:indexPath]).lbLeft.text;        }
    }
    if ([str1 isEqualToString:@"未完成"]) {//&&  btnReviewApproved.hidden == NO
        NSString *str_ =  ((HBReviewStatusCell *)[tableView cellForRowAtIndexPath:indexPath]).lbHead4.text;
        BOOL isEdited = !btnReviewApproved.hidden;//判断是否该隐藏HBModifyMyInformationCtr的保存按钮
        HBModifyMyInformationCtr *ctr   =  [[HBModifyMyInformationCtr alloc] initWithTitle:@"请输入审核评语" defaultValue:str_ isEdited:isEdited];
        ctr.HBModifyMyInformationBlock  = ^(NSString *name){
            strExamineDescription       = name;
            reviewModel.taskDesc        = name;
            [ctr.navigationController popViewControllerAnimated:YES];
            [tbv reloadData];
        };
        [self.navigationController pushViewController:ctr animated:YES];
    }
    if ([str0 isEqualToString:@"详细描述"] ) {//&& btnAchieveTask.hidden == NO
        NSString *str_ =  ((HBTaskDetailCell *)[tableView cellForRowAtIndexPath:indexPath]).tfRight.text;
        BOOL isEdited = !btnAchieveTask.hidden;//判断是否该隐藏HBModifyMyInformationCtr的保存按钮
        HBModifyMyInformationCtr *ctr   =  [[HBModifyMyInformationCtr alloc] initWithTitle:@"请输入任务留言" defaultValue:str_ isEdited:isEdited];
        ctr.HBModifyMyInformationBlock  = ^(NSString *name){
            strExecuteDescription       = name;
            detailModel.taskDesc        = name;
            [tbv reloadData];
            [ctr.navigationController popViewControllerAnimated:YES];

        };
        [self.navigationController pushViewController:ctr animated:YES];
    }


}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (!IsChange) {
        return 50.;
    }
    return .1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (IsChange) {
        return  9;
    }
    return marReview.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!IsChange ) {
        static NSString *str = @"HBReviewStatusCell";
        HBReviewStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
        if(!cell){
            cell = [HBReviewStatusCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        reviewModel = marReview[indexPath.row];
        cell.lbHead1.text   = (reviewModel.completeDate.length > 10)? [reviewModel.completeDate substringToIndex:10]: nil;
        cell.lbBottom1.text = (reviewModel.completeDate.length > 10)? [reviewModel.completeDate substringFromIndex:10]: nil;
        cell.lbHead2.text   = (reviewModel.createTime.length > 10)? [reviewModel.createTime substringToIndex:10]: nil;
        cell.lbBottom2.text =  (reviewModel.createTime.length > 10)? [reviewModel.createTime substringFromIndex:10]: nil;
        cell.lbHead3.text   = reviewModel.taskStatus;
        cell.lbHead4.text   = reviewModel.taskDesc;
        if ([cell.lbHead3.text isEqualToString:@"已完成"] || [cell.lbHead3.text isEqualToString:@"已审核"]) {
            [btnReviewFailure setHidden:YES];
            [btnReviewApproved setHidden:YES];
        }
        btnReviewFailure.hidden = ![HDGI.loginUser.ID isEqualToString:detailModel.examineUserId];//判断是否是否是审核人本人，不是就绝对隐藏，另外判断是否是完成在cell return时判断
        btnReviewApproved.hidden = ![HDGI.loginUser.ID isEqualToString: detailModel.examineUserId];
        lcBottomViewHeight.constant = btnReviewApproved.hidden? .1: 60.;
        [self.view updateConstraints];
        return cell;
    }else {
        static NSString *str1 = @"HBTaskDetailCell";
        HBTaskDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:str1];
        if(!cell){
            cell = [HBTaskDetailCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.tfRight.enabled = NO;
        switch (indexPath.row) {
            case 0:{
                cell.lbLeft.text    = cellTitle[indexPath.row];
                cell.tfRight.text   = detailModel.initiatorName;
                break;            }
            case 1:{
                cell.lbLeft.text    = cellTitle[indexPath.row];
                cell.tfRight.text   = detailModel.taskTitle;
                break;            }
            case 2:{
                cell.lbLeft.text    = cellTitle[indexPath.row];
                cell.tfRight.text   = detailModel.executeName;
                break;
            }
            case 3:{
                cell.lbLeft.text    = cellTitle[indexPath.row];
                cell.tfRight.text   = detailModel.startDate;
                break;
            }
            case 4:{
                cell.lbLeft.text    = cellTitle[indexPath.row];
                cell.tfRight.text   = detailModel.expectDate;
                break;
            }
            case 5:{
                cell.lbLeft.text    = cellTitle[indexPath.row];
                cell.tfRight.text   = detailModel.examineName;
                break;
            }
            case 6:{
                cell.lbLeft.text    = cellTitle[indexPath.row];
                cell.tfRight.text   = detailModel.taskStatus;
                break;
            }
            case 7:{
                cell.lbLeft.text    = cellTitle[indexPath.row];
                cell.tfRight.text   = detailModel.createTime;
                break;
            }
            case 8:{
                //cell.tfRight.enabled    = [detailModel.taskStatus isEqualToString:@"已完成"]? NO: YES;
                cell.lbLeft.text        = cellTitle[indexPath.row];
                cell.tfRight.text       = detailModel.taskDesc;
                cell.tfRight.delegate   = self;
                break;
            }
            default:
                break;
        }
//        if ([cell.tfRight.text isEqualToString:@"已完成"]) {
//            btnAchieveTask.hidden = YES;
//        }
//
        return cell;
    }
        return nil;
}

#pragma mark - UITextFieled delegate
#pragma mark

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    lcTop.constant = -150;
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    lcTop.constant = 115;
    [UIView animateWithDuration:0.4 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSMutableString *text = [NSMutableString stringWithString:textField.text];
    [text replaceCharactersInRange:range withString:string];
    strExecuteDescription  = text;
    return YES;
}

#pragma mark - event

- (void)postFinishedTaskHttp {//确认完成任务
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    helper.parameters = @{@"id":            HDSTR(strId), //任务id,
                          @"completeDesc":  HDSTR(strExecuteDescription)  //任务描述
                          };
    task = [helper postPath:@"execute-task/execute" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        [HDHelper say:@"确认完成！"];
        if (self.HBCancelBlock) {
            _HBCancelBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)postReviewTaskHttp:(NSString*)strResult {//审核通过
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    helper.parameters = @{@"id":            HDSTR(strId), //任务id,
                          @"status":        HDSTR(strResult),//只有success和fail
                          @"examineDesc" :  HDSTR(strExamineDescription) //任务描述
                          };
    task = [helper postPath:@"examine-task/examine" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        [HDHelper say:@"处理完成"];
        if (self.HBCancelBlock) {
            _HBCancelBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];

        
    }];
}

- (IBAction)finishedTaskClick:(UIButton *)sender {
    switch (sender.tag) {
        case 0:{
            if ([HDGI.loginUser.ID isEqualToString:detailModel.executeUserId]) {
                [self postFinishedTaskHttp];
            }else {
                [HDHelper say:@"抱歉！请确定是指派人本人"];
                return;
            }
            break;
        }
        case 1:{
            if ([HDGI.loginUser.ID isEqualToString:detailModel.examineUserId]) {
                [self postReviewTaskHttp:@"success"];
            }else {
                [HDHelper say:@"抱歉！请确定是审核人本人"];
                return;
            }
            break;
        }
        case 2:{
            if ([HDGI.loginUser.ID isEqualToString:detailModel.examineUserId]) {
                [self postReviewTaskHttp:@"fail"];
            }else {
                [HDHelper say:@"抱歉！请确定是审核人本人"];
                return;
            }
            break;
        }
        default:
            break;
    }
}

- (IBAction)selectTask:(UIButton *)sender {
    lcLeftConstraint.constant = HDDeviceSize.width * 0.5 * sender.tag+10;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
    if (sender.tag == 0) {
        refresh = nil;
        IsChange = YES;
        btnReviewApproved.hidden    = YES;
        btnReviewFailure.hidden     = YES;
        [btnDetailDescribtion setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btnReviewStatus setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self getTaskDescriptHttp];
    }else {
        IsChange = NO;
        btnAchieveTask.hidden = YES;
        [btnDetailDescribtion setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [btnReviewStatus setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        refresh = [HDRefresh new];
        [self httpGetPackageList:1];
        [refresh setHeadRefresh:tbv begin:^{
            [self httpGetPackageList:1];
        }];
    }
    
    [tbv reloadData];
}

- (void)httpGetPackageList:(int)index {
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    [helper.parameters setValue:@(10).stringValue forKey:@"pageSize"];
    [helper.parameters setValue:@(index).stringValue forKey:@"pageIndex"];
    task = [helper getPath:@"examine-task" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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
        IsChange = NO;          //tableview 显示哪个cell用；
        NSArray *content = json[@"content"];
        int total   = [JSON(json[@"totalCount"]) intValue];
        NSMutableArray *mar = [NSMutableArray new];
        for (int i = 0; i < content.count; i++) {
            NSDictionary *d = content[i];
             reviewModel = [HDHttpHelper model:[HBTaskReviewModel new] fromDictionary:d];
            if (reviewModel) {
                [mar addObject:reviewModel];
            }
        }
        if (index == 1) {
            marReview = [[NSMutableArray alloc] initWithArray:mar];
        }else{
            [marReview addObjectsFromArray:mar];
        }
        [tbv reloadData];
        isLast = marReview.count >= total;
        [refresh setFootRefresh:tbv isLast:isLast begin:^{
            [self httpGetPackageList:index + 1];
        }];
    }];
}


- (void)getTaskDescriptHttp {
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    NSString *str   = HDFORMAT(@"execute-task/%@",strId);
    task = [helper getPath:str object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        //hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        IsChange = YES;
        NSDictionary *d = json;
        detailModel = [HDHttpHelper model:[HBTaskDetailModel new] fromDictionary:d];
        BOOL is = [HDGI.loginUser.ID isEqualToString:detailModel.executeUserId];
        if ([HDGI.loginUser.ID isEqualToString:detailModel.executeUserId] && ![detailModel.taskStatus isEqualToString:@"已完成"]) {
            btnAchieveTask.hidden = NO;
        }else {
            btnAchieveTask.hidden = YES;
        }
//        btnAchieveTask.hidden = [HDGI.loginUser.ID isEqualToString:detailModel.executeUserId];//判断是否是指派人本人，任务完成或不是本人绝对隐藏
//        btnAchieveTask.hidden = [detailModel.taskStatus isEqualToString:@"已完成"];
//        BOOL b =  btnAchieveTask.hidden;
//        NSString *str_ = HDGI.loginUser.ID;
//        BOOL b1 = btnAchieveTask.hidden;
        lcBottomViewHeight.constant = btnAchieveTask.hidden? .1: 60.;
        [self.view updateConstraints];
        [tbv reloadData];
    }];}

#pragma mark - setter
- (void)setup{
    self.title  = @"任务详情";
    refresh = [HDRefresh new];
    IsChange    = YES;
    lcLeftConstraint.constant               = 10;
    btnDetailDescribtion.selected           = IsChange;
    btnAchieveTask.hidden                   = !btnDetailDescribtion.selected;//完成任务按钮
    btnReviewStatus.selected                = !btnDetailDescribtion.selected;//审核状况
    btnReviewFailure.hidden                 = YES;
    btnReviewApproved.hidden                = YES;
    btnReviewFailure.layer.cornerRadius     = 2.;
    btnReviewFailure.layer.borderColor      = [UIColor groupTableViewBackgroundColor].CGColor;
    btnReviewFailure.layer.borderWidth      = 2;
    btnReviewFailure.layer.masksToBounds    = YES;
    btnReviewApproved.layer.cornerRadius    = 2.;
    btnReviewApproved.layer.masksToBounds   = YES;
    [btnDetailDescribtion setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [tbv reloadData];
}

@end
@implementation HBTaskDetailModel

@end
@implementation HBTaskReviewModel
@end
