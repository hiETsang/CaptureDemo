//
//  LLAddLayerCommand.m
//  LLVideoEditorExample
//
//  Created by Ömer Faruk Gül on 31/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import "LLAddLayerCommand.h"

@interface LLAddLayerCommand ()
@property (weak, nonatomic) LLVideoData *videoData;
@property (strong, nonatomic) CALayer *layer;
@end

@implementation LLAddLayerCommand 
- (instancetype)initWithVideoData:(LLVideoData *)videoData layer:(CALayer *)layer {
    self = [super init];
    if(self) {
        _videoData = videoData;
        _layer = layer;
    }
    
    return self;
}

- (void)execute {
    CGSize videoSize = self.videoData.videoSize;

    AVMutableVideoCompositionInstruction *instruction = nil;
    AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;

//    NSLog(@"The video size is: %@", NSStringFromCGSize(videoSize));
//    NSLog(@"Asset natural size adding layer: %@", NSStringFromCGSize(_assetVideoTrack.naturalSize));

    CALayer *parentLayer = [CALayer layer];

    CALayer *videoLayer = [CALayer layer];
    parentLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    videoLayer.frame = CGRectMake(0, 0, videoSize.width, videoSize.height);
    [parentLayer addSublayer:videoLayer];
    [parentLayer addSublayer:self.layer];
    
    CMTime duration = [self.videoData.composition duration];

    if(self.videoData.videoComposition.instructions.count == 0) {
        instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, duration);

        layerInstruction = [AVMutableVideoCompositionLayerInstruction
                            videoCompositionLayerInstructionWithAssetTrack:self.videoData.videoCompositionTrack];

        instruction.layerInstructions = @[layerInstruction];
        self.videoData.videoComposition.instructions = @[instruction];
    }

    self.videoData.videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool      videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
}

@end
