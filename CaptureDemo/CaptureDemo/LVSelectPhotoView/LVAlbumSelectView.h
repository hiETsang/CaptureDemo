//
//  LVAlbumSelectView.h
//  CaptureDemo
//
//  Created by canoe on 2017/11/9.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLPhotoTool.h"

@interface LVAlbumSelectView : UITableView

@property(nonatomic, strong) NSArray *dataArray;

/** 点击某一个相册 */
@property (nonatomic,copy) void (^didSelectAlbum)(ZLPhotoAblumList *collectionModel);

@end
