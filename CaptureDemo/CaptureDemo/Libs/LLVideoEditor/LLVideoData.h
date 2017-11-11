//
//  LLVideoData.h
//  LLVideoEditorExample
//
//  Created by Ömer Faruk Gül on 30/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;

@interface LLVideoData : NSObject
@property (strong, nonatomic) AVAsset *asset;
@property (strong, nonatomic) AVMutableComposition *composition;
@property (strong, nonatomic) AVAssetTrack *assetVideoTrack;
@property (strong, nonatomic) AVAssetTrack *assetAudioTrack;
@property (strong, nonatomic) AVMutableVideoComposition *videoComposition;
@property (strong, nonatomic) AVMutableCompositionTrack *videoCompositionTrack;
@property (strong, nonatomic) AVMutableCompositionTrack *audioCompositionTrack;
@property (nonatomic) CGSize videoSize;

- (instancetype)initWithAsset:(AVAsset *)asset;
@end
