//
//  LLTrimCommend.m
//  LEVE
//
//  Created by canoe on 2017/11/11.
//  Copyright © 2017年 dashuju. All rights reserved.
//

#import "LLTrimCommend.h"

@interface LLTrimCommend ()

@property(nonatomic, weak) LLVideoData *videoData;
@property(nonatomic) double startTime;
@property(nonatomic) double duration;
@end

@implementation LLTrimCommend

-(instancetype)initWithVideoData:(LLVideoData *)videoData startTime:(double)startTime duration:(double)duration
{
    self = [super init];
    if (self) {
        _videoData = videoData;
        _startTime = startTime;
        _duration = duration;
    }
    return self;
}

-(void)execute
{
    double totalTime = CMTimeGetSeconds(self.videoData.composition.duration);
    if (totalTime - self.startTime < self.duration) {
        NSLog(@"视频裁剪时长设置有误 ！！！！！");
        return;
    }
    
    //在一开始已经进行进行过视频轨道的初始化设置
    //需要移除不需要的视频时长部分
    CMTime firstPartDuration = CMTimeMakeWithSeconds(self.startTime, 60);
    CMTime lastPartStart = CMTimeMakeWithSeconds(self.startTime + self.duration, 60);
    CMTime lastPartDuration = CMTimeMakeWithSeconds(totalTime - self.duration - self.startTime, 60);
    
    [self.videoData.composition removeTimeRange:CMTimeRangeMake(lastPartStart, lastPartDuration)];
    [self.videoData.composition removeTimeRange:CMTimeRangeMake(kCMTimeZero, firstPartDuration)];
}

@end
