//
//  HDPhotoHelper.h
//  Demo
//
//  Created by hufan on 3/15/17.
//  Copyright © 2017 hufan. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HDPI [HDPhotoHelper instance]

typedef void(^photoBlock)(UIImage *image);

@interface HDPhotoHelper : NSObject

+ (HDPhotoHelper *)instance;
- (void)read:(photoBlock)block;
- (void)readPhoto:(BOOL)isCamera finish:(photoBlock)block;
- (void)readCardId:(photoBlock)block;
@end
