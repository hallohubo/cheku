//
// HDHUD.m
//  DennisHu
//
//  Created by DennisHu on 14-8-15.
//
//

#import "HDHUD.h"

@interface HDHUD () <MBProgressHUDDelegate>

@end

static HDHUD *HDData = NULL;
@implementation HDHUD

+ (HDHUD *)instance{
    @synchronized(self){
        if (HDData) {
            [HDData hiden];
            HDData = nil;
        }
        HDData = [[HDHUD alloc] init];
    }
    return HDData;
}

+ (HDHUD *)showLoading:(NSString *)text on:(UIView *)view {
    HDHUD *manager  = [HDHUD instance];
    manager.hud     = [MBProgressHUD showHUDAddedTo:view animated:YES];
    manager.hud.delegate        = manager;
    manager.hud.labelText       = nil;
    manager.hud.backgroundColor = [UIColor clearColor];
    manager.hud.removeFromSuperViewOnHide = YES;
    return manager;
}


+ (void)showNote:(NSString *)text on:(UIView *)view {
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText       = text;
    hud.mode            = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
}
- (void)hudWasHidden:(MBProgressHUD *)hud {
    
}
- (void)hiden {
    [_hud hide:YES];
}

@end
