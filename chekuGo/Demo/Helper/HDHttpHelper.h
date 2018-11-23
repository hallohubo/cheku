//
//  HDHttp.h
//  JianJian
//
//  Created by hufan on 16/6/21.
//  Copyright © 2016年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import <objc/runtime.h>

#define PLATFORM        @"101"          //iOS平台编号
#define PATH_PLIST_INFO [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]
#define MDIC_PLIST_INFO [[NSMutableDictionary alloc] initWithContentsOfFile:PATH_PLIST_INFO]
#define CHANNEL         MDIC_PLIST_INFO[@"Channel"]  //渠道，6：企业版，7：appstore版
#define VERSION         MDIC_PLIST_INFO[@"version"]  //软件版本，传回服务器版本号
#define BUNDLEVERSION   MDIC_PLIST_INFO[@"CFBundleInfoDictionaryVersion"]  //软件build版本
#define APPVERSION      MDIC_PLIST_INFO[@"CFBundleShortVersionString"]      //appstore显示版本
#define BUNDLEID        MDIC_PLIST_INFO[@"CFBundleIdentifier"]

#define JSON(P) [HDHttpHelper jsonObject:P]
#define HDDIC(P) JSON(P)

//#define IP @"http://zuche-local.qring.org/"        //开发
//#define IP @"http://zuche-dev.qring.org/"   //发布
#define IP @"http://wx.chekugo.com/"

@class HDError;

@interface HDHttpHelper : AFHTTPSessionManager{
   
}

@property (nonatomic, strong) NSMutableDictionary *parameters;

+ (HDHttpHelper *)instance;
+ (id)transform:(NSString *)serial toClass:(id)newObj;
+ (id)model:(id)model fromDictionary:(NSDictionary *)dic;
+ (NSArray *)allProperties:(id)model;
+ (NSMutableArray *)dic_arrayWithArray:(NSMutableArray *)ar model:(id)model;
+ (NSMutableArray *)model_arrayWithArray:(NSMutableArray *)ar model:(id)model;

//通用post方法
- (NSURLSessionDataTask *)postPath:(NSString *)path object:(id)newObj finished:(void (^)(HDError *error, id object, BOOL isLast, id data))block;

//通用get方法
- (NSURLSessionDataTask *)getPath:(NSString *)path object:(id)newObj finished:(void (^)(HDError *error, id object, BOOL isLast, id data))block;

//通用put方法
- (NSURLSessionDataTask *)putPath:(NSString *)path object:(id)newObj finished:(void (^)(HDError *error, id object, BOOL isLast, id data))block;


//上传图片post
- (NSURLSessionDataTask *)postFilePath:(NSString *)path data:(NSArray *)datas finished:(void (^)(HDError *error, id data))block;

//同样delete方法
- (NSURLSessionDataTask *)deletePath:(NSString *)path object:(id)newObj finished:(void (^)(HDError *error, id object, BOOL isLast, id json))block;

+ (NSString *)jsonObject:(id)object;

@end

@interface HDError : NSObject

/*!
 @property
 @brief 错误代码
 */
@property (nonatomic) int code;

/*!
 @property
 @brief 错误信息描述
 */
@property (nonatomic, strong) NSString *desc;

/*!
 @method
 @brief 创建一个EMError实例对象
 @param errCode 错误代码
 @param description 错误描述信息
 @result 错误信息描述实例对象
 */
+ (HDError *)errorWithCode:(int)errCode
            andDescription:(NSString *)description;

/*!
 @method
 @brief 通过NSError对象, 生成一个EMError对象
 @param error NSError对象
 @result 错误信息描述实例对象
 */
+ (HDError *)errorWithHDError:(NSError *)error;

@end
