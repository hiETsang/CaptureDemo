//
//  SelectPhotoViewController.h
//  CaptureDemo
//
//  Created by canoe on 2017/11/7.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectPhotoViewController : UIViewController

/** 点击下一步 */
@property (nonatomic,copy) void (^didEndSelectObject)(BOOL isImage,UIImage *image,NSURL *url);

@end
