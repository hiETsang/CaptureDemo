//
//  ViewController.m
//  CaptureDemo
//
//  Created by canoe on 2017/11/2.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "ViewController.h"
#import "CaptureViewController.h"
#import "SelectPhotoViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *preViewImageView;

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) AVPlayerItem *playerItem;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.preViewImageView.image = [UIImage imageNamed:@"pic"];
    
//    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:@""]];
    
    
}

- (IBAction)takePhoto:(id)sender {
    CaptureViewController *vc = [[CaptureViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
    
    [vc setDidFinishCapture:^(UIImage *image) {
        if (self.playerLayer) {
            [self.playerLayer removeFromSuperlayer];
        }
        self.preViewImageView.image = image;
    }];
}

- (IBAction)selectPhoto:(id)sender {
    SelectPhotoViewController *vc = [[SelectPhotoViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
    
    [vc setDidEndSelectObject:^(BOOL isImage, UIImage *image, NSURL *url) {
        if (isImage) {
            if (self.playerLayer) {
                [self.playerLayer removeFromSuperlayer];
            }
            self.preViewImageView.image = image;
        }else
        {
            if (self.playerLayer) {
                [self.playerLayer removeFromSuperlayer];
            }
                self.playerItem = [AVPlayerItem playerItemWithURL:url];
                self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
                self.player.volume = 0.0;
                self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
                self.playerLayer.frame = self.preViewImageView.bounds;
                [self.preViewImageView.layer addSublayer:self.playerLayer];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
                [self.player play];
        }
    }];
}

#pragma mark -- playerItemDidReachEnd
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

-(void)dealloc
{
    [self releasePlayer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
