//
//  ZLShowBigImgViewController.m
//  多选相册照片
//
//  Created by long on 15/11/25.
//  Copyright © 2015年 long. All rights reserved.
//

#import "ZLShowBigImgViewController.h"
#import <Photos/Photos.h>
#import "ZLBigImageCell.h"
#import "ZLDefine.h"
#import "ZLSelectPhotoModel.h"
#import "ZLPhotoTool.h"
#import "ToastUtils.h"
#import "UIView+ZL.h"
//#import "LVImageViewController.h"
/***  当前屏幕宽度 */
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
/***  当前屏幕高度 */
#define kScreenHeight  [[UIScreen mainScreen] bounds].size.height

@interface ZLShowBigImgViewController () <UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    UICollectionView *_collectionView;
    
    NSMutableArray<PHAsset *> *_arrayDataSources;
    UIButton *_navRightBtn;
    
    //底部view
    UIView   *_bottomView;
    UIButton *_btnOriginalPhoto;
    UIButton *_btnDone;
    UIButton *_editBtn;
    
    //双击的scrollView
    UIScrollView *_selectScrollView;
    NSInteger _currentPage;
}

@property (nonatomic, strong) UILabel *labPhotosBytes;

@end

@implementation ZLShowBigImgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initNavBtns];
    [self sortAsset];
    [self initCollectionView];
    [self initBottomView];
    [self changeBtnDoneTitle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.shouldReverseAssets) {
        [_collectionView setContentOffset:CGPointMake((self.assets.count-self.selectIndex-1)*(kViewWidth+kItemMargin), 0)];
    } else {
        [_collectionView setContentOffset:CGPointMake(self.selectIndex*(kViewWidth+kItemMargin), 0)];
    }
    
    [self changeNavRightBtnStatus];
}

- (void)initNavBtns
{
    //left nav btn
    UIImage *navBackImg = [UIImage imageNamed:kZLPhotoBrowserSrcName(@"navBackBtn")]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(@"navBackBtn")];


    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[navBackImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btnBack_Click)];
    
    //right nav btn
    _navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _navRightBtn.frame = CGRectMake(0, 0, 25, 25);
    UIImage *normalImg = [UIImage imageNamed:kZLPhotoBrowserSrcName(@"btn_original_circle")]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(@"btn_original_circle")];
    UIImage *selImg = [UIImage imageNamed:kZLPhotoBrowserSrcName(@"camera_selected")]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(@"camera_selected")];
    [_navRightBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
    [_navRightBtn setBackgroundImage:selImg forState:UIControlStateSelected];
    [_navRightBtn addTarget:self action:@selector(navRightBtn_Click:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_navRightBtn];
}
#pragma mark - 初始化CollectionView
- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = kItemMargin;
    layout.sectionInset = UIEdgeInsetsMake(0, kItemMargin/2, 0, kItemMargin/2);
    layout.itemSize = self.view.bounds.size;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-kItemMargin/2, 0, kViewWidth+kItemMargin, kViewHeight) collectionViewLayout:layout];
    [_collectionView registerClass:[ZLBigImageCell class] forCellWithReuseIdentifier:@"ZLBigImageCell"];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    [self.view addSubview:_collectionView];
}

- (void)initBottomView
{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kViewHeight - 55, kViewWidth, 55)];
    _bottomView.backgroundColor = kRGB(108,120,255);
    
    _btnOriginalPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat btnOriWidth = GetMatchValue(GetLocalLanguageTextValue(ZLPhotoBrowserOriginalText), 15, YES, 30);
    _btnOriginalPhoto.frame = CGRectMake(12, 7, btnOriWidth+25, 30);
    [_btnOriginalPhoto setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserOriginalText) forState:UIControlStateNormal];
    _btnOriginalPhoto.titleLabel.font = [UIFont systemFontOfSize:15];
    [_btnOriginalPhoto setTitleColor:kRGB(80, 180, 234) forState: UIControlStateNormal];
    [_btnOriginalPhoto setTitleColor:kRGB(80, 180, 234) forState: UIControlStateSelected];
    UIImage *normalImg = [UIImage imageNamed:kZLPhotoBrowserSrcName(@"btn_original_circle")]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(@"btn_original_circle")];
    UIImage *selImg = [UIImage imageNamed:kZLPhotoBrowserSrcName(@"camera_selected")]?:[UIImage imageNamed:kZLPhotoBrowserFrameworkSrcName(@"camera_selected")];
    [_btnOriginalPhoto setImage:normalImg forState:UIControlStateNormal];
    [_btnOriginalPhoto setImage:selImg forState:UIControlStateSelected];
    [_btnOriginalPhoto setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
    [_btnOriginalPhoto addTarget:self action:@selector(btnOriginalImage_Click:) forControlEvents:UIControlEventTouchUpInside];
    _btnOriginalPhoto.selected = self.isSelectOriginalPhoto;
    if (self.arraySelectPhotos.count > 0) {
        [self getPhotosBytes];
    }
    [_bottomView addSubview:_btnOriginalPhoto];
    _btnOriginalPhoto.hidden = YES;

    self.labPhotosBytes = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_btnOriginalPhoto.frame)+5, 7, 80, 30)];
    self.labPhotosBytes.font = [UIFont systemFontOfSize:15];
    self.labPhotosBytes.textColor = kRGB(80, 180, 234);
    [_bottomView addSubview:self.labPhotosBytes];
    self.labPhotosBytes.hidden = YES;
    
    _btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDone.frame = CGRectMake(kViewWidth - 99, (55-30)/2.0, 82, 30);
    [_btnDone setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateNormal];
    _btnDone.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    _btnDone.layer.masksToBounds = YES;
    _btnDone.layer.cornerRadius = 15.f;
    [_btnDone setTitleColor:kRGB(177,183,201) forState:UIControlStateNormal];
    [_btnDone setTitleColor:kRGB(108,120,255) forState:UIControlStateSelected];
    [_btnDone setBackgroundColor:[UIColor whiteColor]];
    [_btnDone addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_btnDone];

    _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _editBtn.frame = CGRectMake(0, 0, 53, 55);
    [_editBtn setImage:[UIImage imageNamed:kZLPhotoBrowserSrcName(@"camera_pen_clarity")] forState:UIControlStateNormal];
    [_editBtn setImage:[UIImage imageNamed:kZLPhotoBrowserSrcName(@"camera_pen")] forState:UIControlStateSelected];
    [_editBtn addTarget:self action:@selector(editBtn_click:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_editBtn];
    
    [self.view addSubview:_bottomView];

    [self refreshBtn];
}

#pragma mark - UIButton Actions
- (void)editBtn_click:(UIButton *)btn
{
//    LVImageViewController *imageVc = [[LVImageViewController alloc] init];
//
//    __weak typeof(self) weakSelf = self;
//    imageVc.isBurn = NO;
//    imageVc.sendImageBlock = ^(UIImage *image,NSInteger watchTime){
//        [weakSelf.navigationController dismissViewControllerAnimated:NO completion:nil];
//        if (weakSelf.editCompletion) {
//            weakSelf.editCompletion(image,nil);
//        }
//    };
//    ZLSelectPhotoModel *model = [self.arraySelectPhotos firstObject];
//    [[ZLPhotoTool sharePhotoTool] requestImageForAsset:model.asset scale:1 resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image) {
//
//        imageVc.imageFromCamera = image;
//        [weakSelf presentViewController:imageVc animated:YES completion:nil];
//    }];
}


- (void)btnOriginalImage_Click:(UIButton *)btn
{
    self.isSelectOriginalPhoto = btn.selected = !btn.selected;
    if (btn.selected) {
        if (![self isHaveCurrentPageImage]) {
            [self navRightBtn_Click:_navRightBtn];
        } else {
            [self getPhotosBytes];
        }
    } else {
        self.labPhotosBytes.text = nil;
    }
}

- (void)btnDone_Click:(UIButton *)btn
{
    if (self.arraySelectPhotos.count == 0) {
        PHAsset *asset = _arrayDataSources[_currentPage-1];
        if (![[ZLPhotoTool sharePhotoTool] judgeAssetisInLocalAblum:asset]) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserLoadingText));
            return;
        }
        ZLSelectPhotoModel *model = [[ZLSelectPhotoModel alloc] init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [_arraySelectPhotos addObject:model];
    }
    if (self.btnDoneBlock) {
        self.btnDoneBlock(self.arraySelectPhotos, self.isSelectOriginalPhoto);
    }
}

- (void)btnBack_Click
{
    if (self.onSelectedPhotos) {
        self.onSelectedPhotos(self.arraySelectPhotos, self.isSelectOriginalPhoto);
    }
    
    if (self.isPresent) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        //由于collectionView的frame的width是大于该界面的width，所以设置这个颜色是为了pop时候隐藏collectionView的黑色背景
        _collectionView.backgroundColor = [UIColor clearColor];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)navRightBtn_Click:(UIButton *)btn
{
    if (_arraySelectPhotos.count >= self.maxSelectCount
        && btn.selected == NO) {
        [self getPhotosBytes];
        ShowToastLong(GetLocalLanguageTextValue(ZLPhotoBrowserMaxSelectCountText), self.maxSelectCount);
        return;
    }

    PHAsset *asset = _arrayDataSources[_currentPage-1];
    if (![self isHaveCurrentPageImage]) {
        [btn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        
        if (![[ZLPhotoTool sharePhotoTool] judgeAssetisInLocalAblum:asset]) {
            ShowToastLong(@"%@", GetLocalLanguageTextValue(ZLPhotoBrowserLoadingText));
            return;
        }
        ZLSelectPhotoModel *model = [[ZLSelectPhotoModel alloc] init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [_arraySelectPhotos addObject:model];
    } else {
        [self removeCurrentPageImage];
    }
    
    btn.selected = !btn.selected;
    [self getPhotosBytes];
    [self changeBtnDoneTitle];

    [self refreshBtn];
}
- (void)refreshBtn
{
    _btnDone.selected = (_arraySelectPhotos.count > 0);
    _btnDone.enabled = (_arraySelectPhotos.count > 0);
    _editBtn.selected = _arraySelectPhotos.count == 1;
    _editBtn.enabled = _arraySelectPhotos.count == 1;
}
- (BOOL)isHaveCurrentPageImage
{
    PHAsset *asset = _arrayDataSources[_currentPage-1];
    for (ZLSelectPhotoModel *model in _arraySelectPhotos) {
        if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
            return YES;
        }
    }
    return NO;
}

- (void)removeCurrentPageImage
{
    PHAsset *asset = _arrayDataSources[_currentPage-1];
    for (ZLSelectPhotoModel *model in _arraySelectPhotos) {
        if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
            [_arraySelectPhotos removeObject:model];
            break;
        }
    }
}

#pragma mark - 更新按钮、导航条等显示状态
- (void)changeNavRightBtnStatus
{
    if ([self isHaveCurrentPageImage]) {
        _navRightBtn.selected = YES;
    } else {
        _navRightBtn.selected = NO;
    }
}

- (void)changeBtnDoneTitle
{
    if (self.arraySelectPhotos.count > 0) {
        [_btnDone setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalLanguageTextValue(ZLPhotoBrowserDoneText), self.arraySelectPhotos.count] forState:UIControlStateNormal];
    } else {
        [_btnDone setTitle:GetLocalLanguageTextValue(ZLPhotoBrowserDoneText) forState:UIControlStateNormal];
    }
}

- (void)getPhotosBytes
{
    if (!self.isSelectOriginalPhoto) return;
    
    if (self.arraySelectPhotos.count > 0) {
        weakify(self);
        [[ZLPhotoTool sharePhotoTool] getPhotosBytesWithArray:self.arraySelectPhotos completion:^(NSString *photosBytes) {
            strongify(weakSelf);
            strongSelf.labPhotosBytes.text = [NSString stringWithFormat:@"(%@)", photosBytes];
        }];
    } else {
        self.labPhotosBytes.text = nil;
    }
}

- (void)showNavBarAndBottomView
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:0.3 animations:^{
        _bottomView.top = kViewHeight - _bottomView.height;
        _collectionView.height -= 64;
    }];
}

- (void)hideNavBarAndBottomView
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:0.3 animations:^{
        _bottomView.top = kScreenHeight;
        _collectionView.height += 64;
    }];
}

- (void)sortAsset
{
    _arrayDataSources = [NSMutableArray array];
    if (self.shouldReverseAssets) {
        NSEnumerator *enumerator = [self.assets reverseObjectEnumerator];
        id obj;
        while (obj = [enumerator nextObject]) {
            [_arrayDataSources addObject:obj];
        }
        //当前页
        _currentPage = _arrayDataSources.count-self.selectIndex;
    } else {
        [_arrayDataSources addObjectsFromArray:self.assets];
        _currentPage = self.selectIndex + 1;
    }
    self.title = [NSString stringWithFormat:@"%ld/%ld", _currentPage, _arrayDataSources.count];
}


#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrayDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZLBigImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZLBigImageCell" forIndexPath:indexPath];
    PHAsset *asset = _arrayDataSources[indexPath.row];
    
    cell.asset = asset;
    weakify(self);
    cell.singleTapCallBack = ^() {
        strongify(weakSelf);
        if (strongSelf.navigationController.navigationBar.isHidden) {
            [strongSelf showNavBarAndBottomView];
        } else {
            [strongSelf hideNavBarAndBottomView];
        }
    };
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == (UIScrollView *)_collectionView) {
        //改变导航标题
        CGFloat page = scrollView.contentOffset.x/(kViewWidth+kItemMargin);
        NSString *str = [NSString stringWithFormat:@"%.0f", page];
        _currentPage = str.integerValue + 1;
        self.title = [NSString stringWithFormat:@"%ld/%ld", _currentPage, _arrayDataSources.count];
        [self changeNavRightBtnStatus];
    }
}
- (void)dealloc
{

}
@end
