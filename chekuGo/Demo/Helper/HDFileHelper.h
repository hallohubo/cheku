//
//  HDFileHelper.h
//  Demo
//
//  Created by hufan on 2017/12/11.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDFileHelper : NSObject

/*
 Document文件夹路径，
 内容：可以将应用程序的数据文件保存在此目录下。
 不过这些数据类型仅限于不可再生的数据，可再生的数据文件应该存放在Library/Cache目录下。
 苹果建议将程序中建立的或在程序中浏览到的文件数据保存在该目录下。
 iTunes和iCloud：备份到iTunes或iCloud。
 */
+ (NSString *)documentPath;

/*
 返回Library路径
 1、苹果建议用来存放默认设置或其它状态信息。
 2、是否会被iTunes同步：是
 但是要除了Caches子目录外
 */
+ (NSString *)libraryPath;

/*
 返回caches路径
 1、主要是缓存文件，用户使用过程中缓存都可以保存在这个目录中。
 前面说过，Documents目录用于保存不可再生的文件，那么这个目录就用于保存那些可再生的文件，比如网络请求的数据。
 鉴于此，应用程序通常还需要负责删除这些文件。
 ②是否会被iTunes同步：否。
 */
+ (NSString *)cachesPath;

/*
 1、主要是缓存文件，用户使用过程中缓存都可以保存在这个目录中。
 前面说过，Documents目录用于保存不可再生的文件，那么这个目录就用于保存那些可再生的文件，比如网络请求的数据。
 鉴于此，应用程序通常还需要负责删除这些文件。
 2、是否会被iTunes同步，否。
 */
+ (NSString *)tmpPath;

/*
 返回Preference路径
 1、各种临时文件，保存应用再次启动时不需要的文件。
 而且，当应用不再需要这些文件时应该主动将其删除，因为该目录下的东西随时有可能被系统清理掉，
 目前已知的一种可能清理的原因是系统磁盘存储空间不足的时候。
 2、是否会被iTunes同步：否
 */
+ (NSString *)preferencePath;

//移除某个文件，输入完整的路径+文件名
+ (BOOL)removeFileWithPath:(NSString *)path;

//返回文件夹里所有文件的大小和，返回多少M
+ (float )folderSizeAtPath:(NSString *)folderPath;

+ (NSString *)getCacheSizeWithFilePath:(NSString *)path;
+ (BOOL)clearCacheWithFilePath:(NSString *)path;

@end
