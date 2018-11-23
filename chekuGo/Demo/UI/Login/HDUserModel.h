//;    //
//;    //  HDUserModel.h
//;    //  Demo
//;    //
//;    //  Created by hufan on 2017/3/8.
//;    //  Copyright © 2017年 hufan. All rights reserved.
//;    //

#import <Foundation/Foundation.h>

@interface HDUserModel : NSObject

@end

@interface HDLoginUserModel : NSObject
@property (nonatomic, strong) NSString *companyId;      //1,
@property (nonatomic, strong) NSString *companyName;    //分公司名称
@property (nonatomic, strong) NSString *createTime;     //null,
@property (nonatomic, strong) NSString *ID;             //1516831343000,
@property (nonatomic, strong) NSString *identity;       //"管理员",
@property (nonatomic, strong) NSString *lastModifyTime; //null,
@property (nonatomic, strong) NSString *note;           //"",
@property (nonatomic, strong) NSString *parentCompanyId;//1,
@property (nonatomic, strong) NSString *password;       //"",
@property (nonatomic, strong) NSString *phone;          //"18812112212",
@property (nonatomic, strong) NSString *realname;       //"张三",
@property (nonatomic, strong) NSString *role;           //"角色",
@property (nonatomic, strong) NSString *username;       //"usernamezs"
+ (id)readFromLocal;
- (void)saveToLocal;
+ (void)clearFromLocal;
@end
