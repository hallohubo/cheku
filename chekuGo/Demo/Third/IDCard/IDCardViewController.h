//
//  IDCardViewController.h
//  idcard
//
//  Created by hxg on 16-4-10.
//  Copyright (c) 2016年 林英伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Capture.h"

@interface IDCardViewController : UIViewController<CaptureDelegate> {
    Capture *_capture;
    UIView         *_cameraView;
    unsigned char* _buffer;
}
@property (nonatomic, copy) void(^scanFinishdBlock)(IdInfo *info, UIImage *image);
@property (weak, nonatomic) id<CaptureDelegate> delegate;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic)BOOL             verify;
@end
