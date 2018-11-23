//
//  HDPhotoHelper.m
//  Demo
//
//  Created by hufan on 3/15/17.
//  Copyright © 2017 hufan. All rights reserved.
//

#import "HDPhotoHelper.h"

static HDPhotoHelper *pData = nil;

@interface HDPhotoHelper (){
    photoBlock finishBlock;
}

@end

@implementation HDPhotoHelper

+ (HDPhotoHelper *)instance{
    @synchronized(self){
        if (pData == NULL){
            pData = [[HDPhotoHelper alloc] init];
        }
    }
    return pData;
}

- (void)reset{
    pData = nil;
}

- (void)read:(photoBlock)block{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择图库或拍照" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"取消" otherButtonTitles:@"从图库选取", @"拍一张", nil];
    [sheet showInView:HDGI.nav.view];
    if (block) {
        finishBlock = block;
    }
}

- (void)readCardId:(photoBlock)block{
    if (block) {
        [self readPhoto:NO finish:block];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    Dlog(@"click:%d", buttonIndex);
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    Dlog(@"cancel");
    if (finishBlock && buttonIndex > 0 && buttonIndex < 3) {
        [self readPhoto:buttonIndex-1 finish:finishBlock];
    }
}

- (void)readPhoto:(BOOL)isCamera finish:(photoBlock)block{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (isCamera) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    imagePickerController.delegate = self;
    [HDGI.nav presentViewController:imagePickerController animated:YES completion:nil];
    if (block) {
        finishBlock = block;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSData *data = nil;
    for (int i = 0; i < 10000; i++) {//压缩到2M以内
        NSData *d = UIImageJPEGRepresentation(image, 1 - 0.1 * i);
        CGFloat size = d.length/1024./1024.;
        Dlog(@"size = %0.2fM, i = %d, flag = %0.1f", size, i, 1 - 0.1 * i);
        if (size < 1.5) {
            data = d;
            break;
        }
    }
    Dlog(@"image size = %0.2fM", data.length / 1024. / 1024.);
    UIImage *img = [UIImage imageWithData:data];
    NSData *data1 = UIImageJPEGRepresentation(img, .5);
    Dlog(@"data1 = %0.2fM", data1.length / 1024. / 1024.);
    if (finishBlock) {
        finishBlock(img);
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
