//
//  LLSimpleCamera+Helper.h
//  LLSimpleCameraExample
//
//  Created by Ömer Faruk Gül on 20/02/16.
//  Copyright © 2016 Ömer Faruk Gül. All rights reserved.
//

#import "LLSimpleCamera.h"

@interface LLSimpleCamera (Helper)

//点击聚焦
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
                                          previewLayer:(AVCaptureVideoPreviewLayer *)previewLayer
                                                 ports:(NSArray<AVCaptureInputPort *> *)ports;
//裁剪图片
- (UIImage *)cropImage:(UIImage *)image usingPreviewLayer:(AVCaptureVideoPreviewLayer *)previewLayer;

@end
