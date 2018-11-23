 //
//  UIView+LoadFromNib.m
//  HDStudio
//
//  Created by Hu Dennis on 15/1/20.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "UIView+LoadFromNib.h"

@implementation UIView (LoadFromNib)

+ (id)loadFromNib{
    id view = nil;
    NSString *className = NSStringFromClass([self class]);
    NSArray *ar = [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil];
    if ([ar count] > 0) {
        view = ar[0];
    }
    return view;
}

+ (id)getCell:(NSString *)className nibName:(NSString *)nibName{
    Class moduleClass = NSClassFromString(className);
    UITableViewCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:moduleClass]) {
            cell = (UITableViewCell *)obj;
            break;
        }
    }
    return cell;
}
@end
