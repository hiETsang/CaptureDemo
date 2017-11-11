//
//  PHAsset+ChangeForUrl.m
//  CaptureDemo
//
//  Created by canoe on 2017/11/8.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "PHAsset+ChangeForUrl.h"

@implementation PHAsset (ChangeForUrl)

-(void)getURLCompletionBlock:(void (^)(NSURL *))completionBlock
{
    if (self.mediaType == PHAssetMediaTypeImage) {
        PHContentEditingInputRequestOptions *options = [[PHContentEditingInputRequestOptions alloc] init];
        options.canHandleAdjustmentData = ^BOOL(PHAdjustmentData * _Nonnull adjustmentData) {
            return YES;
        };
        [self requestContentEditingInputWithOptions:options completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
            completionBlock(contentEditingInput.fullSizeImageURL);
        }];
    }else if(self.mediaType == PHAssetMediaTypeVideo)
    {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        [[PHImageManager defaultManager] requestAVAssetForVideo:self options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            AVURLAsset *urlAsset = (AVURLAsset *)asset;
            if (urlAsset) {
                NSURL *url = urlAsset.URL;
                completionBlock(url);
            }else
            {
                completionBlock(nil);
            }
        }];
    }
}

@end
