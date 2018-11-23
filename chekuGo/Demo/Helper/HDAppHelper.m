//
//  HDAppHelper.m
//  Demo
//
//  Created by hufan on 2017/2/28.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import "HDAppHelper.h"
#import "HDMainViewCtr.h"
#import "HDCarportCtr.h"
#import "HDMeViewCtr.h"

#define USER_TOKEN @"USER_TOKEN"

#define ORIGINAL_IMAGE(point) [HDIMAGE(point) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]

@implementation HDAppHelper

+ (UIViewController *)builder{
    HDMainViewCtr *main = [HDMainViewCtr new];
    HDCarportCtr *carport = [HDCarportCtr new];
    UINavigationController *me   = [[UINavigationController alloc] initWithRootViewController:[HDMeViewCtr new]];
    main.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"主页"
                                                    image:HDIMAGE(@"tab_main")
                                            selectedImage:ORIGINAL_IMAGE(@"tab_mainHi")];
    carport.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"车库"
                                                    image:HDIMAGE(@"tab_discover")
                                            selectedImage:ORIGINAL_IMAGE(@"tab_discoverHi")];
    me.tabBarItem   = [[UITabBarItem alloc] initWithTitle:@"我的"
                                                    image:HDIMAGE(@"meTabbarDark")
                                            selectedImage:ORIGINAL_IMAGE(@"meTabbarHi")];
    UITabBarController *tab = [[UITabBarController alloc] init];
    tab.viewControllers = @[main, carport, me];
    [tab.tabBar setBackgroundImage:[HDIMAGE(@"tab_back") alpha:0.7]];
    for (int i = 0; i < tab.tabBar.items.count; i++){//用图片的颜色
        UITabBarItem *tabItem = tab.tabBar.items[i];
        tabItem.image = [tabItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    [tab.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]} forState:UIControlStateNormal];
    [tab.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName: HDCOLOR_THEME} forState:UIControlStateSelected];
    [tab.tabBar setTintColor:HDCOLOR_THEME];
    [tab.tabBar setTranslucent:NO];
    [tab.tabBar setBackgroundColor:[UIColor whiteColor]];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tab];
    nav.navigationBarHidden = YES;
    tab.delegate = HDGI;
    HDGI.nav = nav;
    return nav;
}

+ (void)setAppearence{
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"white_dot"] forBarMetrics:UIBarMetricsDefault];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [UIColor blackColor], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:17.0f], NSFontAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:dic];
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:14.0]} forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-150, 0) forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"back0"]];
    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back0"]];
}

+ (id)readTokenFromLocal{
    NSString *token = [[NSUserDefaults standardUserDefaults] valueForKey:USER_TOKEN];
    return token;
}

+ (BOOL)saveTokenToLocal:(NSString *)token{
    if (!token || token.length == 0) {
        Dlog(@"Error:token is nil");
        return NO;
    }
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:USER_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}

+ (void)clearTokenFromLocal{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USER_TOKEN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
