//
//  ZLCollectionCell.m
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLCollectionCell.h"
#import "ZLDefine.h"

@implementation ZLCollectionCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];

    [self.btnSelect setBackgroundImage:[UIImage imageNamed:kZLPhotoBrowserSrcName(@"camera_not_selected")] forState:UIControlStateNormal];

    [self.btnSelect setBackgroundImage:[UIImage imageNamed:kZLPhotoBrowserSrcName(@"camera_selected")] forState:UIControlStateSelected];

    self.mediaTypeImgView.image = [UIImage imageNamed:kZLPhotoBrowserSrcName(@"VideoSendIcon")];
}

@end
