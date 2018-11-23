//
//  HBContractDetailedCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/1/20.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBContractDetailedCtr.h"
#import "HBContractDetailedCell.h"

#define cellTitle @[@"合同编号",@"签约姓名",@"身份证",@"对接人",@"车牌号",@"品牌型号",@"合同类型",@"押金",@"租金",@"合同日期",@"租金日期",@"合同备注"]

@interface HBContractDetailedCtr () {
    IBOutlet UITableView *tbv;
    
    NSMutableArray              *marPackageList;
    HDHUD                       *hud;
    HDRefresh                   *refresh;
    NSString                    *strContractID;
    NSURLSessionDataTask        *task;
    HBContractDetailedModel     *model;
    NSMutableArray              *marr;
}

@end

@implementation HBContractDetailedCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpGetPackageList:strContractID];
    // Do any additional setup after loading the view from its nib.
}

- (instancetype)initWithString:(NSString *)contractID {
    self = [super init];
    if (self) {
        strContractID = contractID;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 12;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *str1 = @"HBContractDetailedCell";
    HBContractDetailedCell *cell = [tableView dequeueReusableCellWithIdentifier:str1];
    if(!cell){
        cell = [HBContractDetailedCell loadFromNib];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.lbRight.hidden     = YES;
    cell.lbMiddle.hidden    = YES;
    cell.lbTitle.text       = cellTitle[indexPath.row];
    cell.lcWidth.constant   = 135.f;
    switch (indexPath.row) {
        case 0:{
            cell.lbLeft.text = model.bargainNo;
            cell.lcWidth.constant = [HDStringHelper widthOfString:model.bargainNo font:HDFONT widthMax:240];
            [self.view updateConstraints];
            break;
        }
        case 1:{
            cell.lbLeft.text = HDDIC(model.signRealname);
            break;
        }
        case 2:{
            cell.lbLeft.text = HDDIC(model.signCardId);
            cell.lcWidth.constant = [HDStringHelper widthOfString:model.signCardId font:HDFONT widthMax:240];
            [self.view updateConstraints];
            break;
        }
        case 3:{
            cell.lbLeft.text = HDDIC(model.companyUserRealname);
            cell.lcWidth.constant = [HDStringHelper widthOfString:model.companyUserRealname font:HDFONT widthMax:240];
            [self.view updateConstraints];
            break;
        }
        case 4:{
            cell.lbLeft.text = HDDIC(model.vehicleNo);
            break;
        }
        case 5:{//品牌型号
            cell.lbLeft.text = HDDIC(model.vehicleBrand);
            cell.lcWidth.constant = [HDStringHelper widthOfString:model.vehicleBrand font:HDFONT widthMax:240];
            [self.view updateConstraints];
            break;
        }
        case 6:{
            cell.lbLeft.text = HDDIC(model.bargainType);
            break;
        }
        case 7:{
            cell.lbLeft.text = HDDIC(model.deposit);
            break;
        }
        case 8:{
            cell.lbLeft.text = HDDIC(model.rent);
            break;
        }
        case 9:{
            cell.lbMiddle.hidden    = NO;
            cell.lbRight.hidden     = NO;
            cell.lbLeft.text        = HDDIC(model.startDate);
            cell.lbRight.text       = HDDIC(model.endDate);
            break;
        }
        case 10:{
            cell.lbLeft.text = HDDIC(model.rentDay);
           // Dlog(@"rentDay==%@",model.rentDay);
            break;
        }
        case 11:{
            cell.lbLeft.text = HDDIC(model.note);
            //Dlog(@"note==%@",model.note);
            cell.lcWidth.constant   = HDDeviceSize.width - 40;
            [self.view endEditing:YES];
            break;
        }
        default:
            break;
    }
    return cell;
}

#pragma mark - event
#pragma mark

- (void)httpGetPackageList:(NSString *)index {
    HDHttpHelper *helper = [HDHttpHelper instance];
    if (!hud) {
        hud = [HDHUD showLoading:@"" on:self.view];
    }
    //[helper.parameters setValue:HDSTR(index) forKey:@"id"];
    NSString *str = HDFORMAT(@"member-bargain/%@",HDSTR(index));
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
        NSDictionary *mar = json;
        if (!mar) {
            return;
        }
        model = [HDHttpHelper model:[HBContractDetailedModel new] fromDictionary:mar];
        [tbv reloadData];
    }];
}


#pragma setter

- (void)setup {
    self.title = @"合同详情";
}
@end
@implementation HBContractDetailedModel

@end
