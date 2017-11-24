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

@interface SelectPhotoViewController ()<UIGestureRecognizerDelegate>
{
    CGFloat beginOriginY;
}

@property(nonatomic, strong) UIView *navView;
@property(nonatomic, strong) UIView *topView;//上半部分View 包括导航栏和预览View
@property(nonatomic, strong) UIView *coverView; //上半部分的遮盖视图
@property(nonatomic, strong) UIActivityIndicatorView *actView;//小菊花

@property(nonatomic, strong) LVSelectPhotoView *selectView;
@property(nonatomic, strong) LVSelectPhotoPreView *preView;
@property(nonatomic, strong) LVAlbumSelectView *albumView;

@property(nonatomic, strong) UIButton *albunmButton;
@property(nonatomic, strong) UIButton *backButton;
@property(nonatomic, strong) UIButton *sureButton;

@end

@implementation SelectPhotoViewController

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

-(LVAlbumSelectView *)albumView
{
    if (!_albumView) {
        _albumView = [[LVAlbumSelectView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight - 44) style:UITableViewStylePlain];
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
    
    [self configUI];
    
    [self selectViewSomeBlock];
    
    [self.selectView starInitData];
    
    [self addPanGesture];
}

-(void)configUI
{
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44 + kScreenWidth)];
    [self.view addSubview:self.topView];
    self.topView.backgroundColor = [UIColor whiteColor];
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
    [self.topView addSubview:navView];
    self.navView = navView;
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setTitle:@"返回" forState:UIControlStateNormal];
    back.frame = CGRectMake(11, 3, 36, 36);
    [self.navView addSubview:back];
    back.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:13];
    [back setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.backButton = back;
    
    UIButton *sure = [UIButton buttonWithType:UIButtonTypeCustom];
    [sure setTitle:@"下一步" forState:UIControlStateNormal];
    sure.frame = CGRectMake(kScreenWidth - 56, 3, 40, 36);
    [self.navView addSubview:sure];
    sure.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:13];
    [sure setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sure addTarget:self action:@selector(sureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.sureButton = sure;
    
    UIActivityIndicatorView *actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    actView.center = sure.center;
    [self.navView addSubview:actView];
    actView.color = [UIColor blackColor];
    self.actView = actView;
    
    UIButton *alunm = [UIButton buttonWithType:UIButtonTypeCustom];
    [alunm setTitle:@"所有照片" forState:UIControlStateNormal];
    alunm.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:14];
    [alunm setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    alunm.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - 75, 3, 150, 36);
    [self.navView addSubview:alunm];
    [alunm addTarget:self action:@selector(alunmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.albunmButton = alunm;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, kScreenWidth, 1)];
    lineView.backgroundColor = kRGB(235, 235, 235);
    [self.navView addSubview:lineView];
    
    self.preView = [[LVSelectPhotoPreView alloc] initWithFrame:CGRectMake(0, 44, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width)];
    self.selectView = [[LVSelectPhotoView alloc] initWithFrame:CGRectMake(0, 44 + [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 44 - [[UIScreen mainScreen] bounds].size.width)];
    self.selectView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.selectView];
    [self.topView addSubview:self.preView];
    [self.view insertSubview:self.selectView belowSubview:self.topView];
    
}

#pragma mark - 手势滑动操作
-(void)addPanGesture
{
    //用于滑动
    UIView *dragView = [[UIView alloc] initWithFrame:CGRectMake(40, self.topView.frame.size.height - 40, self.topView.frame.size.width - 40, 40)];
    dragView.backgroundColor = [UIColor clearColor];
    [self.topView addSubview:dragView];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [dragView addGestureRecognizer:panGesture];
    
    //用于点击
    UIView *coverView = [[UIView alloc] initWithFrame:self.preView.frame];
    coverView.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.6];
    coverView.alpha = 0.0;
    [self.topView addSubview:coverView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    [coverView addGestureRecognizer:tapGesture];
    self.coverView = coverView;
    
    [self.topView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"] && object == self.topView) {
        id ID = [change valueForKey:@"new"];
        CGRect rect = [ID CGRectValue];
        CGFloat y = rect.origin.y;
        self.coverView.alpha = (-y) / (CGRectGetHeight(self.topView.bounds) - 44.0);
        NSLog(@"aplha ---------> %f",-y / CGRectGetHeight(self.topView.bounds) - 44.0);
    }
}

-  (void)panGestureAction:(UIPanGestureRecognizer *)panGesture {
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            CGRect topFrame = self.topView.frame;
            CGFloat endOriginY = self.topView.frame.origin.y;
            if (endOriginY > beginOriginY) {
                topFrame.origin.y = (endOriginY - beginOriginY) >= 30 ? 0 : -(CGRectGetHeight(self.topView.bounds)-44);
            } else if (endOriginY < beginOriginY) {
                topFrame.origin.y = (beginOriginY - endOriginY) >= 30 ? -(CGRectGetHeight(self.topView.bounds)-44) : 0;
            }
            
            CGRect collectionFrame = self.selectView.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
            [UIView animateWithDuration:.3f animations:^{
                self.topView.frame = topFrame;
                self.selectView.frame = collectionFrame;
            }];
            break;
        }
        case UIGestureRecognizerStateBegan:
        {
            beginOriginY = self.topView.frame.origin.y;
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            CGPoint translation = [panGesture translationInView:self.view];
            CGRect topFrame = self.topView.frame;
            topFrame.origin.y = translation.y + beginOriginY;
            
            CGRect collectionFrame = self.selectView.frame;
            collectionFrame.origin.y = CGRectGetMaxY(topFrame);
            collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
            
            if (topFrame.origin.y <= 0 && (topFrame.origin.y >= -(CGRectGetHeight(self.topView.bounds)-44))) {
                self.topView.frame = topFrame;
                self.selectView.frame = collectionFrame;
            }
            
            break;
        }
        default:
            break;
    }
}

- (void)tapGestureAction:(UITapGestureRecognizer *)tapGesture {
    CGRect topFrame = self.topView.frame;
    
    topFrame.origin.y = (topFrame.origin.y == 0) ? -(CGRectGetHeight(self.topView.bounds)-44) : 0;
    
    CGRect collectionFrame = self.selectView.frame;
    collectionFrame.origin.y = CGRectGetMaxY(topFrame);
    if (topFrame.origin.y != 0) {
        collectionFrame.size.height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
    }
    [UIView animateWithDuration:.3f animations:^{
        self.topView.frame = topFrame;
        self.selectView.frame = collectionFrame;
    }completion:^(BOOL finished) {
        if (topFrame.origin.y == 0) {
            CGFloat height = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(topFrame);
            self.selectView.frame = CGRectMake(collectionFrame.origin.x, collectionFrame.origin.y, collectionFrame.size.width, height);
        }
    }];
}

#pragma mark - 点击等操作

-(void)selectViewSomeBlock
{
    __weak __typeof(self)weakSelf = self;
    [self.selectView setDoneBlock:^(NSArray<ZLSelectPhotoModel *> *selPhotoModels) {
        weakSelf.preView.asset = selPhotoModels[0].asset;
        if (weakSelf.topView.frame.origin.y != 0) {
            [weakSelf tapGestureAction:nil];
        }
    }];
    
    [self.selectView setCollectionViewWillEndDragging:^(CGFloat velocityY) {
        if (velocityY >= 1.8 && weakSelf.topView.frame.origin.y == 0) {
            [weakSelf tapGestureAction:nil];
        }
    }];
    
    [self.selectView setCollectionViewWillBeginDragging:^(CGFloat contentOffsetY) {
        if (contentOffsetY == 0.0 && weakSelf.topView.frame.origin.y != 0) {
            [weakSelf tapGestureAction:nil];
        }
    }];
}

-(void)alunmButtonClick
{
    if (!self.albumView.dataArray) {
        self.albumView.dataArray = [[ZLPhotoTool sharePhotoTool]getPhotoAblumListMediaType:ZLAssetMediaTypeVideoAndImage];
    }
    if (self.albumView.frame.origin.y == kScreenHeight) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.albumView.frame = CGRectMake(0, 44, kScreenWidth, kScreenHeight - 44);
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
    self.sureButton.hidden = YES;
    self.actView.hidden = NO;
    [self.actView startAnimating];
    __weak __typeof(self)weakSelf = self;
    [self.preView getCurrentStateImageOrVideoCompletionBlock:^(BOOL isImage,UIImage *image,NSURL *url) {
        weakSelf.sureButton.hidden = NO;
        [weakSelf.actView stopAnimating];
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
