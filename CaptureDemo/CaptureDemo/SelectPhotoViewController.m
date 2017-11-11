//
//  SelectPhotoViewController.m
//  CaptureDemo
//
//  Created by canoe on 2017/11/7.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "SelectPhotoViewController.h"

#import "LVSelectPhotoView.h"
#import "LVSelectPhotoPreView.h"
#import "LVAlbumSelectView.h"
#import "ZLPhotoTool.h"

/***  当前屏幕宽度 */
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
/***  当前屏幕高度 */
#define kScreenHeight  [[UIScreen mainScreen] bounds].size.height

@interface SelectPhotoViewController ()

@property(nonatomic, strong) LVSelectPhotoView *selectView;

@property(nonatomic, strong) LVSelectPhotoPreView *preView;

@property(nonatomic, strong) LVAlbumSelectView *albumView;

@property(nonatomic, strong) UIButton *albunmButton;

@end

@implementation SelectPhotoViewController

-(LVAlbumSelectView *)albumView
{
    if (!_albumView) {
        _albumView = [[LVAlbumSelectView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight - 64) style:UITableViewStylePlain];
        [self.view addSubview:_albumView];
        __weak __typeof(self)weakSelf = self;
        [_albumView setDidSelectAlbum:^(ZLPhotoAblumList *collectionModel) {
            [weakSelf alunmButtonClick];
            weakSelf.selectView.assetCollection = collectionModel.assetCollection;
            [weakSelf.albunmButton setTitle:collectionModel.title forState:UIControlStateNormal];
        }];
    }
    return _albumView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 63.3, [[UIScreen mainScreen] bounds].size.width, 0.7)];
    lineView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:lineView];
    
    self.preView = [[LVSelectPhotoPreView alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width)];
    self.selectView = [[LVSelectPhotoView alloc] initWithFrame:CGRectMake(0, 64 + [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 44 - [[UIScreen mainScreen] bounds].size.width)];
    [self.view addSubview:self.selectView];
    [self.view addSubview:self.preView];
    
    __weak __typeof(self)weakSelf = self;
    [self.selectView setDoneBlock:^(NSArray<ZLSelectPhotoModel *> *selPhotoModels) {
        weakSelf.preView.asset = selPhotoModels[0].asset;
    }];
    
    [self.selectView starInitData];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeSystem];
    [back setTitle:@"返回" forState:UIControlStateNormal];
    back.frame = CGRectMake(15, 22, 40, 40);
    [self.view addSubview:back];
    [back addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *sure = [UIButton buttonWithType:UIButtonTypeSystem];
    [sure setTitle:@"确定" forState:UIControlStateNormal];
    sure.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 55, 22, 40, 40);
    [self.view addSubview:sure];
    [sure addTarget:self action:@selector(sureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *alunm = [UIButton buttonWithType:UIButtonTypeSystem];
    [alunm setTitle:@"所有照片" forState:UIControlStateNormal];
    alunm.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - 40, 22, 80, 40);
    [self.view addSubview:alunm];
    [alunm addTarget:self action:@selector(alunmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.albunmButton = alunm;
}

-(void)alunmButtonClick
{
    if (!self.albumView.dataArray) {
        self.albumView.dataArray = [[ZLPhotoTool sharePhotoTool]getPhotoAblumListMediaType:ZLAssetMediaTypeVideoAndImage];
    }
    if (self.albumView.frame.origin.y == kScreenHeight) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.albumView.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64);
        } completion:nil];
    }else
    {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.albumView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
        } completion:nil];
    }
}

-(void)sureButtonClick:(UIButton *)button
{
    __weak __typeof(self)weakSelf = self;
    [self.preView getCurrentStateImageOrVideoCompletionBlock:^(BOOL isImage,UIImage *image,NSURL *url) {
        if (weakSelf.didEndSelectObject) {
            weakSelf.didEndSelectObject(isImage, image, url);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
}

-(void)backButtonClick:(UIButton *)button
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
