//
//  HBWithdrawalDetailCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/1/25.
//Copyright © 2018年 hufan. All rights reserved.
//
#define titleText @[@"订单号",@"收款银行",@"银行卡号",@"收款账户",@"提现金额",@"提现时间",@"处理状态",@"处理时间"]

#import "HBWithdrawalDetailCtr.h"
#import "HBWithdrawalDetailCell.h"

@interface HBWithdrawalDetailCtr (){
    IBOutlet UITableView    *tbv;
    IBOutlet UIView         *vBottom;
    IBOutlet UIImageView    *imvReturnReceipt;
    NSURLSessionDataTask    *task;
    HDHUD                   *hud;
    NSString                *strId;
    HBWithdrawalDetailModel *model;
    
}

@end

@implementation HBWithdrawalDetailCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self getWithdrawlDetailHttp];
}

- (instancetype)initWithCompanyId:(NSString *)companyId {
    if(self = [super init]) {
        strId = companyId;
    }
    return self;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == tbv) {
            CGFloat cornerRadius = 10.f;
            cell.backgroundColor = UIColor.clearColor;
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, 0, 0);
            BOOL addLine = YES;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = [UIColor colorWithWhite:1.f alpha:0.8f].CGColor;
            
            if (addLine == YES) {
                CALayer *lineLayer = [[CALayer alloc] init];
                CGFloat lineHeight = 1.f;
                // CGFloat lineHeight = (1.f / [UIScreen mainScreen].scale);
                lineLayer.frame = CGRectMake(CGRectGetMinX(bounds)+10, bounds.size.height-lineHeight, bounds.size.width-10, lineHeight);
                lineLayer.backgroundColor = [UIColor groupTableViewBackgroundColor].CGColor;
                [layer addSublayer:lineLayer];
            }
            UIView *testView = [[UIView alloc] initWithFrame:bounds];
            [testView.layer insertSublayer:layer atIndex:0];
            testView.backgroundColor = UIColor.clearColor;
            cell.backgroundView = testView;
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return titleText.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"HBWithdrawalDetailCell";
    HBWithdrawalDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HBWithdrawalDetailCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (!model) {
        return cell;
    }
    switch (indexPath.row) {
        case 0:{
            cell.lbTitle.text   = titleText[indexPath.row];
            cell.lbContent.text = model.id;
            break;
        }
        case 1:{
            cell.lbTitle.text   = titleText[indexPath.row];
            cell.lbContent.text = model.bankName;
            break;
        }
        case 2:{
            cell.lbTitle.text   = titleText[indexPath.row];
            cell.lbContent.text = model.bankNo;
            break;
        }
        case 3:{
            cell.lbTitle.text   = titleText[indexPath.row];
            cell.lbContent.text = model.bankAccount;
            break;
        }
        case 4:{
            cell.lbTitle.text   = titleText[indexPath.row];
            cell.lbContent.text = model.widthdrawMoney;
            break;
        }
        case 5:{
            cell.lbTitle.text   = titleText[indexPath.row];
            cell.lbContent.text = model.widthdrawTime;
            break;
        }
        case 6:{
            cell.lbTitle.text   = titleText[indexPath.row];
            cell.lbContent.text = model.status;
            break;
        }
        case 7:{
            cell.lbTitle.text   = titleText[indexPath.row];
            cell.lbContent.text = model.handleTime;
            break;
        }

        default:
            break;
    }
    return cell;
}


#pragma mark - event

- (void)getWithdrawlDetailHttp {
    HDHttpHelper *helper = [HDHttpHelper instance];
    [helper.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [helper.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSString *strPath = HDFORMAT(@"company-withdraw-cash/%@",strId);
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    task = [helper getPath:strPath object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            [HDHelper say:error.desc];
            return ;
        }
        if (!json) {
            return;
        }
        NSDictionary *dic = json;
        model = [HDHttpHelper model:[HBWithdrawalDetailModel new] fromDictionary:dic];
        [imvReturnReceipt setImageWithURL:[NSURL URLWithString:model.receipt]];
        [tbv reloadData];
    }];
}

#pragma mark - setter
- (void)setup{
    self.title = @"提现详情";
    vBottom.layer.cornerRadius  = 10.f;
    vBottom.layer.masksToBounds = YES;
    [tbv setTableFooterView:vBottom];
}

@end

@implementation HBWithdrawalDetailModel

@end
