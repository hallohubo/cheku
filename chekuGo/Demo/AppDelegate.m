//
//  AppDelegate.m
//  Demo
//
//  Created by hufan on 2017/2/28.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import "AppDelegate.h"
#import "HDAppHelper.h"
#import "HDLoginViewCtr.h"
#import "HDUMHelper.h"
#import "HDUserModel.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [HDAppHelper setAppearence];
    [HDUMHelper setupAnalytics];
    [HDUMHelper setupSocial];
    [self setRootController];
    return YES;
}

- (void)setRootController{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    HDLoginUserModel *model = [HDLoginUserModel readFromLocal];
    HDGI.loginUser  = model;
    HDGI.token = [HDAppHelper readTokenFromLocal];
    NSString *token = HDGI.token;
    Dlog(@"token = %@", token);
    if (token.length > 0) {//已经登录过
        self.window.rootViewController = [HDAppHelper builder];
    }else{
        self.window.rootViewController = [HDLoginViewCtr new];
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (TARGET_IPHONE_SIMULATOR) {
       
    }
    if (!HDGI.loginUser) {
        HDLoginUserModel *model = [HDLoginUserModel readFromLocal];
        HDGI.loginUser  = model;
    }
    if (HDGI.token.length == 0) {
        HDGI.token = [HDAppHelper readTokenFromLocal];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// 支持所有iOS系统
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    return result;
}


@end









