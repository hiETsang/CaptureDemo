//
//  LLAddAudioCommand.m
//  LLVideoEditorExample
//
//  Created by Ömer Faruk Gül on 01/06/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import "LLAddAudioCommand.h"

@interface LLAddAudioCommand ()
@property (weak, nonatomic) LLVideoData *videoData;
@property (strong, nonatomic) AVAsset *audioAsset;
@property (nonatomic) float startingAt;
@property (nonatomic) float trackDuration;
@end

@implementation LLAddAudioCommand

- (instancetype)initWithVideoData:(LLVideoData *)videoData audioAsset:(AVAsset *)audioAsset {
    self = [self initWithVideoData:videoData audioAsset:audioAsset startingAt:0 trackDuration:FLT_MAX];
    if(self) {
    }
    
    return self;
}

- (instancetype)initWithVideoData:(LLVideoData *)videoData
                       audioAsset:(AVAsset *)audioAsset
                       startingAt:(float)startingAt {
    self = [self initWithVideoData:videoData audioAsset:audioAsset startingAt:startingAt trackDuration:FLT_MAX];
    if(self) {
    }
    
    return self;
}

- (instancetype)initWithVideoData:(LLVideoData *)videoData
                       audioAsset:(AVAsset *)audioAsset
                       startingAt:(float)startingAt
                       trackDuration:(float)trackDuration {
    self = [super init];
    if(self) {
        _videoData = videoData;
        _audioAsset = audioAsset;
        _startingAt = startingAt;
        _trackDuration = trackDuration;
    }
    
    return self;
}

- (void)execute {
    
    AVAssetTrack *track;
    
    // Check if the asset contains video and audio tracks
    if ([self.audioAsset tracksWithMediaType:AVMediaTypeAudio].count != 0) {
        track = [self.audioAsset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    else {
        return;
    }
    
    //NSLog(@"audio asset duration: %f", CMTimeGetSeconds(self.audioAsset.duration));
    
    NSError *error = nil;
    
    AVMutableCompositionTrack *audioCompositionTrack = [self.videoData.composition
                                                       addMutableTrackWithMediaType:AVMediaTypeAudio
                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTime videoDuration = self.videoData.videoCompositionTrack.timeRange.duration;
    CMTime startTime = CMTimeMakeWithSeconds(self.startingAt, videoDuration.timescale);
    CMTime trackDurationTime = CMTimeMakeWithSeconds(self.trackDuration, videoDuration.timescale);
    
    // don't do anyting if the starting time is larger than the video itself
    if(CMTimeCompare(videoDuration, startTime) == -1) {
        return;
    }
    
    // trim the track duration if its longer than the video
    CMTime availableTrackDuration = CMTimeSubtract(videoDuration,
                                                   CMTimeMakeWithSeconds(self.startingAt, videoDuration.timescale));
    
    CMTime duration;
    if(CMTimeCompare(availableTrackDuration, track.timeRange.duration) == -1) {
        duration = availableTrackDuration;
    }
    else {
        duration = track.timeRange.duration;
    }
    
    
    if(CMTimeCompare(trackDurationTime, duration) == -1) {
        duration = trackDurationTime;
    }
    
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, duration);
    
    [audioCompositionTrack insertTimeRange:timeRange
                                    ofTrack:track
                                    atTime:startTime error:&error];
    
    NSLog(@"audio command error : %@", error);
}

@end
