//
//  HDDate.m
//  JianJian
//
//  Created by hufan on 16/4/13.
//  Copyright © 2016年 Hu Dennis. All rights reserved.
//

#import "HDDateHelper.h"

@implementation HDDateHelper

/** 关于date **/
#pragma mark - time

+ (NSString *)readNowTimeWithFormate:(NSString *)yyyyMMddhhmmss{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter	setDateFormat:yyyyMMddhhmmss];//yyyyMMddhhmmss
    NSString *sTime = [formatter stringFromDate: [NSDate date]];
    return sTime;
}

+ (NSString *)stringWithDate:(NSDate *)date withFormat:(NSString *)yyyyMMddhhmmss{
    if (!date) {
        Dlog(@"警告:传入参数date为空!");
        return nil;
    }
    if (yyyyMMddhhmmss.length == 0) {
        Dlog(@"传入时间格式为空！");
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter	setDateFormat:yyyyMMddhhmmss];
    NSString *sTime=[formatter stringFromDate: date];
    return sTime;
}

+ (NSString *)formatterDate:(NSDate *)date{
    if (!date) {
        Dlog(@"警告:传入参数date为空!");
        return nil;
    }
    return [HDDateHelper stringWithDate:date withFormat:@"yyyy-MM-dd"];
}

+ (NSDate *)dateFromString:(NSString *)sDate{
    if (sDate.length > 0) {
        Dlog(@"传入参数有误");
        return nil;
    }
    return [self dateWithString:sDate formate:@"yyyy.MM.dd"];
}

+ (NSDate *)dateWithString:(NSString *)sTime formate:(NSString *)formate{
    if (sTime.length == 0) {
        Dlog(@"传入时间为空！");
        return nil;
    }
    if (formate.length == 0) {
        Dlog(@"传入时间格式为空！");
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:formate];
    NSDate *date = [formatter dateFromString:sTime];
    return date;
}

+ (NSString *)strinDateWithStringDate:(NSString *)strDate originalFormate:(NSString *)oFormate toFormate:(NSString *)theFormate{
    if (!strDate || strDate.length == 0) {
        Dlog(@"传入时间为空！");
        return nil;
    }
    if (oFormate.length == 0) {
        Dlog(@"传入时间格式“oFormate”为空！");
        return nil;
    }
    if (theFormate.length == 0) {
        Dlog(@"传入目标时间格式“theFormate”为空！");
        return nil;
    }
    NSDate *date0 = [HDDateHelper dateWithString:strDate formate:oFormate];
    if (!date0) {
        Dlog(@"时间转换失败！");
        return nil;
    }
    NSString *str = [HDDateHelper stringWithDate:date0 withFormat:theFormate];
    return str;
}

+ (NSString *)getHumanityTime:(NSDate *)compareDate{
    NSTimeInterval timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result;
    if (timeInterval < 10 * 60) {//10分钟前
        result = [NSString stringWithFormat:@"刚刚"];
    }else if((temp = timeInterval/60) < 60){//10分钟到1小时
        result = [NSString stringWithFormat:@"%d分前", (int)temp];
    }else if((temp = temp/60) < 24){
        result = [NSString stringWithFormat:@"%d小时前", (int)temp];
    }else if((temp = temp/24) < 10){
        result = [NSString stringWithFormat:@"%d天前", (int)temp];
    }else if(temp < 365){
        result = [HDDateHelper stringWithDate:compareDate withFormat:@"MM-dd"];
    }else{
        result = [HDDateHelper stringWithDate:compareDate withFormat:@"yyyy-MM-dd"];
    }
    return  result;
}

+ (NSDate *)addMonth:(NSDate *)basedMonth count:(int)count{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:count];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:basedMonth options:0];
    return newDate;
}

+ (NSDate *)addDay:(NSDate *)basedDate count:(int)count{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:count];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *newDate = [calendar dateByAddingComponents:dateComponents toDate:basedDate options:0];
    return newDate;
}

+ (NSString *)getTheDateOfYearsAgo:(NSUInteger)years{
    NSString *now = [self readNowTimeWithFormate:@"yyyy-MM-dd"];
    int y = [now substringToIndex:4].intValue;
    y = y - (int)years;
    if (y < 0) {
        Dlog(@"Error:传入年数有误，years = %d", (int)years);
        return nil;
    }
    NSString *d = HDFORMAT(@"%@%@", @(y).stringValue, [now substringFromIndex:4]);
    return d;
}

@end
