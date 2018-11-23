//
//  UITableViewCell+tableView.m
//  JianJian
//
//  Created by hufan on 16/7/20.
//  Copyright © 2016年 Hu Dennis. All rights reserved.
//

#import "UITableViewCell+tableView.h"

@implementation UITableViewCell (tableView)

- (UITableView *)tableView{
    id view = [self superview];
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    UITableView *tableView = (UITableView *)view;
    return tableView;
}

@end
