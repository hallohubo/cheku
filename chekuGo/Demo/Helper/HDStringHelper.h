//
//  HDStringHelper.h
//  Demo
//
//  Created by hufan on 2017/3/16.
//  Copyright © 2017年 hufan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HDStringHelper : NSObject
+ (CGFloat)widthOfString:(NSString*)str font:(UIFont *)font widthMax:(NSInteger)widthMax;
+ (CGFloat)heightOfString:(NSString *)str font:(UIFont *)font width:(CGFloat)w maxHeight:(CGFloat)height;
+ (NSAttributedString *)htmlString:(NSString *)string;
+ (NSRange)searchNumberFromString:(NSString *)str;
@end
