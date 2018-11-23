//
//  HBFinancialDetailCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/2/18.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBFinancialDetailCtr.h"
#import "HBFinancialtdetailCell.h"
#import "HBFinancialDetailPageCell.h"
#import "HBContractDetailedCtr.h"
#import "HDPayWayCell.h"
#import "HBBankInformation.h"
#import "HBFinancialCtr.h"
#import "HBPricingCell.h"
#import "HBOrderChangePriceCtr.h"

#define cellUpTitle @[@"订单号", @"合同订单", @"签约人", @"合同类型", @"车牌号", @"品牌型号", @"合同对接人", @"订单总金额", @"支付方式", @"支付状态"]
#define cellLeftTitle @[@"类型", @"押金", @"租金"]

@interface HBFinancialDetailCtr (){
    IBOutlet UITableView        *tbv;
    IBOutlet UIButton           *btnCancel;
    IBOutlet UIButton           *btnConfirm;
    IBOutlet UIButton           *btnConfirmPay;
    IBOutlet UIView             *vBottom;
    IBOutlet NSLayoutConstraint *lcHeight;
    NSURLSessionDataTask        *task;
    NSMutableArray              *marPackageList;
    HBFinancialDetailModel      *model;
    HBForContractModel          *contractModel;
    HBPricingMode               *pricingModel;
    NSMutableArray              *marPricing;
    HDHUD                       *hud;
    HDRefresh                   *refresh;
    NSString                    *orderNo;
    NSString                    *strCompanyId;
    NSString                    *contractNo;
    NSString                    *strPayMethod;
    int                         sizeTotal;
    int                         i;
    bool                        isBtn0;
    bool                        isBtn1;
    bool                        isBtn2;
    NSString                *strBankAccount;
    NSString                *strBankCard;
    NSString                *strBankName;
    BOOL                    isHiddenAssociatedButton;
    UIView  *vFloat;
}

@end

@implementation HBFinancialDetailCtr

- (id)initWithOrderNo:(NSString *)no company:(NSString *)companyId showAssociatedBtn:(BOOL)isHidden{
    if (self = [super init]) {
        orderNo         = no;
        strCompanyId    = companyId;
        isHiddenAssociatedButton = isHidden;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpGetOrderDetail:orderNo];
    [self httpGetBankInformaton:strCompanyId];
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == tbv) {
            CGFloat cornerRadius = 5.f;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 2 && indexPath.row > 1) {
        HBPricingCell *cell = (HBPricingCell*)[tableView cellForRowAtIndexPath:indexPath];
        NSString *type  = cell.btnChang.titleLabel.text;
        NSString *money = cell.btnAmount.titleLabel.text;
        NSString *note  = cell.btnExplain.titleLabel.text;
        NSString *strJoin   = HDFORMAT(@"%@\n%@\n%@", type, money, note);
        vFloat              = [[UIView alloc] initWithFrame:self.view.bounds];
        UITextView *tv_     = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 200., 230.)];
        tv_.text            = strJoin;
        tv_.layer.cornerRadius = 6.f;
        tv_.layer.masksToBounds= YES;
        vFloat.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5];
        [self.view addSubview:vFloat];
        [vFloat makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(self.view);
            make.center.equalTo(self.view);
        }];
        [vFloat addSubview:tv_];
        UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80.,40.)];
        [btnCancel setTitle:@"返回" forState:UIControlStateNormal];
        [btnCancel setTitleColor:HDCOLOR_ORANGE forState:UIControlStateNormal];
        [btnCancel setBackgroundColor:[UIColor whiteColor]];
        btnCancel.layer.cornerRadius = 6.f;
        btnCancel.layer.masksToBounds= YES;
        [btnCancel addTarget:self action:@selector(hideFloatView:) forControlEvents:UIControlEventTouchUpInside];

        [vFloat addSubview:btnCancel];
        [tv_ makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(vFloat);
            make.size.width.equalTo(@(200));
            make.size.height.equalTo(@(230));
        }];

        [btnCancel makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(tv_.mas_centerX);
            make.top.mas_equalTo(tv_.mas_bottom).with.offset(20);
            make.width.equalTo(@(80));
            make.height.equalTo(@(30));
        }];
        [vFloat addSubview:tv_];
        [tv_ makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(vFloat);
        }];

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 4 ) {
        return 90;
    }
    if(indexPath.section == 0 || indexPath.section == 3 || indexPath.section == 5) {
        return 70;
    }else if(HDIndexPath(2, 0) && ![model.status isEqualToString:@"未支付"]) {
        return .1;
    }else{
        return 50;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 5) {
        return .1;
    }
    return 10.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 10;
    }else if(section == 1) {
        return 3;
    }else if(section == 2) {
        return marPricing.count > 0 ? marPricing.count+2 : 2;
    }else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
    static NSString *str1    = @"HBFinancialtdetailCell";
    HBFinancialtdetailCell *cell   = [tableView dequeueReusableCellWithIdentifier:str1];
    if(!cell){
        cell = [HBFinancialtdetailCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
        cell.btnCheckMoreOrder.hidden   = YES;
        cell.imvRight.hidden            = YES;
        cell.lbTopTitle.text            = cellUpTitle[indexPath.row];
        cell.lbDownTitel.text           = @"";
        switch (indexPath.row) {
            case 0:{//订单号
                cell.lbDownTitel.text   = model.id;
                break;
            }
            case 1:{//合同订单
                cell.lbDownTitel.text   = model.bargainNo
                ;
                cell.btnCheckMoreOrder.hidden   = isHiddenAssociatedButton;
                [cell.btnCheckMoreOrder addTarget:self action:@selector(checkOrder:) forControlEvents:UIControlEventTouchUpInside];
                break;
            }
            case 2:{//签约人
                cell.lbDownTitel.text   = model.memberRealname;
                break;
            }
            case 3:{//合同类型
                cell.lbDownTitel.text   = model.bargainType;
                cell.imvRight.hidden    = NO;
                [cell.imvRight setUserInteractionEnabled:YES];
                [cell.imvRight addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkContract)]];
                break;
            }
            case 4:{//车牌号
                cell.lbDownTitel.text   = contractModel.vehicleNo;
                break;
            }
            case 5:{//品牌型号
                cell.lbDownTitel.text   = contractModel.vehicleBrand;
                break;
            }
            case 6:{//合同对接人
                cell.lbDownTitel.text   = model.companyUserRealname;
                break;
            }
            case 7:{//订单总金额
                cell.lbDownTitel.text   = model.ordersMoney;
                break;

            }
//            case 8:{//订单备注
//                cell.lbDownTitel.text   = model.note;
//                break;
//            }
            case 8:{//支付方式
                cell.lbDownTitel.text   = [model.payMethod isEqualToString:@"UnionPay"]? @"银行转账": @"";
                break;
            }
            case 9:{//支付状态
                cell.lbDownTitel.text   = model.status;
                break;
            }

            default:
                break;
        }
    
        return cell;
        
    }else if(indexPath.section == 1) {
        static NSString *str1   = @"HDTableViewCell";
        HDTableViewCell *cell   = [tableView dequeueReusableCellWithIdentifier:str1];
        if(!cell){
            cell = [[HDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:str1];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        cell.textLabel.text = cellLeftTitle[indexPath.row];
        cell.detailTextLabel.textAlignment      = NSTextAlignmentRight;
        cell.textLabel.textColor = indexPath.row == 0? [UIColor lightGrayColor]: [UIColor blackColor];
        cell.detailTextLabel.textColor = indexPath.row == 0? [UIColor lightGrayColor]: HDCOLOR_ORANGE;
//        cell.detailTextLabel.text = @[@"金额", HDSTR(model.deposit ), HDSTR(contractModel.rent)][indexPath.row];
        cell.detailTextLabel.text = @[@"金额", HDSTR(model.deposit ), HDSTR(model.rent)][indexPath.row];
        return cell;
    }else if (indexPath.section == 2) {
        static NSString *str3 = @"HBPricingCell";
        HBPricingCell *cell = [tableView dequeueReusableCellWithIdentifier:str3];
        if(!cell){
            cell = [HBPricingCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.btnData.titleLabel.font    = [UIFont systemFontOfSize:12.f];
        cell.btnChang.titleLabel.font   = [UIFont systemFontOfSize:12.f];
        cell.btnAmount.titleLabel.font  = [UIFont systemFontOfSize:12.f];
        cell.btnDelete.titleLabel.font  = [UIFont systemFontOfSize:12.f];
        cell.btnExplain.titleLabel.font = [UIFont systemFontOfSize:12.f];
        
        [cell.btnData       setTitleColor:[UIColor darkGrayColor]   forState:UIControlStateNormal];
        [cell.btnChang      setTitleColor:[UIColor darkGrayColor]   forState:UIControlStateNormal];
        [cell.btnAmount     setTitleColor:[UIColor darkGrayColor]   forState:UIControlStateNormal];
        [cell.btnDelete     setTitleColor:[UIColor blueColor]       forState:UIControlStateNormal];
        [cell.btnExplain    setTitleColor:[UIColor darkGrayColor]   forState:UIControlStateNormal];

        cell.btnData.hidden     = NO;
        cell.btnChang.hidden    = NO;
        cell.btnAmount.hidden   = NO;
        cell.btnDelete.hidden   = NO;
        cell.btnExplain.hidden  = NO;
        cell.lcWidth.constant   = 50.;
        cell.vLine.hidden   = YES;
        cell.hidden = NO;
        if(indexPath.row == 0) {
            cell.hidden = ![model.status isEqualToString:@"未支付"];
            cell.vLine.hidden   = NO;
            cell.btnData.hidden     = YES;
            cell.btnChang.hidden    = YES;
            cell.btnAmount.hidden   = YES;
            cell.btnDelete.hidden   = NO;
            cell.btnExplain.hidden  = YES;
            cell.btnDelete.layer.cornerRadius   = 5.;
            cell.btnDelete.layer.masksToBounds  = YES;
            cell.btnDelete.layer.borderWidth    = 1.;
            cell.btnDelete.layer.borderColor    = [UIColor lightGrayColor].CGColor;
            cell.lcWidth.constant = 120.;
            cell.btnDelete.titleLabel.font = [UIFont systemFontOfSize:14.f];
            [cell.btnDelete     setTitle:@"新增调价项" forState:UIControlStateNormal];
            [cell.btnDelete    setTitleColor:[UIColor darkGrayColor]   forState:UIControlStateNormal];
            [cell.btnDelete addTarget:self action:@selector(changePrice:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }else if (indexPath.row == 1) {
            [cell.btnChang      setTitle:@"变动"  forState:UIControlStateNormal];
            [cell.btnAmount     setTitle:@"金额"  forState:UIControlStateNormal];
            [cell.btnExplain    setTitle:@"缘由"  forState:UIControlStateNormal];
            [cell.btnData       setTitle:@"时间"  forState:UIControlStateNormal];
            [cell.btnDelete     setTitle:@"操作"  forState:UIControlStateNormal];
            cell.btnData.titleLabel.font    = [UIFont systemFontOfSize:13.f];
            cell.btnChang.titleLabel.font   = [UIFont systemFontOfSize:13.f];
            cell.btnAmount.titleLabel.font  = [UIFont systemFontOfSize:13.f];
            cell.btnDelete.titleLabel.font  = [UIFont systemFontOfSize:13.f];
            cell.btnExplain.titleLabel.font = [UIFont systemFontOfSize:13.f];
            [cell.btnDelete    setTitleColor:[UIColor darkGrayColor]   forState:UIControlStateNormal];
            return cell;
        }else {
            cell.btnDelete.hidden == [model.status isEqualToString:@"未支付"]? NO : YES;
            cell.lcWidth.constant = [model.status isEqualToString:@"未支付"]? 50 : 0;
            pricingModel = marPricing[indexPath.row-2];
            NSString *strChange = pricingModel.changeAction.intValue == 1? @"增加" : @"减少";
            NSString *strDate = [pricingModel.createTime substringWithRange:NSMakeRange(0, 10)];
            [cell.btnChang      setTitle:strChange          forState:UIControlStateNormal];
            [cell.btnAmount     setTitle:pricingModel.money forState:UIControlStateNormal];
            [cell.btnExplain    setTitle:pricingModel.note  forState:UIControlStateNormal];
            [cell.btnData       setTitle:strDate            forState:UIControlStateNormal];
            [cell.btnDelete     setTitle:@"删除"             forState:UIControlStateNormal];
            cell.btnDelete.tag = (indexPath.row-2);
            [cell.btnDelete addTarget:self action:@selector(deleteChangeItem:) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
    }else if (indexPath.section == 3) {
        static NSString * cellID=@"cellID";
        UITableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell==nil) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        }
        cell.textLabel.text = @"订单实收金额";
        cell.textLabel.font = [UIFont systemFontOfSize:14.f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13.f];
        cell.detailTextLabel.textColor = HDCOLOR_RED;
        cell.imageView.image = [UIImage imageNamed:@"music"];
        
        float amout = HDSTR(model.ordersMoney).floatValue;
//        for (pricingModel in marPricing) {
//            if ([pricingModel.changeAction isEqualToString:@"1"]) {
//                amout = pricingModel.money.floatValue + amout;
//            }else {
//                amout = amout - pricingModel.money.floatValue ;
//            }
//        }
        cell.detailTextLabel.text   = HDFORMAT(@"¥%.2f",amout);
        cell.backgroundColor = [UIColor whiteColor];

        return cell;
    }else if(indexPath.section == 4) {
        static NSString *str3 = @"HDPayWayCell";
        HDPayWayCell *cell = [tableView dequeueReusableCellWithIdentifier:str3];
        if(!cell){
            cell = [HDPayWayCell loadFromNib];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    static NSString *str3 = @"HBBankInformation";
    HBBankInformation *cell = [tableView dequeueReusableCellWithIdentifier:str3];
    if(!cell){
        cell = [HBBankInformation loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.lbBankName.text        = strBankName;
    cell.lbBankAccount.text     = strBankAccount;
    cell.lbBankCardNumber.text  = strBankCard;
    return cell;
}
#pragma mark - event
#pragma mark
- (void)httpDeletePricingItem:(NSString *)itemId {
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    NSString *str = HDFORMAT(@"member-rent-orders-change-log/%@", HDSTR(itemId));
    task = [helper deletePath:str object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        [HDHelper say:@"删除成功！"];
        [self httpGetOrderDetail:orderNo];//重新获取订单列表
    }];
}

- (IBAction)deleteChangeItem:(UIButton *)sender {
    if (![HDGI.loginUser.role isEqualToString:@"Finance"]) {
        [HDHelper say:@"抱歉，您没有财务管理权限!"];
        return;
    }
    pricingModel = marPricing[sender.tag];
    Dlog(@"删除了%d - %@", sender.tag,pricingModel.id);
    [self httpDeletePricingItem:pricingModel.id];
}

- (IBAction)hideFloatView:(UIButton *)sender {
    [vFloat removeFromSuperview];
    vFloat = nil;
}

- (IBAction)checkOrder:(id)sender {
    HBFinancialCtr *ctr = [[HBFinancialCtr alloc] initWithBargainId:model.bargainId];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)checkContract {
    HBContractDetailedCtr *ctr = [[HBContractDetailedCtr alloc] initWithString:model.bargainId];
    [self.navigationController pushViewController:ctr animated:YES];
}

-(IBAction)cacelPay:(id)sender {
    if (![HDGI.loginUser.role isEqualToString:@"Finance"]) {
        [HDHelper say:@"抱歉，您没有财务管理权限!"];
        return;
    }
    if(!model || model.id.length < 1){
        return;
    }
    [self httpCancelOrder];
}

- (IBAction)confirmPay:(id)sender {
    if (![HDGI.loginUser.role isEqualToString:@"Finance"]) {
        [HDHelper say:@"抱歉，您没有财务管理权限!"];
        return;
    }
    if (!model||model.id.length < 1) {
        return;
    }
    [self httpGetConfirmPay:HDSTR(model.id)];
}

- (IBAction)payingImmediatly:(id)sender {
    if (![HDGI.loginUser.role isEqualToString:@"Finance"]) {
        [HDHelper say:@"抱歉，您没有财务管理权限!"];
        return;
    }
//    if (strPayMethod.length < 1) {
//        [HDHelper say:@"请选择支付方式！"];
//        return;
//    }
    [self httpPostPayImmediatly];
}

- (void)httpGetConfirmPay:(NSString *)orderId {
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    helper.parameters = @{@"id": HDSTR(orderId)
                          };
    task = [helper postPath:@"member-rent-orders/confirm" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        [HDHelper say:@"确认完成！"];
        if (self.cancelBlock) {
            self.cancelBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)httpPostPayImmediatly{
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    helper.parameters = @{@"id":        HDSTR(model.id),
                          @"payMethod": HDSTR(@"UnionPay"),
                          @"note":      HDSTR(model.note)
                          };
    task = [helper postPath:@"member-rent-orders/pay" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        [self httpGetConfirmPay:model.id];
//        [HDHelper say:@"受理成功！"];
//        if (self.cancelBlock) {
//            self.cancelBlock();
//        }
//        [self.navigationController popViewControllerAnimated:YES];
    }];
}


- (void)httpCancelOrder{
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    helper.parameters = @{@"id":HDSTR(model.id)};
    task = [helper postPath:@"member-rent-orders/cancel" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        [HDHelper say:@"受理成功！"];
        if (self.cancelBlock) {
            self.cancelBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)httpGetOrderDetail:(NSString *)no{
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    NSString *str = HDFORMAT(@"member-rent-orders/%@", HDSTR(no));
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
        NSDictionary *dic = json;
        model = [HDHttpHelper model:[HBFinancialDetailModel new] fromDictionary:dic];
        [self setup];
        [self httpGetContractDetail:model.bargainId];
        [self httpGetPricingDetail:no];
        if ([model.status isEqualToString:@"已支付"]) {
            vBottom.hidden      = YES;
            lcHeight.constant   = .1;
        }
        [tbv reloadData];
    }];
}

//获取调价项数据组
- (void)httpGetPricingDetail:(NSString *)no{
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    NSString *str = HDFORMAT(@"member-rent-orders-change-log?ordersNo=%@", HDSTR(no));
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
        NSArray *ar = json[@"content"];
        marPricing = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in ar) {
            pricingModel = [HDHttpHelper model:[HBPricingMode new] fromDictionary:dic];
            [marPricing addObject:pricingModel];
        }
//        NSDictionary *dic = json;
//        model = [HDHttpHelper model:[HBFinancialDetailModel new] fromDictionary:dic];
//        [self setup];
//        [self httpGetContractDetail:model.bargainId];
//        if ([model.status isEqualToString:@"已支付"]) {
//            vBottom.hidden      = YES;
//            lcHeight.constant   = .1;
//        }
        [tbv reloadData];
    }];
}

- (void)httpGetContractDetail:(NSString *)contractNo{
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    NSString *path = HDFORMAT(@"member-bargain/%@",HDSTR(contractNo));
    task = [helper getPath:path object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
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
        NSDictionary *dic = json;
        contractModel = [HDHttpHelper model:[HBForContractModel new] fromDictionary:dic];
        [tbv reloadData];
    }];
}

- (void)httpGetBankInformaton:(NSString *)companyId {
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];//bank-data
    }
    NSString *strMain   = HDFORMAT(@"bank-data?companyId=%@",companyId);
    NSString *strPublic = @"my-bank-data";
    NSString *str       = [HDGI.loginUser.role isEqualToString:@"Main"]? strMain: strPublic;
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
        if ([HDGI.loginUser.role isEqualToString:@"Main"]) {
            NSArray *ar = json[@"content"];
            if (ar.count > 0) {
                NSDictionary *dic = ar[0];
                strBankName     = JSON(dic[@"bankName"]);
                strBankCard     = JSON(dic[@"bankNo"]);
                strBankAccount  = JSON(dic[@"bankAccount"]);
            }
        }else {
            strBankName     = JSON(json[@"bankName"]);
            strBankCard     = JSON(json[@"bankNo"]);
            strBankAccount  = JSON(json[@"bankAccount"]);
        }
        [tbv reloadData];
    }];
}

- (void)httpSaveModify:(NSString *)orderId changType:(NSString *)changeAction account:(NSString *)money note:(NSString *)note {
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    NSString *strPath   = HDFORMAT(@"member-rent-orders/change/%@",orderId);
    helper.parameters   = @{
                          @"changeAction": HDSTR(changeAction),
                          @"money": HDSTR(money),
                          @"note": HDSTR(note)
                          };
    task = [helper postPath:strPath object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        [HDHelper say:@"保存成功！"];
        [self httpGetOrderDetail:orderNo];
    }];
}

- (IBAction)changePrice:(UIButton*)sender {
    if (![HDGI.loginUser.role isEqualToString:@"Finance"]) {
        [HDHelper say:@"抱歉，您没有财务管理权限!"];
        return;
    }
 
    HBOrderChangePriceCtr *ctr = [[HBOrderChangePriceCtr alloc] init];
    [self addChildViewController:ctr];
    [self.view addSubview:ctr.view];
    [self.view bringSubviewToFront:ctr.view];
    [ctr.view makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    [ctr setFinishBlock:^(NSString *strType, NSString *money, NSString *strDescription) {
        [self httpSaveModify:orderNo changType:strType account:money note:strDescription];
    }];

    
    
}

#pragma setter

- (IBAction)selectPayMethod:(UIButton *)sender {
    switch (sender.tag) {
        case 0:{
            i = 1;
            isBtn0          = YES;
            isBtn1          = NO;
            isBtn2          = NO;
            strPayMethod    = @"Alipay";
            [tbv reloadData];
            break;
        }
        case 1:{
            i = 2;
            isBtn0          = NO;
            isBtn1          = YES;
            isBtn2          = NO;
            strPayMethod    = @"Weixin";
            [tbv reloadData];
            break;
        }
        case 2:{
            i = 3;
            isBtn0          = NO;
            isBtn1          = NO;
            isBtn2          = YES;
            strPayMethod    = @"UnionPay";
            [tbv reloadData];
            break;
        }
        default:
            break;
    }
}


- (void)setup {
    self.title = @"订单详情";
    btnCancel.layer.cornerRadius        = 5.f;
    btnConfirm.layer.cornerRadius       = 5.f;
    btnCancel.layer.masksToBounds       = YES;
    btnConfirm.layer.masksToBounds      = YES;
    btnCancel.layer.borderColor         = [UIColor lightGrayColor].CGColor;
    btnCancel.layer.borderWidth         = 1.f;
    btnConfirmPay.layer.cornerRadius    = 5.f;
    btnConfirmPay.layer.masksToBounds   = YES;
    btnConfirmPay.hidden = [model.status isEqualToString:@"已支付"]? NO: YES;
    btnCancel.hidden     = !btnConfirmPay.hidden;
    btnConfirm.hidden    = !btnConfirmPay.hidden;
    vBottom.hidden       = [model.status isEqualToString:@"已作废"]? YES: NO;
    lcHeight.constant    = [model.status isEqualToString:@"已作废"]? 0: 60;
}

@end
@implementation HBFinancialDetailModel



@end
@implementation HBForContractModel

@end
@implementation HBPricingMode

@end


