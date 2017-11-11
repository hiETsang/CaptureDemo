//
//  LVAlbumSelectCell.m
//  CaptureDemo
//
//  Created by canoe on 2017/11/9.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "LVAlbumSelectCell.h"

@implementation LVAlbumSelectCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self configUI];
    }
    return self;
}

-(void)configUI
{
    self.thumbnailImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 50, 50)];
    self.thumbnailImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.thumbnailImgView.clipsToBounds = YES;
    [self.contentView addSubview:self.thumbnailImgView];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 25, 200, 16)];
    self.nameLabel.font = [UIFont systemFontOfSize:16.0];
    self.nameLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.nameLabel];
    
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 45, 200, 12)];
    self.countLabel.font = [UIFont systemFontOfSize:12.0];
    self.countLabel.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.countLabel];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
