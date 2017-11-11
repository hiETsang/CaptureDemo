//
//  LLRotateCommand.h
//  LLVideoEditorExample
//
//  Created by Ömer Faruk Gül on 30/05/15.
//  Copyright (c) 2015 Ömer Faruk Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LLVideoEditor.h"
#import "LLVideoData.h"

@interface LLRotateCommand : NSObject <LLCommandProtocol>
// disable the basic initializer
- (instancetype)init NS_UNAVAILABLE;
// default initializer
- (instancetype)initWithVideoData:(LLVideoData *)videoData;
@end
