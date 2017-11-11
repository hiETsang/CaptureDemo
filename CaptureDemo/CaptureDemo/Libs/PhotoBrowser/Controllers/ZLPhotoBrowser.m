//
//  ZLPhotoBrowser.m
//  多选相册照片
//
//  Created by long on 15/11/27.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLPhotoBrowser.h"
#import "ZLPhotoBrowserCell.h"
#import "ZLPhotoTool.h"
#import "ZLThumbnailViewController.h"
#import "UITableView+Placeholder.h"
//#import "ZLSeletedOnlyPhotoViewController.h"

@interface ZLPhotoBrowser ()
{
    NSMutableArray<ZLPhotoAblumList *> *_arrayDataSources;
}
@end

@implementation ZLPhotoBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    self.title = GetLocalLanguageTextValue(ZLPhotoBrowserPhotoText);
    
    _arrayDataSources = [NSMutableArray array];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self initNavBtn];
    [self loadAblums];
    [self pushAllPhotoSoon];
}

- (void)initNavBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];

    [btn setImage:[UIImage imageNamed:kZLPhotoBrowserSrcName(@"close_black")] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 25, 44);
    
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.hidesBackButton = YES;
}

- (void)loadAblums
{
    [_arrayDataSources addObjectsFromArray:[[ZLPhotoTool sharePhotoTool] getPhotoAblumListMediaType:self.mediaType]];
}
#pragma mark - 直接push到所有照片界面
- (void)pushAllPhotoSoon
{
    if (_arrayDataSources.count == 0) {
        return;
    }
    NSInteger i = 0;
    for (ZLPhotoAblumList *ablum in _arrayDataSources) {
        if (ablum.assetCollection.assetCollectionSubtype == 209) {
            i = [_arrayDataSources indexOfObject:ablum];
            break;
        }
    }
    [self pushThumbnailVCWithIndex:i animated:NO];
}

- (void)navRightBtn_Click
{
    if (self.CancelBlock) {
        self.CancelBlock();
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [tableView placeholderBaseOnNumber:_arrayDataSources.count iconConfig:^(UIImageView *imageView) {
        imageView.image = [UIImage imageNamed:kZLPhotoBrowserSrcName(@"defaultphoto")]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(@"defaultphoto")];
    } textConfig:^(UILabel *label) {
        label.text = @"无照片";
        label.textColor = [UIColor darkGrayColor];
    }];
    return _arrayDataSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZLPhotoBrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ZLPhotoBrowserCell"];
    
    if (!cell) {
        cell = [[kZLPhotoBrowserBundle loadNibNamed:@"ZLPhotoBrowserCell" owner:self options:nil] lastObject];
    }
    
    ZLPhotoAblumList *ablumList= _arrayDataSources[indexPath.row];
    
    [[ZLPhotoTool sharePhotoTool] requestImageForAsset:ablumList.headImageAsset size:CGSizeMake(65*3, 65*3) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
        cell.headImageView.image = image;
    }];
    cell.labTitle.text = ablumList.title;
    cell.labCount.text = [NSString stringWithFormat:@"(%ld)", ablumList.count];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self pushThumbnailVCWithIndex:indexPath.row animated:YES];
}

- (void)pushThumbnailVCWithIndex:(NSInteger)index animated:(BOOL)animated
{
    ZLPhotoAblumList *ablum = _arrayDataSources[index];
    
    if (self.seleteOnlyOne) {
//        ZLSeletedOnlyPhotoViewController *seleteOnlyOneVc = [[ZLSeletedOnlyPhotoViewController alloc] init];
//        seleteOnlyOneVc.title = ablum.title;
//        seleteOnlyOneVc.assetCollection = ablum.assetCollection;
//        seleteOnlyOneVc.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
//        seleteOnlyOneVc.sender = self;
//        seleteOnlyOneVc.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
//        seleteOnlyOneVc.DoneBlock = self.DoneBlock;
//        seleteOnlyOneVc.CancelBlock = self.CancelBlock;
//        seleteOnlyOneVc.canEdit = self.canEdit;
//        seleteOnlyOneVc.isCircular = self.isCircular;
//        seleteOnlyOneVc.editCompletion = self.editCompletion;
//        seleteOnlyOneVc.mediaType = self.mediaType;
//        
//        [self.navigationController pushViewController:seleteOnlyOneVc animated:animated];
    }else{
        ZLThumbnailViewController *tvc = [[ZLThumbnailViewController alloc] initWithNibName:@"ZLThumbnailViewController" bundle:kZLPhotoBrowserBundle];
        tvc.title = ablum.title;
        tvc.maxSelectCount = self.maxSelectCount;
        tvc.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
        tvc.assetCollection = ablum.assetCollection;
        tvc.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
        tvc.sender = self;
        tvc.DoneBlock = self.DoneBlock;
        tvc.CancelBlock = self.CancelBlock;
        tvc.editCompletion = self.editCompletion;
        tvc.mediaType = self.mediaType;
        [self.navigationController pushViewController:tvc animated:animated];
    }
}
- (void)dealloc
{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
