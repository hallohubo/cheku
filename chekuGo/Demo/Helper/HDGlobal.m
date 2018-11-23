//
//  HDGlobleInfo.m
//  HDStudio
//
//  Created by Hu Dennis on 14/12/12.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import "HDGlobal.h"

static HDGlobal *pData = NULL;
@implementation HDGlobal

+ (HDGlobal *)instance{
    @synchronized(self){
        if (pData == NULL){
            pData = [[HDGlobal alloc] init];
        }
    }
    return pData;
}

- (void)reset{
    pData = NULL;
}

#pragma mark - UITabBarControllerDelegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    tabBarController.navigationController.navigationBarHidden = YES;
    NSUInteger select = tabBarController.selectedIndex;
    NSLog(@"shouldSelect_selectTabIndex = %d", (int)select);
    return YES;
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    NSUInteger select = tabBarController.selectedIndex;
    NSLog(@"didSelect_selectTabIndex = %d", (int)select);
    tabBarController.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:HDNOTI_DID_TAP_TABBAR_INDEX object:nil userInfo:@{@"index": @(select)}];
}


@end
