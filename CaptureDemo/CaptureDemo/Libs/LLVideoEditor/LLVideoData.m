//
//  LLVideoData.m
//  LLVideoEditorExample
//
//  Created by Ömer Faruk Gül on 30/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import "LLVideoData.h"

@implementation LLVideoData
- (instancetype)initWithAsset:(AVAsset *)asset {
    self = [super init];
    if(self) {
        _asset = asset;
        
        [self loadAsset:_asset];
    }
    return self;
}

- (void)loadAsset:(AVAsset *)asset {
    
    // Check if the asset contains video and audio tracks
    if ([asset tracksWithMediaType:AVMediaTypeVideo].count != 0) {
        _assetVideoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    }
    if ([asset tracksWithMediaType:AVMediaTypeAudio].count != 0) {
        _assetAudioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    }
    
    _videoSize = [_assetVideoTrack naturalSize];
    
    self.composition = [AVMutableComposition composition];
    self.videoComposition = [AVMutableVideoComposition videoComposition];
    self.videoComposition.frameDuration = CMTimeMake(1, 30);
    self.videoComposition.renderSize = _videoSize;
    
    CMTime insertionPoint = kCMTimeZero;
    NSError *error = nil;
    
    // Insert the video and audio tracks from AVAsset
    if (_assetVideoTrack != nil) {
        _videoCompositionTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                               preferredTrackID:kCMPersistentTrackID_Invalid];
        
        [_videoCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                                        ofTrack:_assetVideoTrack
                                         atTime:insertionPoint error:&error];
        
        //NSLog(@"Asset initialized with natural size: %@", NSStringFromCGSize(_assetVideoTrack.naturalSize));
        
        //CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(M_PI_2);
        //videoTrack.preferredTransform = rotationTransform;
        //[videoTrack setPreferredTransform:[_assetVideoTrack preferredTransform]];
    }
    if (_assetAudioTrack != nil) {
        _audioCompositionTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                               preferredTrackID:kCMPersistentTrackID_Invalid];
        [_audioCompositionTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration])
                                        ofTrack:_assetAudioTrack
                                         atTime:insertionPoint error:&error];
    }
}
@end
