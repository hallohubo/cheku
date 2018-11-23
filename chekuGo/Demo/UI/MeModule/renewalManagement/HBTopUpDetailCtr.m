//
//  HBTopUpDetailCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/2/7.
//  Copyright © 2018年 hufan. All rights reserved.
//
#define cellTitle @[@[@"订单号",@"续费年数",@"订单金额",@"订单时间"],@[@"支付状态",@"支付时间",@"支付方式"]]
#import "HBTopUpDetailCtr.h"
#import "HBTopUpDetailPageCell.h"

@interface HBTopUpDetailCtr () {
    IBOutlet UIButton       *btnPay;
    IBOutlet UIView         *vBottom;
    IBOutlet UITableView    *tbv;
    NSURLSessionDataTask    *task;
    HDHUD                   *hud;
    NSString                *renewaId;
    NSString                *strPayMethod;
    HBTopUpDetailPageModel  *model;
    int                     i ;
    bool                    isBtn0;
    bool                    isBtn1;
    bool                    isBtn2;
    NSString                *strBankAccount;
    NSString                *strBankCard;
    NSString                *strBankName;
}

@end

@implementation HBTopUpDetailCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpGetPackageList:renewaId];
    [self httpGetBankInformaton];
}

- (id)initWithTitle:(NSString *)titleState {
    if (self = [super init]) {
        renewaId = titleState;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (HDIndexPath(1, 3)) {
        return 100.f;
    }
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .1;
}

#pragma mark - UITableViewDataSource
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {
        return ([model.payStatus isEqualToString:@"已完成"] || [model.payStatus isEqualToString:@"已支付"])? 3 : 4;
    }else {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *str = @"HBTopUpDetailPageCell";
    HBTopUpDetailPageCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if(!cell){
        cell = [HBTopUpDetailPageCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.vSelectPay.hidden = YES;
//    [cell.btnUnionCard addTarget:self action:@selector(selectPayMethod:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.btnWechat addTarget:self action:@selector(selectPayMethod:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.btnAlipay addTarget:self action:@selector(selectPayMethod:) forControlEvents:UIControlEventTouchUpInside];
    cell.btnUnionCard.selected = isBtn2;
    cell.btnAlipay.selected = isBtn0;
    cell.btnWechat.selected = isBtn1;
    cell.vAlipay.hidden     = YES;//暂时不需要第三方支付
    cell.vWechatPay.hidden  = YES;//暂时不需要第三方支付
    cell.lbTitle.hidden     = NO;
    cell.lbDetailed.hidden  = NO;
    cell.vBankInformation.hidden = YES;
    cell.imvAlipay.image = cell.btnAlipay.selected? HDIMAGE(@"selected"): HDIMAGE(@"selectNone");
    cell.imvWechat.image = cell.btnWechat.selected? HDIMAGE(@"selected"): HDIMAGE(@"selectNone");
    cell.imvUnionCard.image =  HDIMAGE(@"selected");
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                cell.lbTitle.text    = cellTitle[indexPath.section][indexPath.row];
                cell.lbDetailed.text = model.id;
                break;                }
            case 1:{
                cell.lbTitle.text    = cellTitle[indexPath.section][indexPath.row];
                cell.lbDetailed.text = model.renewNumber;
                break;                }
            case 2:{
                cell.lbTitle.text    = cellTitle[indexPath.section][indexPath.row];
                cell.lbDetailed.text = model.ordersMoney;
                break;                }
            case 3:{
                cell.lbTitle.text    = cellTitle[indexPath.section][indexPath.row];
                cell.lbDetailed.text = model.lastModifyTime;
                break;                }
            default:
                break;
        }
        return cell;
    }else {
        switch (indexPath.row) {
            case 0:{
                cell.lbTitle.text    = cellTitle[indexPath.section][indexPath.row];
                cell.lbDetailed.text = model.payStatus;
                break;                                }
            case 1:{
                cell.lbTitle.text    = cellTitle[indexPath.section][indexPath.row];
                cell.lbDetailed.text = model.payTime;
                break;                                }
            case 2:{
                cell.lbTitle.text    = cellTitle[indexPath.section][indexPath.row];
                cell.lbDetailed.text = [model.payMethod isEqualToString:@"UnionPay"]? @"银行转账": model.payMethod;
                bool isNeed = [model.payStatus isEqualToString:@"已完成"] || [model.payStatus isEqualToString:@"已支付"];
                cell.lbDetailed.hidden = !isNeed;
                cell.vSelectPay.hidden = isNeed;
                if (!isNeed) {
                    
                }
                break;
            }
            case 3:{
                bool isNeed = [model.payStatus isEqualToString:@"已完成"] || [model.payStatus isEqualToString:@"已支付"];
                cell.lbDetailed.hidden  = YES;
                cell.lbTitle.hidden     = YES;
                cell.vSelectPay.hidden  = YES;
                cell.lbBankName.text    = strBankName;
                cell.lbBankAccount.text = strBankAccount;
                cell.lbBankCardNumber.text  = strBankCard;
                cell.vBankInformation.hidden    = isNeed;
                break;
            }
            default:
                break;
        }
        return cell;
    }
    return nil;
    }

#pragma mark - event
#pragma mark

//- (IBAction)selectPayMethod:(UIButton *)sender {
//    switch (sender.tag) {
//        case 0:{
//            i = 1;
//            isBtn0          = YES;
//            isBtn1          = NO;
//            isBtn2          = NO;
//            strPayMethod    = @"Alipay";
//            [tbv reloadData];
//            break;
//        }
//        case 1:{
//            i = 2;
//            isBtn0          = NO;
//            isBtn1          = YES;
//            isBtn2          = NO;
//            strPayMethod    = @"Weixin";
//             [tbv reloadData];
//            break;
//        }
//        case 2:{
//            i = 3;
//            isBtn0          = NO;
//            isBtn1          = NO;
//            isBtn2          = YES;
//            strPayMethod    = @"UnionPay";
//            [tbv reloadData];
//            break;
//        }
//        default:
//            break;
//    }
//}

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
        if (!mar || mar.count < 0) {
            return;
        }
        model = [HDHttpHelper model:[HBTopUpDetailPageModel new] fromDictionary:mar];
        vBottom.hidden = [model.payStatus isEqualToString:@"已完成"] || [model.payStatus isEqualToString:@"已支付"];
        [tbv reloadData];
    }];
    
}

- (void)httpGetBankInformaton {
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    task = [helper getPath:@"admin-bank-data" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        hud = nil;
        if (error) {
            if (error.code == -999) {
                return ;
            }
            [HDHelper say:error.desc];
            return;
        }
        strBankName = JSON(json[@"bankName"]);
        strBankCard = JSON(json[@"bankNo"]);
        strBankAccount = JSON(json[@"bankAccount"]);
        [tbv reloadData];
    }];
    
}


- (void)httpPostPayConfirm {
    HDHttpHelper *helper = [HDHttpHelper instance];
    HDHUD *hud = [HDHUD showLoading:@"" on:self.view];
    helper.parameters = @{@"payMethod": @"UnionPay",
                          @"id":HDSTR(renewaId)};
    Dlog(@"=%@=%@",strPayMethod,renewaId);
    task = [helper postPath:@"/company-renew/ios-pay" object:nil finished:^(HDError *error, id object, BOOL isLast, id json) {
        [hud hiden];
        if (error) {
            if (error.code != -999) {
                [HDHelper say:error.desc];
            }
            return ;
        }
        [HDHelper say:@"保存成功！"];
        if (self.cancelBlock) {
            self.cancelBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


- (IBAction)payClick:(id)sender {
//    if (strPayMethod.length < 1) {
//        [HDHelper say:@"请选择支付方式"];
//        return;
//    }
    [self httpPostPayConfirm];
}

#pragma mark - setter

- (void)setup {
    btnPay.layer.cornerRadius   = 6.;
    btnPay.layer.masksToBounds  = YES;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 90)];
    [v addSubview:vBottom];
    [vBottom makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(v);
        make.center.equalTo(v);
    }];
    tbv.tableFooterView = v;
    self.title = @"充值详情";
}

@end
@implementation HBTopUpDetailPageModel

@end
