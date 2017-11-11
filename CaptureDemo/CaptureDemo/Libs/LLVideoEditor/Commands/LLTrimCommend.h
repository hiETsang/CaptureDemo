//
//  LLTrimCommend.h
//  LEVE
//
//  Created by canoe on 2017/11/11.
//  Copyright © 2017年 dashuju. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLVideoData.h"
#import "LLVideoEditor.h"

@interface LLTrimCommend : NSObject <LLCommandProtocol>
// disable the basic initializer
- (instancetype)init NS_UNAVAILABLE;
// default initializer  startTime :seconds
- (instancetype)initWithVideoData:(LLVideoData *)videoData startTime:(double)startTime duration:(double)duration;

@end
