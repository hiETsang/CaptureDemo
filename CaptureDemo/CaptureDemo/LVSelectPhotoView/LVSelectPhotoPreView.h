//
//  LVSelectPhotoPreView.h
//  CaptureDemo
//
//  Created by canoe on 2017/11/6.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface LVSelectPhotoPreView : UIView

//PHAsset 媒体对象
@property(nonatomic, strong) PHAsset *asset;

//获取当前状态下的图片或者视频 如果是图片，返回UIImage类型  视频返回URL
- (void)getCurrentStateImageOrVideoCompletionBlock:(void (^)(BOOL isImage,UIImage *image,NSURL *url))completionBlock;

@end
