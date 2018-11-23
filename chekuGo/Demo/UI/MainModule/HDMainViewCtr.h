//
//  HDMainViewCtr.h
//  Demo
//
//  Created by hufan on 2017/3/1.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDMainViewCtr : UIViewController

@end

@interface HDBannerModel : NSObject
@property (nonatomic, strong) NSString *createTime;     //"2018-01-25 20:50:33";
@property (nonatomic, strong) NSString *desc;           //"string,\U63cf\U8ff0";
@property (nonatomic, strong) NSString *id;             //服务端回来的是id关键字
@property (nonatomic, strong) NSString *imgUrl;         //"/files/test/2.png";
@property (nonatomic, strong) NSString *lastModifyTime; //"2018-01-25 20:50:33";
@property (nonatomic, strong) NSString *position;       //app;
@property (nonatomic, strong) NSString *url;            //"string,\U8df3\U8f6c\U5730\U5740";

@end
