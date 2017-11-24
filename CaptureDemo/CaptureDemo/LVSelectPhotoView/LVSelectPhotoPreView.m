//
//  LVSelectPhotoPreView.m
//  CaptureDemo
//
//  Created by canoe on 2017/11/6.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "LVSelectPhotoPreView.h"
#import "ZLPhotoTool.h"
#import "PHAsset+ChangeForUrl.h"
#import "LLVideoEditor.h"
#import "UIImage+ZL.h"
#import "XCropVideoTool.h"

/***  当前屏幕宽度 */
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
/***  当前屏幕高度 */
#define kScreenHeight  [[UIScreen mainScreen] bounds].size.height

@interface LVSelectPhotoPreView ()<UIScrollViewDelegate>
@property(nonatomic, assign) BOOL isImageAsset;//是否是图片
@property(nonatomic, assign) BOOL isSquare;//图片或者视频是否是正方形
@property(nonatomic, assign) BOOL isSquareRatio;//当前状态是否缩放成正方形显示

@property(nonatomic, assign) float minZoomScale;// 默认0.75

//用于展示大图的ScrollView
@property(nonatomic, strong) UIScrollView *scrollView;

//缩放按钮
@property(nonatomic, strong) UIButton *scaleButton;

//图片
@property(nonatomic, strong) UIImageView *imageView;

//视频播放
@property(nonatomic, strong) UIView *videoView;
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) AVPlayerItem *playerItem;

@end

@implementation LVSelectPhotoPreView


#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageView];
        [self.scrollView addSubview:self.videoView];
        [self addSubview:self.scaleButton];
        self.isSquare = NO;
        self.isSquareRatio = YES;
        self.minZoomScale = 0.75;
    }
    return self;
}

#pragma mark - get

-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollView.backgroundColor = [UIColor whiteColor];
        scrollView.contentSize = CGSizeMake(0, 0);
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.maximumZoomScale = 3.0;
        scrollView.minimumZoomScale = 1.0;
        scrollView.multipleTouchEnabled = YES;
        scrollView.delegate = self;
        _scrollView = scrollView;
    }
    return _scrollView;
}

-(UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

-(UIView *)videoView
{
    if (!_videoView) {
        _videoView = [[UIView alloc] init];
    }
    return _videoView;
}

-(UIButton *)scaleButton
{
    if (!_scaleButton) {
        _scaleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _scaleButton.frame = CGRectMake(12, self.frame.size.height - 42, 30, 30);
        _scaleButton.backgroundColor = [UIColor lightGrayColor];
        [_scaleButton setImage:[UIImage imageNamed:@"scale"] forState:UIControlStateNormal];
        _scaleButton.clipsToBounds = YES;
        _scaleButton.layer.cornerRadius = 15;
        [_scaleButton addTarget:self action:@selector(scaleButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _scaleButton;
}

#pragma mark - set

-(void)setIsImageAsset:(BOOL)isImageAsset
{
    _isImageAsset = isImageAsset;
    self.scrollView.zoomScale = 1.0;
    if (_isImageAsset) {
        self.videoView.hidden = YES;
        self.imageView.hidden = NO;
        self.scrollView.maximumZoomScale = 3.0;
        self.scrollView.minimumZoomScale = self.minZoomScale;
        if (self.player) {
            [self.player pause];
        }
    }else
    {
        self.videoView.hidden = NO;
        self.imageView.hidden = YES;
        self.scrollView.maximumZoomScale = 1.0;
        self.scrollView.minimumZoomScale = 1.0;
    }
}

-(void)setIsSquare:(BOOL)isSquare
{
    _isSquare = isSquare;
    if (self.isImageAsset && !isSquare) {
        self.scrollView.minimumZoomScale = self.minZoomScale;
    }else
    {
        self.scrollView.minimumZoomScale = 1.0;
    }
    self.scaleButton.hidden = isSquare?YES:NO;
}

-(void)setAsset:(PHAsset *)asset
{
    if (_asset && _asset == asset) {
        return;
    }
    
    _asset = asset;
    
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        self.isImageAsset = NO;
        [self configVideoView];
    }else
    {
        self.isImageAsset = YES;
        
        [self configImageView];
    }
}

#pragma mark - 视频显示
-(void)configVideoView
{
    [[ZLPhotoTool sharePhotoTool] requestVideoWithAsset:self.asset completion:^(AVPlayerItem *playerItem, NSDictionary *dictInfo) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.playerLayer) {
                [self.playerLayer removeFromSuperlayer];
            }
            self.playerItem = playerItem;
            self.player = [AVPlayer playerWithPlayerItem:playerItem];
            self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
            self.player.volume = 0.0;
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
            [self resetVideoSize];
            [self.videoView.layer addSublayer:self.playerLayer];
            [self.player play];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        });
    }];
}

//根据视频大小重新设置视频位置
-(void)resetVideoSize
{
    CGFloat scrollViewH = self.scrollView.bounds.size.height;
    CGFloat videoW = _asset.pixelWidth;
    CGFloat videoH = _asset.pixelHeight;
    self.isSquare = (videoW == videoH)?YES:NO;
    if (videoW > videoH) {
        self.videoView.frame = CGRectMake(0, 0, videoW * scrollViewH/videoH, scrollViewH);
        self.playerLayer.frame = self.videoView.bounds;
        self.scrollView.contentOffset = CGPointMake((self.videoView.frame.size.width - self.videoView.frame.size.height)/2, 0);
    }else
    {
        self.videoView.frame = CGRectMake(0, 0, scrollViewH, videoH * scrollViewH/videoW);
        self.playerLayer.frame = self.videoView.bounds;
        self.scrollView.contentOffset = CGPointMake(0, (self.videoView.frame.size.height - self.videoView.frame.size.width)/2);
    }
    self.scrollView.contentSize = self.videoView.frame.size;
    
    self.isSquareRatio = YES;
}

#pragma mark - 图片显示
- (void)configImageView
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN(kScreenWidth, 500.f);
    CGSize size = CGSizeMake(width*scale, width*scale*self.asset.pixelHeight/self.asset.pixelWidth);
    
    [[ZLPhotoTool sharePhotoTool] requestImageForAsset:self.asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.imageView.image = image;
            [self resetMinZoomScale];
            [self resetSubviewSize];
        });
    }];
}

-(void)resetSubviewSize
{
    [self.scrollView setZoomScale:1.0 animated:YES];
    CGFloat scrollViewH = self.scrollView.bounds.size.height;
    
    UIImage *image = self.imageView.image;
    CGFloat imageW = image.size.width;
    CGFloat imageH = image.size.height;
    self.isSquare = (imageH == imageW) ? YES:NO;
    
    CGFloat ratioW = scrollViewH / imageW;
    CGFloat ratioH = scrollViewH / imageH;
    
    if (imageW == imageH) {
        self.imageView.frame = self.scrollView.bounds;
    }else if(ratioH > ratioW)
    {
        self.imageView.frame = CGRectMake(0, 0, imageW * ratioH, scrollViewH);
    }else
    {
        self.imageView.frame = CGRectMake(0, 0, scrollViewH, imageH * ratioW);
    }
    self.scrollView.contentOffset = CGPointMake(self.imageView.center.x - self.scrollView.center.x,self.imageView.center.y - self.scrollView.center.y);
    self.scrollView.contentSize = self.imageView.frame.size;
    
    self.isSquareRatio = YES;
}

#pragma mark - 根据图片尺寸重新定义最小缩放比例
-(void)resetMinZoomScale
{
    CGSize size = self.imageView.image.size;
    if (size.width > size.height) {
        if (size.height/size.width > 0.75) {
            self.minZoomScale = size.height/size.width;
        }else
        {
            self.minZoomScale = 0.75;
        }
    }else if(size.height > size.width)
    {
        if (size.width/size.height > 0.75) {
            self.minZoomScale = size.width/size.height;
        }else
        {
            self.minZoomScale = 0.75;
        }
    }else
    {
        self.minZoomScale = 1.0;
    }
}

#pragma mark - 获取当前预览状态下的视频或者图片（原图）
-(void)getCurrentStateImageOrVideoCompletionBlock:(void (^)(BOOL isImage, UIImage *image, NSURL *url))completionBlock
{
    __weak __typeof(self)weakSelf = self;
    if (self.isImageAsset) {
        [[ZLPhotoTool sharePhotoTool] requestImageForAsset:self.asset scale:1 resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image) {
            CGRect rect = [weakSelf getCurrentShowImageRectOffsetWithImage:image];
            UIImage *resultImage = [UIImage imageWithSourceImage:[UIImage fixOrientation:image] clipRect:rect];
            if (completionBlock) {
                completionBlock(YES,resultImage,nil);
            }
        }];
    }else
    {
        [self.asset getURLCompletionBlock:^(NSURL *responseURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSURL *exportUrl = [[[weakSelf applicationDocumentsDirectory]
                                         URLByAppendingPathComponent:@"output"] URLByAppendingPathExtension:@"mov"];
                    
                    LLVideoEditor *videoEditor = [[LLVideoEditor alloc] initWithVideoURL:responseURL];
                    //需求是超过60秒截取前60秒
                    if (self.asset.duration > 60) {
                        [videoEditor trimStartTime:0 duration:60];
                    }
                    //旋转
                    if ([XCropVideoTool degressFromVideoFileWithURL:responseURL] == 90) {
                        [videoEditor rotate:LLRotateDegree90];
                    }
                    //裁切
                    [videoEditor crop:[weakSelf getCurrentShowVideoRectOffset]];
                    //导出
                    [videoEditor exportToUrl:exportUrl completionBlock:^(AVAssetExportSession *session) {
                        switch (session.status) {
                            case AVAssetExportSessionStatusCompleted: {
                                // show the cropped video
                                completionBlock(NO,nil,session.outputURL);
                                break;
                            }
                            case AVAssetExportSessionStatusFailed:
                                NSLog(@"Failed:%@",session.error);
                                break;
                            case AVAssetExportSessionStatusCancelled:
                                NSLog(@"Canceled:%@", session.error);
                                break;
                            default:
                                break;
                        }
                    }];
                });
        }];
        
    }
}

//获取当前显示的图片或者视频相对原始对象的偏移量
-(CGRect) getCurrentShowImageRectOffsetWithImage:(UIImage *)image
{
    float imageX = self.scrollView.contentOffset.x;
    float imageY = self.scrollView.contentOffset.y;
    float imageW = self.scrollView.frame.size.width;
    float imageH = self.scrollView.frame.size.width;
    
    float ratioX = 0;   //相对原图x的偏移量
    float ratioY = 0;   //相对原图y的偏移量
    float ratioW = 0;   //相对原图展示的宽度
    float ratioH = 0;   //相对原图所展示的高度
    
    if (self.scrollView.zoomScale >= 1.0) {
        ratioW = imageW /self.imageView.frame.size.width * image.size.width;
        ratioH = imageH /self.imageView.frame.size.height * image.size.height;
    }else
    {
        //缩放比例小于1.0
        if (image.size.height > image.size.width) {
            ratioW = image.size.width;
            ratioH = imageH /self.imageView.frame.size.height * image.size.height;
        }else
        {
            ratioW = imageW /self.imageView.frame.size.width * image.size.width;
            ratioH = image.size.height;
        }
    }
    ratioX = [self roundFloat:imageX / self.imageView.frame.size.width * image.size.width];
    ratioY = [self roundFloat:imageY / self.imageView.frame.size.height * image.size.height];
    ratioW = [self roundFloat:ratioW];
    ratioH = [self roundFloat:ratioH];
    
    return CGRectMake(ratioX, ratioY, ratioW, ratioH);
}

-(CGRect) getCurrentShowVideoRectOffset
{
    float imageX = self.scrollView.contentOffset.x;
    float imageY = self.scrollView.contentOffset.y;
    float imageW = self.scrollView.frame.size.width;
    float imageH = self.scrollView.frame.size.width;
    float ratioX = 0;   //相对原图x的偏移量
    float ratioY = 0;   //相对原图y的偏移量
    float ratioW = 0;   //相对原图展示的宽度
    float ratioH = 0;   //相对原图所展示的高度
    ratioX = [self roundFloat:imageX / self.videoView.frame.size.width * self.asset.pixelWidth];
    ratioY = [self roundFloat:imageY / self.videoView.frame.size.height * self.asset.pixelHeight];
    ratioW = imageW /self.videoView.frame.size.width * self.asset.pixelWidth;
    ratioH = imageH /self.videoView.frame.size.height * self.asset.pixelHeight;
    return CGRectMake(ratioX, ratioY, ratioW, ratioH);
}



#pragma mark - other
//因为精度问题导致裁剪错误
-(float)roundFloat:(float)num{
    return round(num);
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - playerItemDidReachEnd
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    [playerItem seekToTime:kCMTimeZero];
}

- (void)releasePlayer {
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    self.player = nil;
    self.playerItem = nil;
}

#pragma mark - scrollViewDelegate
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"zoomScale ---------> %.2f",scrollView.zoomScale);
    if (self.isImageAsset) {
        CGSize boundsSize = self.scrollView.bounds.size;
        CGRect contentsFrame = self.imageView.frame;
        
        if (contentsFrame.size.width < boundsSize.width) {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0;
        } else {
            contentsFrame.origin.x = 0.0;
        }
        if (contentsFrame.size.height < boundsSize.height) {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0;
        } else {
            contentsFrame.origin.y = 0.0;
        }
        
        self.imageView.frame = contentsFrame;
    }
}

#pragma mark - 点击放大缩小按钮
-(void)scaleButtonClick:(UIButton *)button
{
    if (self.isImageAsset) {
        //图片
        //已经正方形显示
        if (self.isSquareRatio) {
            [self.scrollView setZoomScale:self.minZoomScale animated:YES];
            self.isSquareRatio = NO;
        }else
        {
            [self resetSubviewSize];
        }
    }else
    {
        //视频
        //已经缩放成正方形显示
        if (self.isSquareRatio) {
            self.videoView.frame = self.scrollView.frame;
            self.playerLayer.frame = self.videoView.bounds;
            self.scrollView.contentOffset = CGPointMake(0, 0);
            self.scrollView.contentSize = self.videoView.frame.size;
            self.isSquareRatio = NO;
        }else
        {
            [self resetVideoSize];
        }
    }
}

-(void)dealloc
{
    [self releasePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
