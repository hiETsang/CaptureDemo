//
//  PHAsset+ChangeForUrl.h
//  CaptureDemo
//
//  Created by canoe on 2017/11/8.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (ChangeForUrl)

-(void)getURLCompletionBlock:(void (^)(NSURL *responseURL))completionBlock;

@end
