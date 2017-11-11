//
//  UIImage+ZL.h
//  
//
//  Created by long on 2017/4/26.
//  Copyright © 2017年 long All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZL)
/**
 *  获取圆角图片
 *
 *  @param image       <#image description#>
 *  @param borderWidth <#borderWidth description#>
 *  @param color       <#color description#>
 *
 *  @return <#return value description#>
 */

+ (UIImage *)imageWithClipImage:(UIImage *)image borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)color;

/**
 *  指定区域图片的截图
 *
 *  @param sourceImage 原始图片
 *  @param clipRect    截取范围
 *
 *  @return 截图图片
 */
+ (UIImage *)imageWithSourceImage:(UIImage *)sourceImage
                         clipRect:(CGRect)clipRect;


/**
 修正图片方向
 对于竖直拍摄的图片大于2M之后进行裁剪会出现旋转90度的情况，需要先对图片进行修正
 @param aImage 需要修正的图片
 @return 修正后的图片
 */
+ (UIImage *)fixOrientation:(UIImage *)aImage;

/**
 *  截取指定位置的图片
 *
 *  @param bounds <#bounds description#>
 *
 *  @return <#return value description#>
 */
- (UIImage *)croppedImage:(CGRect)bounds;




@end
