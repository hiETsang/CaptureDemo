
//
//  ZLConst.h
//  
//
//  Created by long on 2017/4/26.
//  Copyright © 2017年 long All rights reserved.
//

#ifndef ZLConst_h
#define ZLConst_h
/**
 *  1.屏幕尺寸
 */
#define ScreenWidth  CGRectGetWidth([UIScreen mainScreen].bounds)
#define ScreenHeight CGRectGetHeight([UIScreen mainScreen].bounds)

#define kZLPhotoBrowserSrcName(file) [@"ZLPhotoBrowser.bundle" stringByAppendingPathComponent:file]
/**
 *  2.返回一个RGBA格式的UIColor对象
 */
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

/**
 *  3.返回一个RGB格式的UIColor对象
 */
#define RGB(r, g, b) RGBA(r, g, b, 1.0f)

/**
 *  4.弱引用
 */
#define STWeakSelf __weak typeof(self) weakSelf = self;

#endif /* ZLConst_h */
