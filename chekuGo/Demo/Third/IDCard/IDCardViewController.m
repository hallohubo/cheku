//
//  IDCardViewController.m
//  idcard
//
//  Created by hxg on 16-4-10.
//  Copyright (c) 2016年 林英伟. All rights reserved.
//
//@import MobileCoreServices;
@import ImageIO;
#import "IDCardViewController.h"
#import "IdInfo.h"

@interface IDCardViewController ()
@end


@implementation IDCardViewController
@synthesize verify = _verify;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

static Boolean init_flag = false;
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    if (!init_flag)
    {
        const char *thePath = [[[NSBundle mainBundle] resourcePath] UTF8String];
        int ret = EXCARDS_Init(thePath);
        if (ret != 0)
        {
            NSLog(@"Init Failed!ret=[%d]", ret);
        }
        
        init_flag = true;
    }
    
    self.toolbar = [UIToolbar new];
    _toolbar.barStyle = UIBarStyleDefault;
    
    // size up the toolbar and set its frame
    [_toolbar sizeToFit];
    CGFloat toolbarHeight = [_toolbar frame].size.height;
    CGRect frame = self.view.bounds;
    [_toolbar setFrame:CGRectMake(CGRectGetMinX(frame),
                                  20,
                                  CGRectGetWidth(frame),
                                  toolbarHeight)];
//    [[[_toolbar subviews] objectAtIndex:0] setAlpha:0];
    [_toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UITabBarItemPositioningFill barMetrics:UIBarMetricsDefault];
    [_toolbar setShadowImage:[UIImage new] forToolbarPosition:UITabBarItemPositioningFill];
//    [_toolbar setShadowImage:[UIImage new]];
//    [_toolbar setTintColor:[UIColor whiteColor]];
    [_toolbar setTintColor:HDCOLOR_THEME];
    [self.view addSubview:_toolbar];
    
    // Create spacing
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *close = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                              target:self
                              action:@selector(closeAction)];
    
    NSMutableArray *items = [NSMutableArray arrayWithObjects: close, flex, nil];
    [self.toolbar setItems:items animated:NO];
}

- (void)closeAction
{
    [self removeCapture];
    [self dismissViewControllerAnimated: YES completion:nil];
    if(init_flag){
        EXCARDS_Done();
        init_flag = false;
    }
}

- (void)startAction
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
    });
    
    [[_capture captureSession] startRunning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initCapture];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Capture

- (void)initCapture
{
    // init capture manager
    _capture = [[Capture alloc] init];
    
    _capture.delegate = self;
    _capture.verify = self.verify;
    
    // set video streaming quality
    /**指定摄像头采集的分辨率*/
    // AVCaptureSessionPresetHigh   1280x720
    // AVCaptureSessionPresetPhoto  852x640
    // AVCaptureSessionPresetMedium 480x360
    _capture.captureSession.sessionPreset = AVCaptureSessionPresetHigh;
    
    //kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
    //kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
    //kCVPixelFormatType_32BGRA
    [_capture setOutPutSetting:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]];
    
    // AVCaptureDevicePositionBack
    // AVCaptureDevicePositionFront
    [_capture addVideoInput:AVCaptureDevicePositionBack];
    
    [_capture addVideoOutput];
    [_capture addVideoPreviewLayer];
    
    CGRect layerRect = self.view.bounds;
    [[_capture previewLayer] setOpaque: 0];
    [[_capture previewLayer] setBounds:layerRect];
    [[_capture previewLayer] setPosition:CGPointMake( CGRectGetMidX(layerRect), CGRectGetMidY(layerRect))];
    
    // create a view, on which we attach the AV Preview layer
    CGRect frame = self.view.bounds;
    CGFloat toolbarHeight = [_toolbar frame].size.height;
    frame.size.height = frame.size.height - toolbarHeight;
    _cameraView = [[UIView alloc] initWithFrame:frame];
    [[_cameraView layer] addSublayer:[_capture previewLayer]];
    
    frame = _cameraView.bounds;
    UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 500)];
    [imv setImage:HDIMAGE(@"idcard")];
    imv.center = _cameraView.center;
    
    // add the view we just created as a subview to the View Controller's view
    [self.view addSubview:imv];
    [self.view addSubview: _cameraView];
    [self.view sendSubviewToBack:_cameraView];
    
    // start !
    [self performSelectorInBackground:@selector(startCapture) withObject:nil];
}

- (void)removeCapture
{
    [_capture.captureSession stopRunning];
    [_cameraView removeFromSuperview];
    _capture     = nil;
    _cameraView  = nil;
}

- (void)startCapture
{
    //@autoreleasepool
    {
        [[_capture captureSession] startRunning];
    }
}

#pragma mark - Capture Delegates
- (void)idCardRecognited:(IdInfo*)idInfo
{
    //NSLog(@"%@", [idInfo toString]);
    [_capture.captureSession stopRunning];
    UIImage *image = _capture.stillImage;
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self removeCapture];
        if (self.scanFinishdBlock) {
            self.scanFinishdBlock(idInfo, image);
        }
        if([self.delegate respondsToSelector:@selector(idCardRecognited:)])
        {
            [self.delegate idCardRecognited:idInfo];
        }
    });
    
    
}


@end
