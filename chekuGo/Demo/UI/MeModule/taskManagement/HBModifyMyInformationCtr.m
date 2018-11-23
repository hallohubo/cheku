//
//  HBModifyMyInformationCtr.m
//  Demo
//
//  Created by hubo on 2017/11/28.
//Copyright © 2017年 hufan. All rights reserved.
//

#import "HBModifyMyInformationCtr.h"

@interface HBModifyMyInformationCtr (){
    IBOutlet UITextField *tf_;
    NSURLSessionDataTask *task;
    HDHUD       *hud;
    NSString    *title;
    NSString    *defaultValue;
    NSString    *ishidden;
}
@end

@implementation HBModifyMyInformationCtr


- (instancetype)initWithTitle:(NSString *)tile defaultValue:(NSString *)value isEdited:(BOOL)isEdited {
    self = [super init];
    if (self) {
        title           = tile;
        defaultValue    = value;
        ishidden        = isEdited ? @"YES" : @"NO";
        tf_.enabled     = isEdited;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
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

#pragma mark - event
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)save:(id)sender {
    if (!tf_.text.length > 0) {
        [HDHelper say:@"输入内容不能为空!"];  
        return;
    }else if (self.HBModifyMyInformationBlock) {
        [self.view endEditing:YES];
        self.HBModifyMyInformationBlock(tf_.text);
    }
}

#pragma mark - setter
- (void)setup{
    self.title      = title;
    tf_.text        = defaultValue;
    tf_.placeholder = title;
    [tf_ becomeFirstResponder];
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(save:)];
    [anotherButton setTintColor:HDCOLOR_THEME];
    self.navigationItem.rightBarButtonItem  = anotherButton;
    [anotherButton setTitle:([ishidden isEqualToString:@"YES"]? @"保存": @"" )];
    [anotherButton setEnabled:[ishidden isEqualToString:@"YES"]];
}

@end



