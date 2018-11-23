//
//  HBOrderChangePriceCtr.m
//  Demo
//
//  Created by 胡勃 on 2018/9/12.
//  Copyright © 2018年 hufan. All rights reserved.
//

#import "HBOrderChangePriceCtr.h"
#import "HBTriangleV.h"

@interface HBOrderChangePriceCtr ()<UITextFieldDelegate> {
    IBOutlet UITextField    *tfAmount;
    IBOutlet UITextView     *tvNote;
    IBOutlet UIButton       *btnCancel;
    IBOutlet UIButton       *btnSave;
    IBOutlet UIButton       *btnSelect;
    IBOutlet UITableView    *tbvSelect;
    IBOutlet UIImageView    *imvSelect;
    IBOutlet HBTriangleV    *vTriangle;
    IBOutlet UIView         *vM;
    NSString    *strSelect;
    NSString    *strDescription;
    NSString    *money;
}

@end

@implementation HBOrderChangePriceCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
}

- (void)viewWillAppear:(BOOL)animated {
    tbvSelect.hidden = YES;
    vTriangle.hidden = YES;
    self.view.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.5];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self rotateArrowImage];
}



#pragma mark -  UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuse"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuse"];
    }
    cell.textLabel.text = indexPath.row == 0? @"增加" : @"减少";
    [cell.textLabel setFont:[UIFont systemFontOfSize:13.f]];
    return cell;
}

#pragma mark -UIScrollViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [btnSelect setTitle:cell.textLabel.text forState:UIControlStateNormal];
    tbvSelect.hidden = YES;
    vTriangle.hidden = YES;
    btnSelect.selected = NO;
    [self rotateArrowImage];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.f;
}

#pragma mark - ITextField delegate

- (void) textFieldDidChange:(id) sender {
    
    UITextField *_field = (UITextField *)sender;
    NSLog(@"%@",[_field text]);
    money = HDFORMAT((@"%.2f"), [_field text].floatValue);
}

#pragma mark - ITextField delegate

- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView.markedTextRange == nil) {
        NSLog(@"text:%@", textView.text);
    }
    strDescription = textView.text;
}

#pragma mark - event
- (IBAction)cancel:(UIButton *)sender {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (IBAction)save:(UIButton *)sender {
    if (money.length < 1) {
        [HDHelper say:@"请输入金额!"];
        return;
    }else if(strDescription.length < 2) {
        [HDHelper say:@"请输入调价事由"];
        return;
    }
    if (self.finishBlock) {
        NSString *str = [btnSelect.titleLabel.text isEqualToString:@"增加"]? @"1" : @"0";
        self.finishBlock(str, money, strDescription);
    }
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
}

- (IBAction)showTbv:(UIButton *)sender {
    btnSelect.selected = !btnSelect.selected;
    tbvSelect.hidden = btnSelect.selected? NO : YES;
    vTriangle.hidden = tbvSelect.hidden;
    [self rotateArrowImage];
}

- (void)rotateArrowImage {
    // 旋转箭头图片
    imvSelect.transform = CGAffineTransformRotate(imvSelect.transform, M_PI);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [tfAmount resignFirstResponder];
    [tvNote resignFirstResponder];
    if (!tbvSelect.hidden) {
        tbvSelect.hidden = YES;
        vTriangle.hidden = YES;
        [self rotateArrowImage];
        btnSelect.selected = NO;
    }
}

#pragma mark = setter and getter

- (void)setup {
    
    tbvSelect.hidden = YES;
    vTriangle.hidden = YES;
    tbvSelect.layer.masksToBounds = YES;
    tbvSelect.layer.borderWidth   = 1.f;
    tbvSelect.layer.borderColor   = HDCOLOR_GRAY.CGColor;
    
    btnSelect.selected  = NO;
    btnSelect.layer.cornerRadius  = 5.f;
    btnSelect.layer.masksToBounds = YES;
    btnSelect.layer.borderWidth   = 1.f;
    btnSelect.layer.borderColor   = HDCOLOR_GRAY.CGColor;
    
    vM.layer.cornerRadius  = 5.f;
    vM.layer.masksToBounds = YES;
    
    tfAmount.layer.cornerRadius  = 5.f;
    tfAmount.layer.masksToBounds = YES;
    tfAmount.layer.borderWidth   = 1.f;
    tfAmount.layer.borderColor   = HDCOLOR_GRAY.CGColor;
    
    tvNote.layer.cornerRadius  = 5.f;
    tvNote.layer.masksToBounds = YES;
    tvNote.layer.borderWidth   = 1.f;
    tvNote.layer.borderColor   = HDCOLOR_GRAY.CGColor;
    
    btnSave.layer.cornerRadius  = 10.f;
    btnSave.layer.masksToBounds = YES;
    btnSave.layer.borderWidth   = 1.f;
    btnSave.layer.borderColor   = HDCOLOR_GRAY.CGColor;
    btnCancel.layer.cornerRadius  = 10.f;
    btnCancel.layer.masksToBounds = YES;
    btnCancel.layer.borderWidth   = 1.f;
    btnCancel.layer.borderColor   = HDCOLOR_GRAY.CGColor;
    
    [btnSelect setTitle:@"增加" forState:UIControlStateNormal];
    [tfAmount addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

@end
