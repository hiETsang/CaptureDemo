//
//  ZLSelectPhotoModel.h
//  多选相册照片
//
//  Created by long on 15/11/26.
//  Copyright © 2015年 long. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface ZLSelectPhotoModel : NSObject

@property(nonatomic, assign) BOOL highlight;//是否高亮显示
@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy) NSString *localIdentifier;

@end
