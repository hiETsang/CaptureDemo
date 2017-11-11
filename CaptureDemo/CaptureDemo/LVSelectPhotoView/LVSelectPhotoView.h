//
//  LVSelectPhotoView.h
//  CaptureDemo
//
//  Created by canoe on 2017/11/6.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "ZLCollectionCell.h"
#import "ZLPhotoTool.h"
#import "ZLSelectPhotoModel.h"

@interface LVSelectPhotoView : UIView

/** 是否需要原图 */
//@property (nonatomic,assign) BOOL originalPhoto;

/** 是否单选 */
//@property (nonatomic,assign) BOOL selectOnlyOne;

//相册
@property (nonatomic,strong) PHAssetCollection *assetCollection;

//媒体类型 图片或者视频  Default : ZLAssetMediaTypeVideoAndImage
@property (nonatomic,assign) ZLAssetMediaType mediaType;

//当前已经选择的图片
@property (nonatomic,strong) NSMutableArray<ZLSelectPhotoModel *> *arraySelectPhotos;

//选择完成后回调，返回未裁截原始图片
@property (nonatomic,copy) void (^DoneBlock)(NSArray<ZLSelectPhotoModel *> *selPhotoModels);

//开始初始化数据
- (void)starInitData;

@end
