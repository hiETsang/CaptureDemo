//
//  LVAlbumSelectView.m
//  CaptureDemo
//
//  Created by canoe on 2017/11/9.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "LVAlbumSelectView.h"
#import "LVAlbumSelectCell.h"


@interface LVAlbumSelectView () <UITableViewDelegate,UITableViewDataSource>

@end

@implementation LVAlbumSelectView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    [self reloadData];
}

-(void)createUI
{
    self.dataSource = self;
    self.delegate = self;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    LVAlbumSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[LVAlbumSelectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    CGSize size = cell.frame.size;
    size.width *= 2.5;
    size.height *= 2.5;
    ZLPhotoAblumList *model = self.dataArray[indexPath.row];
    [[ZLPhotoTool sharePhotoTool] requestImageForAsset:model.headImageAsset size:size resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image, NSDictionary *info) {
        cell.thumbnailImgView.image = image;
    }];
    cell.nameLabel.text = model.title;
    cell.countLabel.text = [NSString stringWithFormat:@"%ld", model.count];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZLPhotoAblumList *model = self.dataArray[indexPath.row];
    if (self.didSelectAlbum) {
        self.didSelectAlbum(model);
    }
}

@end
