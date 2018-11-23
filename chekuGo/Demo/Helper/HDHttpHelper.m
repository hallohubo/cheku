//
//  HDHttp.m
//  JianJian
//
//  Created by hufan on 16/6/21.
//  Copyright © 2016年 Hu Dennis. All rights reserved.
//

#import "HDHttpHelper.h"
#import "LDCry.h"
#import "BaseFunc.h"

@interface HDHttpHelper (){

}

@end

@implementation HDHttpHelper

+ (instancetype)instance{
    static HDHttpHelper *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 70.;
        configuration.timeoutIntervalForResource = 70.;
        NSString *sip = IP;
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:sip] sessionConfiguration:configuration];
    });
    [_sharedClient setDefault];
    return _sharedClient;
}

- (void)setDefault{
    _parameters = [NSMutableDictionary new];
    /*设置默认参数*/
    [_parameters setValue:@"1"                      forKey:@"Source"];
    //[_parameters setValue:PLATFORM                  forKey:@"Platform"];
    [_parameters setValue:HDSTR([HDHelper uuid])    forKey:@"IMEI"];
    [_parameters setValue:HDSTR(APPVERSION)         forKey:@"Version"];
    NSString *token = HDGI.token;
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    if (token) {
        [self.requestSerializer setValue:HDSTR(token) forHTTPHeaderField:@"token"];
    }
}

- (void)setParameters:(NSMutableDictionary *)parameters{
    [_parameters addEntriesFromDictionary:parameters];
}
#pragma mark - 通用请求get方法
- (NSURLSessionDataTask *)getPath:(NSString *)path object:(id)newObj finished:(void (^)(HDError *error, id object, BOOL isLast, id json))block{
    HDError *e = [HDError new];
    if ([path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    NSString *p = HDFORMAT(@"app/%@", path);
    if ([HDGI.loginUser.role isEqualToString:@"Main"]) {
        p = HDFORMAT(@"app-main/%@", path);
    }
    Dlog(@"header = %@", self.requestSerializer.HTTPRequestHeaders);
    NSURLSessionDataTask *task = [self GET:p parameters:_parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Dlog(@"%@ http = %@", path, task.response.URL);
        NSError *nserror = nil;
        NSDictionary *dic_json = responseObject;
        Dlog(@"%@ json = %@", path, dic_json);
        if (!dic_json) {
            e.desc = HDFORMAT(@"服务器返回数据有误，错误码:%@01", path);
            block(e, nil, NO, nil);
            return;
        }
        NSString    *code       = JSON(dic_json[@"code"]);
        NSString    *msg        = JSON(dic_json[@"msg"]);
        NSString    *errorCode  = JSON(dic_json[@"errCode"]);
        NSObject    *data       = dic_json[@"data"];
        BOOL        isLast      = NO;
        if (code.intValue != 0) {
            e.desc = msg;
            e.code = errorCode.intValue;
            block(e, nil, NO, nil);
            return;
        }
        if (!data || [data isKindOfClass:[NSNull class]]) {
            e.desc = HDFORMAT(@"服务器返回数据有误，错误码:%@02", path);
            e.code = code.intValue;
        }
        if (!newObj) {//结果只返回成功或失败，newObjectc传回result值，调用者爱用不用
            block(nil, nil, NO, data);
            return;
        }
        if (![data isKindOfClass:[NSDictionary class]]) {//非字典，错误
            block(nil, nil, NO, data);
            return;
        }
        NSDictionary *dic = (NSDictionary *)data;
        NSArray *allKeys = [dic allKeys];
        if (allKeys.count == 0) {//result 字典无值
            block(nil, nil, NO, data);
            return;
        }
        if ([dic[@"content"] isKindOfClass:[NSArray class]] && dic[@"pageSize"]) {//列表情况
            NSArray *list = dic[@"content"];
            NSMutableArray *mar = [NSMutableArray new];
            for (int i = 0; i < list.count; i++) {
                NSDictionary *dic_model = list[i];
                id o = [HDHttpHelper model:[[newObj class] new] fromDictionary:dic_model];
                [mar addObject:o];
            }
            int pageIndex = JSON(dic[@"pageIndex"]).intValue;
            int pageNumber = JSON(dic[@"pageNumber"]).intValue;
            BOOL isLastPage = pageIndex == pageNumber;
            block(nil, mar, isLastPage, dic);
            return;
        }
        //字典情况
        id obj = [HDHttpHelper model:newObj fromDictionary:dic];
        block(nil, obj, NO, dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        Dlog(@"网络请求失败 code = %d.描述：%@", (int)error.code, error.localizedDescription);
        Dlog(@"%@ http = %@", path, task.response.URL);
        e.desc  = HDFORMAT(@"%@:%@", path, error.localizedDescription);
        e.code  = (int)error.code;
        if (error.code == -999) {//用户主动取消，如请求中，用户跳转其他页面，即主动取消请求
            e.code = -999;
            e.desc = HDFORMAT(@"%@:%@", path, error.localizedDescription);
        }
        block(e, nil, NO, nil);
        return ;
    }];
    [task resume];
    return task;
}
#pragma mark - 通用请求post方法
- (NSURLSessionDataTask *)postPath:(NSString *)path object:(id)newObj finished:(void (^)(HDError *error, id object, BOOL isLast, id json))block
{
    HDError *e = [HDError new];
    NSString *pathCode;
    if (path.length > 3) {
        pathCode = [path substringFromIndex:3];
    }
    if ([path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    NSString *p = HDFORMAT(@"app/%@", path);
    if ([HDGI.loginUser.role isEqualToString:@"Main"]) {
        p = HDFORMAT(@"app-main/%@", path);
    }
    Dlog(@"header = %@，parameters = %@", self.requestSerializer.HTTPRequestHeaders, _parameters);
    NSURLSessionDataTask *task = [self POST:p parameters:_parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Dlog(@"%@ http = %@", path, task.response.URL);
        NSError *nserror = nil;
        NSDictionary *dic_json = responseObject;
        Dlog(@"%@ json = %@", path, dic_json);
        if (!dic_json) {
            e.desc = HDFORMAT(@"服务器返回数据有误，错误码:%@01", pathCode);
            block(e, nil, NO, nil);
            return;
        }
        NSString    *code       = JSON(dic_json[@"code"]);
        NSString    *description= JSON(dic_json[@"msg"]);
        NSString    *errorCode  = JSON(dic_json[@"errCode"]);
        NSObject    *data        = dic_json[@"data"];
        BOOL        isLast      = NO;
        if (code.intValue != 0) {
            e.desc = description;
            e.code = errorCode.intValue;
            block(e, nil, NO, nil);
            return;
        }
        if (!data || [data isKindOfClass:[NSNull class]]) {
            e.desc = HDFORMAT(@"服务器返回数据有误，错误码:%@02", pathCode);
            e.code = code.intValue;
        }
        if (!newObj) {//结果只返回成功或失败，newObjectc传回result值，调用者爱用不用
            block(nil, nil, NO, data);
            return;
        }
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)data;
            NSArray *allKeys = [dic allKeys];
            if (allKeys.count == 0) {//result 字典无值
                block(nil, nil, NO, data);
                return;
            }
            //取最多value的字典
            NSDictionary *the_dic = [NSDictionary new];
            for (int i = 0; i < allKeys.count; i++) {
                NSString *key = allKeys[i];
                id obj = [dic objectForKey:key];
                if (![obj isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSDictionary *d = obj;
                if ([d allValues].count > [the_dic allValues].count) {
                    the_dic = d;
                }
            }
            id obj = [HDHttpHelper model:newObj fromDictionary:the_dic];
            block(nil, obj, NO, dic);
            return;
        }
        block(nil, nil, NO, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        Dlog(@"网络请求失败 code = %d.描述：%@", (int)error.code, error.localizedDescription);
        Dlog(@"%@ http = %@", path, task.response.URL);
        e.desc  = HDFORMAT(@"%@:%@", path, error.localizedDescription);
        e.code  = (int)error.code;
        if (error.code == -999) {//用户主动取消，如请求中，用户跳转其他页面，即主动取消请求
            e.code = 0;
            e.desc = HDFORMAT(@"%@:%@", path, error.localizedDescription);
        }
        block(e, nil, NO, nil);
        return ;
    }];
    [task resume];

    return task;
}

#pragma mark - 请求Post图片方法
- (NSURLSessionDataTask *)postFilePath:(NSString *)path data:(UIImage *)img finished:(void (^)(HDError *error, id object))block{
    HDError *e = [HDError new];
    if (!img) {
        Dlog(@"Error:image is nil");
        e.desc = @"image is nil";
        block(e, nil);
        return nil;
    }
    if ([path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    NSString *p = HDFORMAT(@"app/%@", path);
    if ([HDGI.loginUser.role isEqualToString:@"Main"]) {
        p = HDFORMAT(@"app-main/%@", path);
    }
    Dlog(@"header = %@", self.requestSerializer.HTTPRequestHeaders);
    NSURLSessionDataTask *task = [self POST:p parameters:_parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *data = UIImageJPEGRepresentation(img, .5);
        [formData appendPartWithFileData:data name:HDFORMAT(@"file") fileName:@"jpg" mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        Dlog(@"progress = %f, totalUnitCount = %f", uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Dlog(@"%@ http = %@", path, task.response.URL);
        NSDictionary *dic_json = responseObject;
        Dlog(@"%@ json = %@", path, dic_json);
        if (!dic_json) {
            e.desc = HDFORMAT(@"网络出错，请稍后再试(%@)", path);
            block(e, nil);
            return;
        }
        NSString    *code       = JSON(dic_json[@"code"]);
        NSObject    *data       = dic_json[@"data"];
        NSString    *message    = JSON(dic_json[@"msg"]);
        NSString    *errCode    = JSON(dic_json[@"errCod"]);
        if (code.intValue != 0 || !data || [data isKindOfClass:[NSNull class]]) {
            e.desc = HDFORMAT(@"网络数据有误，错误码:%@%d，错误描述：%@", path, errCode.intValue, message);
            block(e, nil);
            return;
        }
        block(nil, data);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        Dlog(@"网络请求失败 failed %d", (int)error.code);
        Dlog(@"%@ http = %@", path, task.response.URL);
        e.desc  = error.localizedDescription;;
        e.code  = (int)error.code;
        if (error.code == -999) {
            e.code = 0;
            e.desc = error.localizedDescription;
        }
        block(e, nil);
    }];
    [task resume];
    return task;
}

#pragma mark - 通用put请求更新方法

- (NSURLSessionDataTask *)putPath:(NSString *)path object:(id)newObj finished:(void (^)(HDError *error, id object, BOOL isLast, id json))block
{
    HDError *e = [HDError new];
    NSString *pathCode;
    if ([path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    NSString *p = HDFORMAT(@"app/%@", path);
    if ([HDGI.loginUser.role isEqualToString:@"Main"]) {
        p = HDFORMAT(@"app-main/%@", path);
    }
    Dlog(@"header = %@，parameters = %@", self.requestSerializer.HTTPRequestHeaders, _parameters);
    NSURLSessionDataTask *task = [self PUT:p parameters:_parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Dlog(@"%@ http = %@", path, task.response.URL);
        NSError *nserror = nil;
        NSDictionary *dic_json = responseObject;
        Dlog(@"%@ json = %@", path, dic_json);
        if (!dic_json) {
            e.desc = HDFORMAT(@"服务器返回数据有误,responseObject为空。");
            block(e, nil, NO, nil);
            return;
        }
        NSString    *code       = JSON(dic_json[@"code"]);
        NSString    *description= JSON(dic_json[@"msg"]);
        NSString    *errorCode  = JSON(dic_json[@"errCode"]);
        NSObject    *data        = dic_json[@"data"];
        BOOL        isLast      = NO;
        if (code.intValue != 0) {
            e.desc = description;
            e.code = errorCode.intValue;
            block(e, nil, NO, nil);
            return;
        }
        if (!data || [data isKindOfClass:[NSNull class]]) {
            e.desc = HDFORMAT(@"服务器返回数据有误，data为空。");
            e.code = code.intValue;
        }
        if (!newObj) {//结果只返回成功或失败，newObjectc传回result值，调用者爱用不用
            block(nil, nil, NO, data);
            return;
        }
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)data;
            NSArray *allKeys = [dic allKeys];
            if (allKeys.count == 0) {//result 字典无值
                block(nil, nil, NO, data);
                return;
            }
            //取最多value的字典
            NSDictionary *the_dic = [NSDictionary new];
            for (int i = 0; i < allKeys.count; i++) {
                NSString *key = allKeys[i];
                id obj = [dic objectForKey:key];
                if (![obj isKindOfClass:[NSDictionary class]]) {
                    continue;
                }
                NSDictionary *d = obj;
                if ([d allValues].count > [the_dic allValues].count) {
                    the_dic = d;
                }
            }
            id obj = [HDHttpHelper model:newObj fromDictionary:the_dic];
            block(nil, obj, NO, dic);
            return;
        }
        block(nil, nil, NO, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        Dlog(@"网络请求失败 code = %d.描述：%@", (int)error.code, error.localizedDescription);
        Dlog(@"%@ http = %@", path, task.response.URL);
        e.desc  = HDFORMAT(@"%@:%@", path, error.localizedDescription);
        e.code  = (int)error.code;
        if (error.code == -999) {//用户主动取消，如请求中，用户跳转其他页面，即主动取消请求
            e.code = 0;
            e.desc = HDFORMAT(@"%@:%@", path, error.localizedDescription);
        }
        block(e, nil, NO, nil);
        return ;
    }];
    [task resume];
    return task;
}

#pragma mark - 通用delete请求更新方法

- (NSURLSessionDataTask *)deletePath:(NSString *)path object:(id)newObj finished:(void (^)(HDError *error, id object, BOOL isLast, id json))block{
    HDError *e = [HDError new];
    if ([path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    NSString *p = HDFORMAT(@"app/%@", path);
    if ([HDGI.loginUser.role isEqualToString:@"Main"]) {
        p = HDFORMAT(@"app-main/%@", path);
    }
    Dlog(@"header = %@", self.requestSerializer.HTTPRequestHeaders);
    NSURLSessionDataTask *task = [self DELETE:p parameters:_parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        Dlog(@"%@ http = %@", path, task.response.URL);
        NSError *nserror = nil;
        NSDictionary *dic_json = responseObject;
        Dlog(@"%@ json = %@", path, dic_json);
        if (!dic_json) {
            e.desc = HDFORMAT(@"服务器返回数据有误，错误码:%@01", path);
            block(e, nil, NO, nil);
            return;
        }
        NSString    *code       = JSON(dic_json[@"code"]);
        NSString    *msg        = JSON(dic_json[@"msg"]);
        NSString    *errorCode  = JSON(dic_json[@"errCode"]);
        NSObject    *data       = dic_json[@"data"];
        BOOL        isLast      = NO;
        if (code.intValue != 0) {
            e.desc = msg;
            e.code = errorCode.intValue;
            block(e, nil, NO, nil);
            return;
        }
        if (!data || [data isKindOfClass:[NSNull class]]) {
            e.desc = HDFORMAT(@"服务器返回数据有误，错误码:%@02", path);
            e.code = code.intValue;
        }
        if (!newObj) {//结果只返回成功或失败，newObjectc传回result值，调用者爱用不用
            block(nil, nil, NO, data);
            return;
        }
        if (![data isKindOfClass:[NSDictionary class]]) {//非字典，错误
            block(nil, nil, NO, data);
            return;
        }
        NSDictionary *dic = (NSDictionary *)data;
        NSArray *allKeys = [dic allKeys];
        if (allKeys.count == 0) {//result 字典无值
            block(nil, nil, NO, data);
            return;
        }
        if ([dic[@"content"] isKindOfClass:[NSArray class]] && dic[@"pageSize"]) {//列表情况
            NSArray *list = dic[@"content"];
            NSMutableArray *mar = [NSMutableArray new];
            for (int i = 0; i < list.count; i++) {
                NSDictionary *dic_model = list[i];
                id o = [HDHttpHelper model:[[newObj class] new] fromDictionary:dic_model];
                [mar addObject:o];
            }
            int pageIndex = JSON(dic[@"pageIndex"]).intValue;
            int pageNumber = JSON(dic[@"pageNumber"]).intValue;
            BOOL isLastPage = pageIndex == pageNumber;
            block(nil, mar, isLastPage, dic);
            return;
        }
        //字典情况
        id obj = [HDHttpHelper model:newObj fromDictionary:dic];
        block(nil, obj, NO, dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        Dlog(@"网络请求失败 code = %d.描述：%@", (int)error.code, error.localizedDescription);
        Dlog(@"%@ http = %@", path, task.response.URL);
        e.desc  = HDFORMAT(@"%@:%@", path, error.localizedDescription);
        e.code  = (int)error.code;
        if (error.code == -999) {//用户主动取消，如请求中，用户跳转其他页面，即主动取消请求
            e.code = -999;
            e.desc = HDFORMAT(@"%@:%@", path, error.localizedDescription);
        }
        block(e, nil, NO, nil);
        return ;
    }];
    [task resume];
    return task;
}

+ (NSString *)getTheArrayKey:(NSDictionary *)dic{
    if (dic.count == 0 || !dic) {
        return nil;
    }
    NSArray *ar = [dic allKeys];
    NSString *key = ar[0];
    for (int i = 0; i < ar.count; i++) {
        NSString *k = ar[i];
        if ([dic[k] isKindOfClass:[NSArray class]]) {
            key = k;
            break;
        }
    }
    return key;
}

#pragma mark - runtime
+ (id)model:(id)model fromDictionary:(NSDictionary *)dic{
    if (!model || !dic || dic.count == 0) {
        Dlog(@"传入参数model或dic为空！");
        return nil;
    }
    NSArray *ar_properties = [self allProperties:model];
    for (int i = 0; i < ar_properties.count; i++) {
        NSString *sPropertyName = ar_properties[i];
        if (sPropertyName.length == 0) {
            NSLog(@"Error:Get property name false!");
            continue;
        }
        if (!dic[sPropertyName]) {
            continue;
        }
        if ([dic[sPropertyName] isKindOfClass:[NSDictionary class]] || [dic[sPropertyName] isKindOfClass:[NSArray class]]) {//如果是嵌套的字典或数组
            id d = dic[sPropertyName];
            [model setValue:d forKey:sPropertyName];
        }else{//字符串
            NSString *s = [self jsonObject:dic[sPropertyName]];
            s = [self changeBr2n:s];
            [model setValue:s forKey:sPropertyName];
        }
    }
    return model;
}

+ (NSString *)changeBr2n:(NSString *)s{
    if (s.length == 0) {
        return @"";
    }
    s = [s stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, s.length)];
    s = [s stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, s.length)];
    s = [s stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, s.length)];
    s = [s stringByReplacingOccurrencesOfString:@"</b>" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, s.length)];
    s = [s stringByReplacingOccurrencesOfString:@"<b>" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, s.length)];
    s = [s stringByReplacingOccurrencesOfString:@"<br/" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, s.length)];
    s = [s stringByReplacingOccurrencesOfString:@"&nbsp" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, s.length)];
    return s;
}

+ (NSArray *)allProperties:(id)model{
    NSMutableArray *allNames    = [[NSMutableArray alloc] init];
    unsigned int propertyCount  = 0;
    NSString *sClass = NSStringFromClass([model class]);
    objc_property_t *propertys  = class_copyPropertyList(objc_getClass([sClass UTF8String]), &propertyCount);
    for (int i = 0; i < propertyCount; i ++) {
        objc_property_t property   = propertys[i];
        const char *propertyName   = property_getName(property);
        [allNames addObject:[NSString stringWithUTF8String:propertyName]];
    }
    return allNames;
}

+ (NSMutableArray *)dic_arrayWithArray:(NSMutableArray *)ar model:(id)model{
    NSMutableArray *mar = [NSMutableArray new];
    for (int i = 0; i < ar.count; i++) {
        id m = ar[i];
        NSDictionary *d = [NSMutableDictionary new];
        NSArray *properties = [HDHttpHelper allProperties:model];
        for (int j = 0; j < properties.count; j++) {
            NSString *key = properties[j];
            NSString *value = [m valueForKey:key];
            [d setValue:HDSTR(value) forKey:key];
        }
        [mar addObject:d];
    }
    return mar;
}

+ (NSMutableArray *)model_arrayWithArray:(NSMutableArray *)ar model:(id)model{
    NSMutableArray *mar = [NSMutableArray new];
    for (int i = 0; i < ar.count; i++) {
        NSDictionary *d = ar[i];
        id m = [HDHttpHelper model:[[model class] new] fromDictionary:d];
        [mar addObject:m];
    }
    return mar;
}

+ (id)transform:(NSString *)serial toClass:(id)newObj{
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:[serial dataUsingEncoding:kCFStringEncodingUTF8] options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        Dlog(@"error: %@", error.description);
        return nil;
    }
    if ([result isKindOfClass:[NSArray class]]) {
        NSArray *list = (NSArray *)result;
        NSMutableArray *mar = [NSMutableArray new];
        for (int i = 0; i < list.count; i++) {
            NSDictionary *dic = list[i];
            id obj = [[newObj class] new];
            obj = [HDHttpHelper model:newObj fromDictionary:dic];
            [mar addObject:obj];
        }
        return mar;
    }
    id obj = [HDHttpHelper model:newObj fromDictionary:result];
    return obj;
}

+ (NSString *)jsonObject:(id)object{
    if ([object isKindOfClass:[NSNull class]]) {
        object = @"";
    }
    NSString *s = HDFORMAT(@"%@", object);
    BOOL isNull1 = [s isEqualToString:@"<null>"] || [s isEqualToString:@"(null)"] || [s isEqualToString:@"null"];
    BOOL isNull2 = [s isEqualToString:@"<NULL>"] || [s isEqualToString:@"(NULL)"] || [s isEqualToString:@"NULL"];
    if (isNull1 || isNull2 || !object) {
        return @"";
    }else{
        return s;
    }
}
@end



@implementation HDError

+ (HDError *)errorWithCode:(int)errCode andDescription:(NSString *)description{
    return [[self alloc] initWithCode:errCode desc:description];
}

- (id)initWithCode:(int)code desc:(NSString *)desc{
    if (self = [super init]) {
        self.code   = code;
        self.desc   = desc;
    }
    return self;
}
+ (HDError *)errorWithHDError:(NSError *)error{
    return [self alloc];
}
@end
