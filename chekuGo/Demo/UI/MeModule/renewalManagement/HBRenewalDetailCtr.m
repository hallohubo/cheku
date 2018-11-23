//
//  HBRenewalDetailCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/1/22.
//Copyright © 2018年 hufan. All rights reserved.
//
#define arrTitle @[@"订单号",@"合同订单",@"签约人",@"合同类型",@"车牌号",@"品牌型号",@"合同对接人",@"订单总金额",@"订单备注",@"支付方式",@"支付状态"]

#import "HBRenewalDetailCtr.h"
#import "HBRenewalDetailCell.h"

@interface HBRenewalDetailCtr (){
    IBOutlet NSLayoutConstraint *lcBottonHeight;
    IBOutlet UIView             *vBottom;
    IBOutlet UIView             *vSmallContain;
    IBOutlet UIButton           *btnInvalid;
    IBOutlet UIButton           *btnPay;
    IBOutlet UILabel            *lbRent;
    IBOutlet UILabel            *lbDeposit;
    IBOutlet UITableView        *tbv;
    NSURLSessionDataTask        *task;
    HBRenewalDetailModel        *model;
    HDHUD       *hud;
    NSString    *renewaId;
    HDRefresh   *refresh;
    
}

@end

@implementation HBRenewalDetailCtr

- (id)initWithTitle:(NSString *)titleState {
    if (self = [super init]) {
        renewaId = titleState;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpGetPackageList:renewaId];
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
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return .1f;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    return 100;
//}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"HBRenewalDetailCell";
    HBRenewalDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HBRenewalDetailCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.lbTitle.text = arrTitle[indexPath.row];
    cell.btnToView.hidden = YES;
    cell.imv.hidden = YES;
    switch (indexPath.row) {
        case 1:{
            cell.btnToView.hidden   = NO;
            cell.lbContent.text     = model.ordersNo;
            break;
        }
        case 3:{
            cell.imv.hidden     = NO;
            cell.lbContent.text = model.companyId;
            break;
        }
        default:
            break;
    }
    return cell;
}


#pragma mark - event
- (void)httpGetPackageList:(NSString *)index {
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    //[helper.parameters setValue:HDSTR(index) forKey:@"id"];
    NSString *str = HDFORMAT(@"company-renew/%@",HDSTR(index));
    task = [helper getPath:str object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        NSDictionary *mar = json;
        if (!mar) {
            return;
        }
        model = [HDHttpHelper model:[HBRenewalDetailModel new] fromDictionary:mar];
        [tbv reloadData];
    }];

}

- (void)editCell {
    
}

#pragma mark - setter

- (void)setup{
    self.title = @"订单详情";
    vSmallContain.layer.cornerRadius    = 10.;
    vSmallContain.layer.masksToBounds   = YES;
    btnInvalid.layer.cornerRadius       = 4.f;
    btnInvalid.layer.masksToBounds      = YES;
    btnInvalid.layer.borderColor        = HDCOLOR_GRAY.CGColor;
    btnInvalid.layer.borderWidth        = 1.;
    btnPay.layer.cornerRadius           = 4.f;
    btnPay.layer.masksToBounds          = YES;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width-20, 181.)];
    v.backgroundColor = self.view.backgroundColor;
    [v addSubview:vSmallContain];
    [vSmallContain makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(v);
        make.top.equalTo(v).offset(10);
        make.bottom.equalTo(v).offset(10);
        make.size.width.equalTo(v);
    }];
    tbv.tableFooterView = v;
}

@end

@implementation HBRenewalDetailModel
@end
