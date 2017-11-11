//
//  LVSelectPhotoView.m
//  CaptureDemo
//
//  Created by canoe on 2017/11/6.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "LVSelectPhotoView.h"

/***  当前屏幕宽度 */
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
/***  当前屏幕高度 */
#define kScreenHeight  [[UIScreen mainScreen] bounds].size.height

double const CScalePhotoWidth = 1000;

@interface LVSelectPhotoView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic,strong) NSMutableArray<ZLSelectPhotoModel *> *arrayDataSources;

@property(nonatomic, strong) NSIndexPath *selectIndexPath;//当前选中的图片的位置

@end

@implementation LVSelectPhotoView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.arraySelectPhotos = [NSMutableArray new];
        self.arrayDataSources = [NSMutableArray new];
        [self addSubview:self.collectionView];
        self.mediaType = ZLAssetMediaTypeVideoAndImage;
    }
    return self;
}

-(void)setAssetCollection:(PHAssetCollection *)assetCollection
{
    _assetCollection = assetCollection;
    [self.arrayDataSources removeAllObjects];
    NSArray *assetArray = [[ZLPhotoTool sharePhotoTool] getAssetsInAssetCollection:_assetCollection ascending:NO mediaType:self.mediaType];
    for (NSInteger i = 0; i < assetArray.count; i++) {
        ZLSelectPhotoModel *model = [[ZLSelectPhotoModel alloc] init];
        model.asset = assetArray[i];
        model.localIdentifier = [(PHAsset *)assetArray[i] localIdentifier];
        [self.arrayDataSources addObject:model];
    }
    
    [self configStartIndex];
    [self.collectionView reloadData];
}

- (void)starInitData {
    [self loadAblums];
}

- (void)loadAblums {
    NSMutableArray *dataArray = [NSMutableArray new];
    [dataArray addObjectsFromArray:[[ZLPhotoTool sharePhotoTool] getPhotoAblumListMediaType:self.mediaType]];
    if (dataArray.count == 0) {
        return;
    }
    for (ZLPhotoAblumList *ablum in dataArray) {
        //全部照片
        if (ablum.assetCollection.assetCollectionSubtype == 209) {
            self.assetCollection = ablum.assetCollection;
            break;
        }
    }
}

-(void)configStartIndex
{
    self.selectIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    ZLSelectPhotoModel *selectModel = _arrayDataSources[0];
    selectModel.highlight = YES;
    
    ZLSelectPhotoModel *model = [[ZLSelectPhotoModel alloc] init];
    model.asset = selectModel.asset;
    model.localIdentifier = selectModel.asset.localIdentifier;
    [self.arraySelectPhotos removeAllObjects];
    [self.arraySelectPhotos addObjectsFromArray:@[model]];
    if (self.DoneBlock) {
        self.DoneBlock(self.arraySelectPhotos);
    }
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake((kViewWidth-3)/4, (kViewWidth-3)/4);
        layout.minimumInteritemSpacing = 1;
        layout.minimumLineSpacing = 1;
        layout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _collectionView = collectionView;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerNib:[UINib nibWithNibName:@"ZLCollectionCell" bundle:kZLPhotoBrowserBundle] forCellWithReuseIdentifier:@"ZLCollectionCell"];
    }
    
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrayDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLCollectionCell" forIndexPath:indexPath];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    
    ZLSelectPhotoModel *model = self.arrayDataSources[indexPath.row];
    
    CGSize size = cell.frame.size;
    size.width *= 2.5;
    size.height *= 2.5;
    PHAsset *asset = model.asset;
    [[ZLPhotoTool sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image, NSDictionary *info) {
            cell.imageView.image = image;
    }];
    
    cell.btnSelect.hidden = YES;
    cell.coverWhiteView.hidden = model.highlight?NO:YES;
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        cell.videoView.hidden = NO;
        int minutes = (int)asset.duration / 60;
        int seconds = (int)asset.duration % 60;
        cell.videoTimeLabel.text = [NSString stringWithFormat:@"%.2d:%.2d",minutes,seconds];
    }else{
        cell.videoView.hidden = YES;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLSelectPhotoModel *selectModel = _arrayDataSources[indexPath.row];
    
//    if (![[ZLPhotoTool sharePhotoTool] judgeAssetisInLocalAblum:selectModel.asset]) {
//        ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowseriCloudPhotoText));
//        return;
//    }

    ZLSelectPhotoModel *model = [[ZLSelectPhotoModel alloc] init];
    model.asset = selectModel.asset;
    model.localIdentifier = selectModel.asset.localIdentifier;
    [self.arraySelectPhotos removeAllObjects];
    [self.arraySelectPhotos addObjectsFromArray:@[model]];
    if (self.DoneBlock) {
        self.DoneBlock(self.arraySelectPhotos);
    }
    
    //将原来选中的取消选中，改成选中当前的
    if ([self.selectIndexPath isEqual:indexPath]) {
        return;
    }
    ZLSelectPhotoModel *previousModel = _arrayDataSources[self.selectIndexPath.row];
    previousModel.highlight = NO;
    selectModel.highlight = YES;
    [collectionView reloadItemsAtIndexPaths:@[self.selectIndexPath,indexPath]];
    self.selectIndexPath = indexPath;
}

- (void)dealloc
{
}

@end
