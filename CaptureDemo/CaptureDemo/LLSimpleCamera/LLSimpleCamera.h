//
//  CameraViewController.h
//  LLSimpleCamera
//
//  Created by Ömer Faruk Gül on 24/10/14.
//  Copyright (c) 2014 Ömer Farul Gül. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    LLCameraPositionRear,
    LLCameraPositionFront
} LLCameraPosition;

typedef enum : NSUInteger {
    // The default state has to be off
    LLCameraFlashOff,
    LLCameraFlashOn,
    LLCameraFlashAuto
} LLCameraFlash;

typedef enum : NSUInteger {
    // The default state has to be off
    LLCameraMirrorOff,
    LLCameraMirrorOn,
    LLCameraMirrorAuto
} LLCameraMirror;

extern NSString *const LLSimpleCameraErrorDomain;
typedef enum : NSUInteger {
    LLSimpleCameraErrorCodeCameraPermission = 10,
    LLSimpleCameraErrorCodeMicrophonePermission = 11,
    LLSimpleCameraErrorCodeSession = 12,
    LLSimpleCameraErrorCodeVideoNotEnabled = 13
} LLSimpleCameraErrorCode;

@interface LLSimpleCamera : UIViewController

/**
 * Triggered on device change. 设备切换的回调
 */
@property (nonatomic, copy) void (^onDeviceChange)(LLSimpleCamera *camera, AVCaptureDevice *device);

/**
 * Triggered on any kind of error.返回错误信息
 */
@property (nonatomic, copy) void (^onError)(LLSimpleCamera *camera, NSError *error);

/**
 * Triggered when camera starts recording 开始录制
 */
@property (nonatomic, copy) void (^onStartRecording)(LLSimpleCamera* camera);

/**     拍摄质量
 * Camera quality, set a constants prefixed with AVCaptureSessionPreset.
 * Make sure to call before calling -(void)initialize method, otherwise it would be late.
 */
@property (copy, nonatomic) NSString *cameraQuality;

/**     闪光灯模式
 * Camera flash mode.
 */
@property (nonatomic, readonly) LLCameraFlash flash;

/**     镜像模式
 * Camera mirror mode.
 */
@property (nonatomic) LLCameraMirror mirror;

/**     前后置摄像头
 * Position of the camera.
 */
@property (nonatomic) LLCameraPosition position;

/**     白平衡模式
 * White balance mode. Default is: AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance
 */
@property (nonatomic) AVCaptureWhiteBalanceMode whiteBalanceMode;

/**     是否允许录制视频
 * Boolean value to indicate if the video is enabled.
 */
@property (nonatomic, getter=isVideoEnabled) BOOL videoEnabled;

/**     是否正在录制视频
 * Boolean value to indicate if the camera is recording a video at the current moment.
 */
@property (nonatomic, getter=isRecording) BOOL recording;

/**     是否允许缩放
 * Boolean value to indicate if zooming is enabled.
 */
@property (nonatomic, getter=isZoomingEnabled) BOOL zoomingEnabled;

/**     最大缩放比例。没有作用
 * Float value to set maximum scaling factor
 */
@property (nonatomic, assign) CGFloat maxScale;

/**     自动调整方向
 * Fixess the orientation after the image is captured is set to Yes.
 * see: http://stackoverflow.com/questions/5427656/ios-uiimagepickercontroller-result-image-orientation-after-upload
 */
@property (nonatomic) BOOL fixOrientationAfterCapture;

/**     点击聚焦
 * Set NO if you don't want ot enable user triggered focusing. Enabled by default.
 */
@property (nonatomic) BOOL tapToFocus;

/**     是否使用设备的方向
 * Set YES if you your view controller does not allow autorotation,
 * however you want to take the device rotation into account no matter what. Disabled by default.
 */
@property (nonatomic) BOOL useDeviceOrientation;

/**     请求相机权限
 * Use this method to request camera permission before initalizing LLSimpleCamera.
 */
+ (void)requestCameraPermission:(void (^)(BOOL granted))completionBlock;

/**     请求麦克风权限
 * Use this method to request microphone permission before initalizing LLSimpleCamera.
 */
+ (void)requestMicrophonePermission:(void (^)(BOOL granted))completionBlock;

/**     初始化
 * Returns an instance of LLSimpleCamera with the given quality.
 * Quality parameter could be any variable starting with AVCaptureSessionPreset.
 */
- (instancetype)initWithQuality:(NSString *)quality position:(LLCameraPosition)position videoEnabled:(BOOL)videoEnabled;

/**     是否允许视频
 * Returns an instance of LLSimpleCamera with quality "AVCaptureSessionPresetHigh" and position "CameraPositionBack".
 * @param videEnabled: Set to YES to enable video recording.
 */
- (instancetype)initWithVideoEnabled:(BOOL)videoEnabled;

/**     开始
 * Starts running the camera session.
 */
- (void)start;

/**     停止
 * Stops the running camera session. Needs to be called when the app doesn't show the view.
 */
- (void)stop;


/**     拍照带结束动画
 * Capture an image.
 * @param onCapture a block triggered after the capturing the photo.
 * @param exactSeenImage If set YES, then the image is cropped to the exact size as the preview. So you get exactly what you see.
 * @param animationBlock you can create your own animation by playing with preview layer.
 */
-(void)capture:(void (^)(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage animationBlock:(void (^)(AVCaptureVideoPreviewLayer *))animationBlock;

/**     拍照不带结束动画
 * Capture an image.
 * @param onCapture a block triggered after the capturing the photo.
 * @param exactSeenImage If set YES, then the image is cropped to the exact size as the preview. So you get exactly what you see.
 */
-(void)capture:(void (^)(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture exactSeenImage:(BOOL)exactSeenImage;

/**     直接拍照
 * Capture an image.
 * @param onCapture a block triggered after the capturing the photo.
 */
-(void)capture:(void (^)(LLSimpleCamera *camera, UIImage *image, NSDictionary *metadata, NSError *error))onCapture;

/*      开始录制视频
 * Start recording a video with a completion block. Video is saved to the given url.
 */
- (void)startRecordingWithOutputUrl:(NSURL *)url didRecord:(void (^)(LLSimpleCamera *camera, NSURL *outputFileUrl, NSError *error))completionBlock;

/**     停止录制
 * Stop recording video.
 */
- (void)stopRecording;

/**     将相机界面添加到某一个界面
 * Attaches the LLSimpleCamera to another view controller with a frame. It basically adds the LLSimpleCamera as a
 * child vc to the given vc.
 * @param vc A view controller.
 * @param frame The frame of the camera.
 */
- (void)attachToViewController:(UIViewController *)vc withFrame:(CGRect)frame;

/**     切换摄像头
 * Changes the posiition of the camera (either back or front) and returns the final position.
 */
- (LLCameraPosition)togglePosition;

/**     更新闪光灯模式
 * Update the flash mode of the camera. Returns true if it is successful. Otherwise false.
 */
- (BOOL)updateFlashMode:(LLCameraFlash)cameraFlash;

/**     闪光灯是否可用
 * Checks if flash is avilable for the currently active device.
 */
- (BOOL)isFlashAvailable;

/**     手电筒是否可用
 * Checks if torch (flash for video) is avilable for the currently active device.
 */
- (BOOL)isTorchAvailable;

/**     聚焦图层和聚焦动画
 * Alter the layer and the animation displayed when the user taps on screen.
 * @param layer Layer to be displayed
 * @param animation to be applied after the layer is shown
 */
- (void)alterFocusBox:(CALayer *)layer animation:(CAAnimation *)animation;

/**     前置摄像头是否可用
 * Checks is the front camera is available.
 */
+ (BOOL)isFrontCameraAvailable;

/**     后置摄像头是否可用
 * Checks is the rear camera is available.
 */
+ (BOOL)isRearCameraAvailable;
@end
