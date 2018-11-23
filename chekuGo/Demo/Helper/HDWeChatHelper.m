//
//  HDWeChatHelper.m
//  Demo
//
//  Created by hubo on 2017/12/5.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import "HDWeChatHelper.h"
//#import "WXApi.h"
//#import "WXApiObject.h"

//#define WECHAT_APP_ID @"wx79813547720de782"

@implementation HDWeChatHelper
//+ (void)wechatSetup{
//    [WXApi registerApp:WECHAT_APP_ID];
//}
//+ (void)jumpToPay:(NSDictionary *)dic{
//    if(dic == nil){
//        Dlog(@"Error:dic is nil!");
//        return;
//    }
//    NSMutableString *stamp  = [dic objectForKey:@"timestamp"];
//    //调起微信支付
//    PayReq *req             = [[PayReq alloc] init];
//    req.partnerId           = [dic objectForKey:@"partnerid"];
//    req.prepayId            = [dic objectForKey:@"prepayid"];
//    req.nonceStr            = [dic objectForKey:@"noncestr"];
//    req.timeStamp           = stamp.intValue;
//    req.package             = [dic objectForKey:@"package"];
//    req.sign                = [dic objectForKey:@"sign"];
//    [WXApi sendReq:req];
//    Dlog(@"appid = %@\npartid = %@\nprepayid = %@\nnoncestr = %@\ntimestamp = %ld\npackage = %@\nsign = %@", [dic objectForKey:@"appId"], req.partnerId, req.prepayId, req.nonceStr, (long)req.timeStamp, req.package, req.sign);
//}
@end

