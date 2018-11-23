//
//  HDNullView.m
//  JianJian
//
//  Created by hufan on 16/6/30.
//  Copyright © 2016年 Hu Dennis. All rights reserved.
//

#import "HDNullView.h"

@implementation HDNullView

- (id)init{
    if ([super init ]) {
        [self draw];
    }
    return self;
}
- (void)doTouchNullAction{
    if (self.touchNullViewAction) {
        self.touchNullViewAction();
    }
}
- (void)draw{
    UILabel *lb         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    lb.textColor        = [UIColor lightGrayColor];
    lb.text             = @"暂无数据";
    lb.textAlignment    = NSTextAlignmentCenter;
    lb.font             = HDFONT;
    [self addSubview:lb];
    [lb makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(150, 20));
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame   = CGRectMake(0, 0, 10, 10);
    [btn setBackgroundImage:HDIMAGE(@"v_null") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(doTouchNullAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    [btn makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 66.7));
        make.centerX.equalTo(self);
        make.bottom.equalTo(lb.top).offset(-20);
    }];
}

@end
