//
//  CaptureViewController.m
//  CaptureDemo
//
//  Created by canoe on 2017/11/8.
//  Copyright © 2017年 canoe. All rights reserved.
//

#import "CaptureViewController.h"
#import "LVCaptureController.h"
#import "SelectPhotoViewController.h"

@interface CaptureViewController ()

@property(nonatomic, strong) LVCaptureController *capture;

@end

@implementation CaptureViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.capture start];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.capture = [[LVCaptureController alloc] initWithQuality:AVCaptureSessionPresetHigh position:LVCapturePositionRear enableRecording:YES];
    [self.capture attachToViewController:self withFrame:CGRectMake(0, 64, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.width)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - 40,[[UIScreen mainScreen] bounds].size.height - 150 , 80, 80);
    button.backgroundColor = [UIColor lightGrayColor];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = 40;
    [button setTitle:@"拍照" forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    
//    UIButton *photoButton = [UIButton buttonWithType:UIButtonTypeSystem];
//    [photoButton setTitle:@"相册" forState:UIControlStateNormal];
//    photoButton.frame = CGRectMake(20, CGRectGetMinY(button.frame), 50, 80);
//    [self.view addSubview:photoButton];
//    [photoButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [backButton setTitle:@"返回" forState:UIControlStateNormal];
    backButton.frame = CGRectMake(15, 20, 40, 40);
    [self.view addSubview:backButton];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeButton setImage:[UIImage imageNamed:@"exchange"] forState:UIControlStateNormal];
    changeButton.frame = CGRectMake(15,  64 + 15, 40, 40);
    [self.view addSubview:changeButton];
    [changeButton addTarget:self action:@selector(changeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [lightButton setImage:[UIImage imageNamed:@"lightoff"] forState:UIControlStateNormal];
    lightButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 55,  64 + 15, 40, 40);
    [self.view addSubview:lightButton];
    [lightButton addTarget:self action:@selector(lightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

//闪光灯点击
- (void) lightButtonClick:(UIButton *)button
{
    switch (self.capture.flash) {
        case LVCaptureFlashOff:
            [self.capture updateFlashMode:LVCaptureFlashOn];
            [button setImage:[UIImage imageNamed:@"lighton"] forState:UIControlStateNormal];
            break;
        case LVCaptureFlashOn:
            [self.capture updateFlashMode: LVCaptureFlashAuto];
            [button setImage:[UIImage imageNamed:@"lightauto"] forState:UIControlStateNormal];
            break;
        case LVCaptureFlashAuto:
            [self.capture updateFlashMode: LVCaptureFlashOff];
            [button setImage:[UIImage imageNamed:@"lightoff"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    

}

//切换摄像头
- (void) changeButtonClick
{
    [self.capture changePosition];
}


-(void) back
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)selectPhoto:(UIButton *)button
{
    SelectPhotoViewController *vc = [[SelectPhotoViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)takePhoto
{
    __weak __typeof(self)weakSelf = self;
    [self.capture capture:^(LVCaptureController *camera, UIImage *image, NSError *error) {
        if (weakSelf.didFinishCapture) {
            weakSelf.didFinishCapture(image);
        }
        [weakSelf back];
    } exactSeenImage:YES];
}

-(void)changeCameraFrame:(UIButton *)button
{
    self.capture.view.frame = CGRectMake(0, 0, 100, 100);
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
