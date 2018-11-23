//
//  HDRefresh.m
//  JianJian
//
//  Created by Hu Dennis on 15/8/21.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDRefresh.h"

static HDRefresh *instance = nil;

@interface HDRefresh () <UIScrollViewDelegate, EGORefreshTableDelegate>{
}
@property (assign) BOOL isReloading;

@end

@implementation HDRefresh

+ (HDRefresh *)instance{
    @synchronized(self){
        if (instance == nil) {
            instance = [HDRefresh new];
        }
    }
    return instance;
}

- (void)reset{
    [self.refreshHeader removeFromSuperview];
    [self.refreshFooter removeFromSuperview];
    instance = NULL;
}

- (void)setIsFirstLoadRefresh:(BOOL)isFirstLoadRefresh{
    _isFirstLoadRefresh = isFirstLoadRefresh;
    [self setHeaderRefreshView:_scrollView];
}

- (void)setHeadRefresh:(UIScrollView *)scroll begin:(void (^)(void))begin{
    if (!scroll) {
        Dlog(@"传入参数scrollView不能为空！");
        return;
    }
    _scrollView     = scroll;
    self.headBlock  = begin;
    _isFirstLoadRefresh = NO;
    [self setHeaderRefreshView:scroll];
}

- (void)setFootRefresh:(UIScrollView *)scroll isLast:(BOOL)isLast begin:(void (^)(void))begin{
    if (!scroll) {
        Dlog(@"传入参数scrollView不能为空！");
        return;
    }
    _scrollView     = scroll;
    self.footBlock  = begin;
    [self setFooterRefreshView:isLast];
}

-(void)setFooterRefreshView:(BOOL)isLast{
    if (_refreshFooter && [_refreshFooter superview]) {
        [_refreshFooter removeFromSuperview];
    }
    _refreshFooter = nil;
    if (isLast) {
        return;
    }
    CGFloat height = MAX(self.scrollView.contentSize.height, self.scrollView.frame.size.height);
    _refreshFooter = [[EGORefreshTableFooterView alloc] initWithFrame:CGRectMake(0.0f, height, self.scrollView.frame.size.width, self.scrollView.bounds.size.height)];
    _refreshFooter.delegate = self;
    [self.scrollView addSubview:_refreshFooter];
    if (_refreshFooter) {
        [_refreshFooter refreshLastUpdatedDate];
    }
}
#pragma mark - refresh模块
#pragma mark EGORefreshTableDelegate
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos{
    [self beginToReloadData:aRefreshPos];
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
    return _isReloading;
}

- (NSDate *)egoRefreshTableDataSourceLastUpdated:(UIView*)view{
    return [NSDate date];
}

-(void)setHeaderRefreshView:(UIScrollView *)scroll{
    if (_refreshHeader && [_refreshHeader superview]) {
        [_refreshHeader removeFromSuperview];
    }
    _refreshHeader = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.scrollView.bounds.size.height, self.scrollView.frame.size.width, self.scrollView.bounds.size.height)];
    _refreshHeader.delegate = self;
    [self.scrollView addSubview:_refreshHeader];
    [_refreshHeader refreshLastUpdatedDate];
    if (_isFirstLoadRefresh) {
        [_refreshHeader refreshData:scroll];
    }
    
}

- (void)beginToReloadData:(EGORefreshPos)aRefreshPos{
    _isReloading = YES;
    if (aRefreshPos == EGORefreshHeader) {
        if (self.headBlock && _refreshHeader) {
            self.headBlock();
        }
    }else if(aRefreshPos == EGORefreshFooter){
        if (self.footBlock && _refreshHeader) {
            self.footBlock();
        }
    }
}

- (void)finishReloadingData{
    _isReloading = NO;
    if (_refreshHeader) {
        [_refreshHeader egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
    }
    if (_refreshFooter) {
        [_refreshFooter egoRefreshScrollViewDataSourceDidFinishedLoading:self.scrollView];
    }
}
@end
