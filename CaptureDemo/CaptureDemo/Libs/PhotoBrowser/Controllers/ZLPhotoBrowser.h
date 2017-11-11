//
//  ZLPhotoBrowser.h
//  多选相册照片
//
//  Created by long on 15/11/27.
//  Copyright © 2015年 long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLDefine.h"

@class ZLSelectPhotoModel;

@interface ZLPhotoBrowser : UITableViewController

//最大选择数
@property (nonatomic, assign) NSInteger maxSelectCount;
//是否选择了原图
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

/** 只显示一张*/
@property (nonatomic, assign) BOOL seleteOnlyOne;

/** 单选时是否裁剪 */
@property (nonatomic, assign) BOOL canEdit;

/** 单选时裁剪框是否为圆形 */
@property (nonatomic, assign) BOOL isCircular;

@property (nonatomic, assign) ZLAssetMediaType mediaType;

//当前已经选择的图片
@property (nonatomic, strong) NSMutableArray<ZLSelectPhotoModel *> *arraySelectPhotos;

//选则完成后回调
@property (nonatomic, copy) void (^DoneBlock)(NSArray<ZLSelectPhotoModel *> *selPhotoModels, BOOL isSelectOriginalPhoto);

//编辑完成后的回调
@property (copy, nonatomic) void (^editCompletion)(UIImage *seletedImage,NSString *filePath);

//取消选择后回调
@property (nonatomic, copy) void (^CancelBlock)();

@end
