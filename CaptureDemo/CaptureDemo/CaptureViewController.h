//
//  CaptureViewController.h
//  CaptureDemo
//
//  Created by canoe on 2017/11/8.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CaptureViewController : UIViewController

/** 拍照完成 */
@property (nonatomic,copy) void (^didFinishCapture)(UIImage *image);

@end
