//
//  HDRefresh.h
//  JianJian
//
//  Created by Hu Dennis on 15/8/21.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"
#import "EGORefreshTableFooterView.h"

#define HDRefreshInstance [HDRefresh instance]

@interface HDRefresh : NSObject{
    
}
@property (strong) UIScrollView *scrollView;
@property (assign, nonatomic) BOOL isFirstLoadRefresh;
@property (copy) void (^headBlock)(void);
@property (copy) void (^footBlock)(void);
@property (strong) EGORefreshTableHeaderView *refreshHeader;
@property (strong) EGORefreshTableFooterView *refreshFooter;
+ (HDRefresh *)instance;
- (void)reset;
- (void)setHeadRefresh:(UIScrollView *)scroll begin:(void (^)(void))begin;
- (void)setFootRefresh:(UIScrollView *)scroll isLast:(BOOL)isLast begin:(void (^)(void))begin;
- (void)finishReloadingData;
@end
