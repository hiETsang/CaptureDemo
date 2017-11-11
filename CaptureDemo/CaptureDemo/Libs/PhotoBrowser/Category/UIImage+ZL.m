//
//  UIImage+ZL.m
// 
//
//  Created by long on 2017/4/26.
//  Copyright © 2017年 long All rights reserved.
//

#import "UIImage+ZL.h"

@implementation UIImage (ZL)
/**
 *  绘制图片圆角
 *
 *  @param image       <#image description#>
 *  @param borderWidth <#borderWidth description#>
 *  @param color       <#color description#>
 *
 *  @return <#return value description#>
 */


+ (UIImage *)imageWithClipImage:(UIImage *)image borderWidth:(CGFloat)borderWidth borderColor:(UIColor *)color
{
    // 图片的宽度和高度
    CGFloat imageWH = image.size.width;

    // 设置圆环的宽度
    CGFloat border = borderWidth;

    // 圆形的宽度和高度
    CGFloat ovalWH = imageWH + 2 * border;

    // 1.开启上下文
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(ovalWH, ovalWH), NO, 0);

    // 2.画大圆
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, ovalWH, ovalWH)];

    [color set];

    [path fill];

    // 3.设置裁剪区域
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(border, border, imageWH, imageWH)];
    [clipPath addClip];

    // 4.绘制图片
    [image drawAtPoint:CGPointMake(border, border)];

    // 5.获取图片
    UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();

    // 6.关闭上下文
    UIGraphicsEndImageContext();

    return clipImage;
}

+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation ==UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform =CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width,0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width,0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height,0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx =CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                            CGImageGetBitsPerComponent(aImage.CGImage),0,
                                            CGImageGetColorSpace(aImage.CGImage),
                                            CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx,CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx,CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg =CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

/**
 *  指定区域图片的截图
 *
 *  @param sourceImage 原始图片
 *  @param clipRect    截取范围
 *
 *  @return 截图图片
 */
+ (UIImage *)imageWithSourceImage:(UIImage *)sourceImage
                         clipRect:(CGRect)clipRect
{
    CGImageRef imageRef = sourceImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, clipRect);
    CGSize imageSize = clipRect.size;
    UIGraphicsBeginImageContext(imageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, clipRect, subImageRef);
    UIImage *clipImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return clipImage;
}

/**
 *  指定图片的比例
 *
 *  @param sourceImage <#sourceImage description#>
 *  @param scaleSize   <#scaleSize description#>
 *
 *  @return <#return value description#>
 */
+ (UIImage *)imageWithSourceImage:(UIImage *)sourceImage
                        scaleSize:(CGSize)scaleSize
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(scaleSize);

    // 绘制改变大小的图片
    [sourceImage drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];

    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    // 使当前的context出堆栈
    UIGraphicsEndImageContext();

    // 返回新的改变大小后的图片
    return scaledImage;
}

/**
 *  截取指定位置的图片
 *
 *  @param bounds <#bounds description#>
 *
 *  @return <#return value description#>
 */
- (UIImage *)croppedImage:(CGRect)bounds {
    CGFloat scale = MAX(self.scale, 1.0f);
    CGRect scaledBounds = CGRectMake(bounds.origin.x * scale, bounds.origin.y * scale, bounds.size.width * scale, bounds.size.height * scale);
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], scaledBounds);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    return croppedImage;
}

@end
