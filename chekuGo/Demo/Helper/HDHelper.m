//
//  HDUtility.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-6.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "HDHelper.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "CommonCrypto/CommonDigest.h"

#define TAG_SHOW        0
#define TAG_SAY         1
#define TAG_SAY_CUSTOM  2
#define TAG_INPUT       3

#define UUID_KEY @"UUID_KEY"

static HDHelper *utility = nil;

@implementation HDHelper

+ (HDHelper *)instance{
    @synchronized(self){
        if (utility == nil) {
            utility = [HDHelper new];
        }
    }
    return utility;
}

- (void)reset{
    utility = NULL;
}

+ (NSDictionary *)getConectedWIFI{
    NSDictionary *dic = [[NSDictionary alloc] init];
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);  //单个数据info[@"SSID"]; info[@"BSSID"];
        if (info && [info count]) {
            dic = (NSDictionary *)info;
            return dic;
        }
    }
    return nil;
}

+ (NSString *)uuid{
    if (TARGET_OS_SIMULATOR) {
        return @"DEF2EB11-6C33-4ED1-AA69-85EC4943705E";
    }
    NSString *sUUID = [[NSUserDefaults standardUserDefaults] objectForKey:UUID_KEY];
    if (sUUID && sUUID.length > 0) {
        return sUUID;
    }
    UIDevice *device    = [UIDevice currentDevice];
    sUUID               = device.identifierForVendor.UUIDString;
    Dlog(@"uuid = %@", sUUID);
    if (sUUID && sUUID.length > 0) {
        NSError *error = nil;
        [[NSUserDefaults standardUserDefaults] setObject:sUUID forKey:UUID_KEY];//本地也存一份
        [[NSUserDefaults standardUserDefaults] synchronize];
        return sUUID;
    }
    return nil;
}

#pragma mark - UIAlertView
+ (void)mbSay:(NSString *)sMsg{
    [self mbSay:sMsg delay:1.f];
}

+ (void)mbSay:(NSString *)sMsg delay:(CGFloat)seconed{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = sMsg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:seconed];
}

+ (void)mbSay:(NSString *)sMsg completion:(void(^)(void))block{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = sMsg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
}
+ (MBProgressHUD *)sayAfterSuccess:(NSString *)s{
    MBProgressHUD *hud  = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow ];
    hud.customView      = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success.png"]];
    hud.mode            = MBProgressHUDModeCustomView;
    hud.labelText       = s;
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:1.0f];
    return hud;
}
+ (MBProgressHUD *)sayAfterFail:(NSString *)s{
    MBProgressHUD *hud  = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow ];
    hud.customView      = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fail.png"]];
    hud.mode            = MBProgressHUDModeCustomView;
    hud.labelText       = s;
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:1.0f];
    return hud;
}

+ (void)say:(NSString *)sMsg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:sMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

+ (void)say:(NSString *)sMsg title:(NSString *)title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:sMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

+ (UIAlertView *)say:(NSString *)sMsg Delegate:(id)delegate_{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:sMsg delegate:delegate_ cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    return alert;
}
+ (UIAlertView *)say2:(NSString *)sMsg Delegate:(id)delegate_{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:sMsg delegate:delegate_ cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    return alert;
}

- (void)say:(NSString *)message finished:(void (^)(UIAlertView *alertView, int index))block{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    alert.tag = TAG_SAY;
    self.alertFinished = block;
}

- (void)showInput:(NSString *)title message:(NSString *)message placeHolder:(NSString *)placeHolder finished:(void (^)(UIAlertView *alertView, int index))block{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    BOOL isSecretInput = [title containsString:@"密码"] || [message containsString:@"密码"];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *nameField  = [alert textFieldAtIndex:0];
    nameField.placeholder   = placeHolder;
    nameField.secureTextEntry = isSecretInput;
    alert.tag               = TAG_INPUT;
    alert.delegate          = self;
    self.userInputFinished  = block;
    [alert show];
}

- (void)show:(NSString *)message finished:(void (^)(UIAlertView *alertView))block{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    alert.tag = TAG_SHOW;
    //self.showFinished = block;
}

- (void)say:(NSString *)message confirm:(NSString *)confirm cancel:(NSString *)cancel finished:(void (^)(UIAlertView *alertView, int index))block{
    [self say:message title:@"提示" confirm:confirm cancel:cancel finished:block];
}

- (void)say:(NSString *)message title:(NSString *)title confirm:(NSString *)confirm cancel:(NSString *)cancel finished:(void (^)(UIAlertView *alertView, int index))block{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:confirm, nil];
    [alert show];
    alert.tag = TAG_SAY_CUSTOM;
    self.alertFinished = block;
}

- (void)showSheetWithTitle:(NSString *)title first:(NSString *)firstTitle seconed:(NSString *)seconedTitle showIn:(UIView *)view finished:(void (^)(UIActionSheet *sheet, int index))block{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:firstTitle otherButtonTitles:seconedTitle, nil];
    [sheet showInView:view];
//    self.showSheetFinished = block;
    self.sheetDidDisappear = block;
}

- (void)showSheetWithTitle:(NSString *)title first:(NSString *)firstTitle seconed:(NSString *)seconedTitle third:thirdTitle showIn:(UIView *)view finished:(void (^)(UIActionSheet *sheet, int index))block{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:firstTitle otherButtonTitles:seconedTitle, thirdTitle, nil];
    [sheet showInView:view];
//    self.showSheetFinished = block;
    self.sheetDidDisappear = block;
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.showSheetFinished) {
        self.showSheetFinished(actionSheet, (int)buttonIndex);
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (self.sheetDidDisappear) {
        self.sheetDidDisappear(actionSheet, (int)buttonIndex);
    }
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.alertFinished && (alertView.tag == TAG_SAY || alertView.tag == TAG_SAY_CUSTOM)) {
        self.alertFinished(alertView, (int)buttonIndex);
    }
    if (self.showFinished && alertView.tag == TAG_SHOW) {
        self.showFinished(alertView);
    }
    if (self.userInputFinished && alertView.tag == TAG_INPUT) {
        self.userInputFinished(alertView, (int)buttonIndex);
    }
}
+ (void)rotateView:(UIView *)view angle:(float)angle{
    CALayer *layer          = view.layer;
    CAKeyframeAnimation *animation;
    animation               = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration      = 0.5f;
    animation.cumulative    = YES;
    animation.repeatCount   = 1;
    animation.values        = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.0 * M_PI],
                               [NSNumber numberWithFloat:angle],
                               nil];
    animation.keyTimes      = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0],
                               [NSNumber numberWithFloat:.3],
                               nil];
    animation.timingFunctions = [NSArray arrayWithObjects:
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:nil];
}

+ (void)setShadow:(UIView *)view{
    view.layer.shadowOpacity    = 0.25f;
    view.layer.shadowOffset     = CGSizeMake(0, 3);
    view.layer.shadowRadius     = 3.0f;
    view.clipsToBounds          = NO;
}

//Unix时间戳
+ (NSString *)UnixTime{

    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSString *strTime = [NSString stringWithFormat:@"%.0f",time];
    return strTime;
}

//MD5加密
+(NSString *)md5:(NSString *)inPutText
{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}


/*邮箱验证 MODIFIED BY DENNISHU*/
+ (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex    = @"^\\s*\\w+(?:\\.{0,1}[\\w-]+)*@[a-zA-Z0-9]+(?:[-.][a-zA-Z0-9]+)*\\.[a-zA-Z]+\\s*$";
    NSPredicate *emailTest  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/*手机号码验证 MODIFIED BY DENNISHU*/
+ (BOOL)isValidateMobile:(NSString *)mobile{
    if (!([mobile hasPrefix:@"1"] || [mobile hasPrefix:@"4"]) || !([mobile length] == 11)) {
        return NO;
    }
    NSString *phoneRegex    = @"^[0－9]*$";
    NSPredicate *phoneTest  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

/*车牌号验证 MODIFIED BY DENNISHU*/
+ (BOOL)isValidateCarNo:(NSString *)carNo{
    NSString *carRegex      = @"^[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    NSPredicate *carTest    = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}

/*是否合法的密码*/
+ (BOOL)isValidatePassword:(NSString *)sPwd{
    sPwd = [NSString stringWithFormat:@"%@", sPwd];
    if (sPwd.length < 6 || sPwd.length > 20) {
        return NO;
    }
    return YES;
}

/*是否合法的身份证号码*/
+ (BOOL)isValideteIdentityCard:(NSString *)IDCardNumber{
    IDCardNumber = [NSString stringWithFormat:@"%@", IDCardNumber];
    if (IDCardNumber.length < 15 || IDCardNumber.length > 20) {
        return NO;
    }
    return YES;
}

/*是否合法账号名*/
+ (BOOL)isValidateAccount:(NSString *)s {
    NSString *carRegex      = @"^[a-zA-Z0-9\u4e00-\u9fa5\ue001-\ue537]+$";
    NSPredicate *carTest    = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:s];
}


#pragma mark - 邮件、短信、电话
- (UIViewController *)messageController:(NSString *)bodyOfMessage recipients:(NSArray *)recipients block:(void (^)(MFMessageComposeViewController *controller))block{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    controller.navigationBar.tintColor = [UIColor whiteColor];
    controller.messageComposeDelegate = self;
    self.sendMessageFinished = block;
    if([MFMessageComposeViewController canSendText]){
        controller.body         = bodyOfMessage;
        controller.recipients   = recipients;
        return controller;
    }
    return nil;
}

- (UIViewController *)mailController:(NSArray *)recipients title:(NSString *)title content:(NSString *)content image:(UIImage *)image block:(void (^)(MFMailComposeViewController *controller))block{
    if (![MFMailComposeViewController canSendMail]) {
        [HDHelper mbSay:@"您尚未设置邮箱"];
        return nil;
    }
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.navigationBar.tintColor = [UIColor whiteColor];
    if (title.length > 0) {
        [controller setSubject:title];
    }
    [controller setMessageBody:content isHTML:NO];
    if (image) {
        NSData *imageData = UIImagePNGRepresentation(image);
        [controller addAttachmentData:imageData mimeType:@"image/png" fileName:HDFORMAT(@"%d", arc4random())];
    }
    if (recipients.count > 0) {
        [controller setToRecipients:recipients];
    }
    controller.mailComposeDelegate  = self;
    self.sendMailFinished = block;
    return controller;
}

#pragma mark MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent) {
        [HDHelper mbSay:@"发送成功"];
    }
    if (result == MFMailComposeResultFailed) {
        [HDHelper mbSay:@"发送失败"];
    }
    if (self.sendMailFinished) {
        self.sendMailFinished(controller);
    }
}

#pragma mark MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent){
        [HDHelper mbSay:@"短信发送成功"];
    }
    if (result == MessageComposeResultFailed) {
        [HDHelper mbSay:@"短信发送失败"];
    }
    if (self.sendMessageFinished) {
        self.sendMessageFinished(controller);
    }
}

+ (void)makingCall:(NSString *)phone{
    NSString *str = HDFORMAT(@"tel://%@", phone);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

/** 动画 **/
#pragma mark - 动画

+ (void)view:(UIView *)view appearAt:(CGPoint)location withDalay:(CGFloat)delay duration:(CGFloat)duration{
    view.center                         = location;
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.duration             = duration;
    scaleAnimation.values               = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1)],
                                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.15, 1.15, 1)],
                                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)]];
    scaleAnimation.calculationMode      = kCAAnimationLinear;
    scaleAnimation.keyTimes             = @[[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:delay], [NSNumber numberWithFloat:1.0f]];
    [view.layer addAnimation:scaleAnimation forKey:@"buttonAppear"];
}

+ (void)showPullDown:(UIView *)view appearAt:(CGPoint)center withDalay:(CGFloat)delay duration:(CGFloat)duration{//未完
    view.center                         = center;
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.duration             = duration;
    scaleAnimation.values               = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 0.1, 1)],
                                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 0.5, 1)],
                                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)]];
    scaleAnimation.calculationMode      = kCAAnimationLinear;
    scaleAnimation.keyTimes             = @[[NSNumber numberWithFloat:0.0f], @(delay), [NSNumber numberWithFloat:1.0f]];
    [view.layer addAnimation:scaleAnimation forKey:@"buttonAppear"];
}

- (void)hidePullUp:(UIView *)view appearAt:(CGRect)bounds duration:(CGFloat)duration finished:(void (^)(void))block{
    view.bounds                         = CGRectMake(CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetWidth(bounds), 0);
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.duration             = duration;
    scaleAnimation.values               = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)],
                                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 0.1, 1)]];
    scaleAnimation.calculationMode      = kCAAnimationLinear;
    scaleAnimation.keyTimes             = @[@(0), @(1)];
    scaleAnimation.removedOnCompletion  = NO;
    scaleAnimation.delegate             = self;
    [view.layer addAnimation:scaleAnimation forKey:@"buttonAppear"];
    self.hidePullUpAnimationFinished    = block;
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    CAKeyframeAnimation *keyAnim = (CAKeyframeAnimation *)anim;
    if ([keyAnim.keyPath isEqualToString:@"transform"]) {
        if (self.hidePullUpAnimationFinished) {
            self.hidePullUpAnimationFinished();
        }
    }
}
+ (void)showView:(UIView *)view centerAtPoint:(CGPoint)pos duration:(CGFloat)waitDuration{
    view.center = pos;
    CABasicAnimation *forwardAnimation  = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    forwardAnimation.duration           = waitDuration;
    forwardAnimation.timingFunction     = [CAMediaTimingFunction functionWithControlPoints:0.5f :1.7f :0.6f :0.85f];
    forwardAnimation.fromValue          = [NSNumber numberWithFloat:0.0f];
    forwardAnimation.toValue            = [NSNumber numberWithFloat:1.0f];
    CAAnimationGroup *animationGroup    = [CAAnimationGroup animation];
    animationGroup.animations           = [NSArray arrayWithObjects:forwardAnimation, nil];
    //animationGroup.delegate             = self;
    animationGroup.duration             = forwardAnimation.duration;
    animationGroup.removedOnCompletion  = NO;
    animationGroup.fillMode             = kCAFillModeForwards;
    [UIView animateWithDuration:animationGroup.duration
                          delay:0.0
                        options:0
                     animations:^{
                         [view.layer addAnimation:animationGroup
                                           forKey:@"kLPAnimationKeyPopup"];
                     }
                     completion:^(BOOL finished) {
                     }];
}
+ (void)hideView:(UIView *)view duration:(CGFloat)waitDuration{
    CABasicAnimation *reverseAnimation      = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    reverseAnimation.duration               = 0.3;
    reverseAnimation.beginTime              = 0;
    reverseAnimation.timingFunction         = [CAMediaTimingFunction functionWithControlPoints:0.4f :0.15f :0.5f :-0.7f];
    reverseAnimation.fromValue              = [NSNumber numberWithFloat:1.0f];
    reverseAnimation.toValue                = [NSNumber numberWithFloat:0.0f];
    reverseAnimation.removedOnCompletion    = YES;
    [view.layer addAnimation:reverseAnimation forKey:@"1111"];
}

//相机是否可用
+ (BOOL)isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL)isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

+ (BOOL)isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

+ (CGFloat)heightOfUITextView:(UITextView *)textView{
    if (!textView || textView.font == nil) {
        Dlog(@"传入参数有误！");
        return 0.;
    }
    if ([textView respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]){
        CGRect frame = textView.bounds;
        UIEdgeInsets textContainerInsets = textView.textContainerInset;
        UIEdgeInsets contentInsets = textView.contentInset;
        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;
        NSString *textToMeasure = textView.text;
        if ([textToMeasure hasSuffix:@"\n"]){
            textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
        }
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        NSDictionary *attributes = @{NSFontAttributeName:textView.font, NSParagraphStyleAttributeName:paragraphStyle};
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
        CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        return measuredHeight;
    }else{
        return textView.contentSize.height;
    }
}

+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePathString
{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

+ (void)setNormalDisplayModleForTheView:(UIView *)v{
    if (!v) {
        Dlog(@"传入参数'v'不能为空！");
        return;
    }
    [v setContentMode:UIViewContentModeScaleAspectFill];
    v.clipsToBounds = YES;
}

+ (void)addDashedBorderWithTheMotherView:(UIView *)view color:(UIColor *)color{
    for (int i = 0; i < view.layer.sublayers.count; i++) {
        CALayer *layer = view.layer.sublayers[i];
        if ([layer isKindOfClass:[CAShapeLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    CGSize frameSize = view.frame.size;
    CGRect shapeRect = CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height);
    [shapeLayer setBounds:shapeRect];
    [shapeLayer setPosition:CGPointMake(frameSize.width/2,frameSize.height/2)];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:color.CGColor];
    [shapeLayer setLineWidth:0.5f];
    [shapeLayer setLineDashPattern:@[@(10), @(5)]];
    Dlog(@"shapeRect = %f", frameSize.width);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:shapeRect];
    [shapeLayer setPath:path.CGPath];
    [view.layer addSublayer:shapeLayer];
}

+ (void)removeDashedBorder:(UIView *)view{
    for (int i = 0; i < view.layer.sublayers.count; i++) {
        CALayer *layer = view.layer.sublayers[i];
        if ([layer isKindOfClass:[CAShapeLayer class]]) {
            [layer removeFromSuperlayer];
        }
    }
}

+ (NSString *)getCurrentDate{
    NSDate * today = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];//格式化
    [df setDateFormat:@"yyyy-MM-dd"];
    return [df stringFromDate:today];
}

+ (BOOL)isTimeToRefresh:(NSString *)str{
    return [self hasPassedHours:0.1 flag:str];
}

+ (BOOL)hasPassedHours:(CGFloat)hour flag:(NSString *)str{
    if (str.length == 0 || hour < 0) {
        return NO;
    }
    NSDate *date    = [[NSUserDefaults standardUserDefaults] objectForKey:HDFORMAT(@"date_%@", str)];
    if (!date) {//第一次
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:HDFORMAT(@"date_%@", str)];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    NSTimeInterval timeInterval = [date timeIntervalSinceNow];
    timeInterval    = -timeInterval;
    if (timeInterval > 60 * 60 * hour) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:HDFORMAT(@"date_%@", str)];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return NO;
}

+ (BOOL)clearTimeToRefreshFlag:(NSString *)flag{
    if (flag.length == 0 || !flag) {//remove all
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        return YES;
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:HDFORMAT(@"date_%@", flag)];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return YES;
}
@end
