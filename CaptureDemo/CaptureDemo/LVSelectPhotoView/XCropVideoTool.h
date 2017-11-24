//
//  XCropVideoTool.h
//  CaptureDemo
//
//  Created by canoe on 2017/11/9.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface XCropVideoTool : NSObject

- (instancetype)initWithVideoURL:(NSURL *)videoURL;

//裁剪区域
@property(nonatomic) CGRect cropRect;

//裁剪初始时间
@property(nonatomic) float startTime;

//裁剪结束时间
@property(nonatomic) float endTime;

//是否需要拉伸,false的话不拉伸，裁剪黑背景
@property(nonatomic) BOOL shouldScale;


/**
 图片裁剪

 @param fileName 视频名称
 @param completionBlock 裁剪完成视频回调
 */
- (void)exportFileName:(NSString *)fileName completionBlock:(void (^)(AVAssetExportSession *session))completionBlock;

/**
 视频方向
 
 @param url 视频文件URL
 @return 上  90  下  270  右 0 左 180
 */
+ (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url;

@end
