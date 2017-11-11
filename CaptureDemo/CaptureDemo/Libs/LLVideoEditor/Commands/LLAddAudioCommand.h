//
//  LLAddAudioCommand.h
//  LLVideoEditorExample
//
//  Created by Ömer Faruk Gül on 01/06/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LLVideoEditor.h"
#import "LLVideoData.h"

@interface LLAddAudioCommand : NSObject<LLCommandProtocol>
// disable the basic initializer
- (instancetype)init NS_UNAVAILABLE;
// initializers
- (instancetype)initWithVideoData:(LLVideoData *)videoData audioAsset:(AVAsset *)audioAsset;

- (instancetype)initWithVideoData:(LLVideoData *)videoData
                       audioAsset:(AVAsset *)audioAsset
                       startingAt:(float)startingAt;

- (instancetype)initWithVideoData:(LLVideoData *)videoData
                       audioAsset:(AVAsset *)audioAsset
                       startingAt:(float)startingAt
                    trackDuration:(float)trackDuration;
@end
