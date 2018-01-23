//
//  VideoListPlayer.m
//  HK_VideoPlayer
//
//  Created by houke on 2018/1/19.
//  Copyright © 2018年 houke. All rights reserved.
//

#import "VideoListPlayer.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "UIViewExt.h"
#import <AVFoundation/AVFoundation.h>
#import "Header.h"

@interface VideoListPlayer()
{
    double anglet;
}
@property(atomic, strong) id<IJKMediaPlayback> player;
@property(assign, nonatomic)BOOL isTouchDownProgress;

@end


@implementation VideoListPlayer
NSString *const kHTPlayerFinishedPlayNotificationKey  = @"com.hotoday.kHTPlayerFinishedPlayNotificationKey";
NSString *const kHTPlayerFullScreenBtnNotificationKey = @"com.hotoday.kHTPlayerFullScreenBtnNotificationKey";
NSString *const kHTPlayerLoadingCompleteNotificationKey = @"com.hotoday.kHTPlayerLoadingCompleteNotificationKey";


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(IsEnableWIFIVideoPlay) name:@"IsEnableWIFIVideoPlay" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(IsEnable3GVideoPause) name:@"IsEnable3GVideoPause" object:nil];
        
        // 单击 显示或者隐藏工具栏
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        if (!self.playerControl) {
            self.playerControl = [[VideoPlayerControlView alloc]initWithFrame:self.frame];
            [self addSubview:self.playerControl];
            self.playerControl.alpha = 0.0;
            [self addPlayerControlWay];
            
        }
        
        
        // 双击暂停或者播放
        UITapGestureRecognizer* doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        // 双击手势确定监测失败才会触发单击手势的相应操作
        [singleTap requireGestureRecognizerToFail:doubleTap];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        
    }
    return self;
}
-(void)IsEnableWIFIVideoPlay
{
    [self videoPlay];
}
-(void)IsEnable3GVideoPause
{
    //视频暂停
    [self videoPause];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"您正在使用2G/3G/4G网络，是否继续播放？"  message:nil delegate:self cancelButtonTitle:@"继续播放" otherButtonTitles:@"暂停播放", nil];
    [alert show];
}
- (instancetype)initWithFrame:(CGRect)frame videoURLStr:(NSString *)videoURLStr{
    self = [self initWithFrame:frame];
    if (self) {
        self.frame = frame;
        self.backgroundColor = [UIColor blackColor];
        self.videoURLStr = videoURLStr;
    }
    return self;
}
-(void)setPlayTitle:(NSString *)playTitle
{
    self.playerControl.playTitle = playTitle;
}
-(void)setVideoURLStr:(NSString *)videoURLStr
{
    _videoURLStr = videoURLStr;
    if (self.player) {
        [self.player stop];
        [self.player shutdown];
        [self.player.view removeFromSuperview];
    }
    [self addVideoPlayerWith:videoURLStr];
}
-(void)addPlayerControlWay
{
    [self.playerControl.playOrPauseBtn addTarget:self action:@selector(PlayOrPause:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerControl.closeBtn addTarget:self action:@selector(toNormalSize:) forControlEvents:UIControlEventTouchUpInside];
    [self.playerControl.fullScreenBtn addTarget:self action:@selector(fullScreenAction:) forControlEvents:UIControlEventTouchUpInside];
    // slider开始滑动事件
    [self.playerControl.progressSlider addTarget:self action:@selector(TouchBeganProgress:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [self.playerControl.progressSlider addTarget:self action:@selector(changeProgress:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [self.playerControl.progressSlider addTarget:self action:@selector(updateProgress:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
}
//添加播放器
-(void)addVideoPlayerWith:(NSString *)str
{
    
#ifdef DEBUG
    //    [IJKFFMoviePlayerController setLogReport:YES];
    //    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:NO];
    // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:str] withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.bounds;
    self.player.scalingMode = MPMovieScalingModeAspectFill;
    [self installMovieNotificationObservers];
    self.player.shouldAutoplay = YES;
    self.player.allowsMediaAirPlay = YES;
    self.autoresizesSubviews = YES;
    [self.player prepareToPlay];
    
    [self insertSubview:self.player.view belowSubview:self.playerControl];
    [self.player play];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshMediaControl];
    });
}
#pragma Mark IJKPlayer播放器  注册通知与回调方法
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMoviePlayerPlaybackStateDidChangeNotification object:_player];
}
-(void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter]postNotificationName:kHTPlayerLoadingCompleteNotificationKey object:nil];
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}
-(void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    
    switch (_player.playbackState)
    {
        case MPMoviePlaybackStateStopped: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case MPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            
            break;
        }
        case MPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case MPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case MPMoviePlaybackStateSeekingForward:
        case MPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}
-(void)moviePlayBackDidFinish:(NSNotification*)notification
{
    self.playerControl.playOrPauseBtn.selected = YES;
    //播放完成后的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kHTPlayerFinishedPlayNotificationKey object:nil];
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case MPMovieFinishReasonPlaybackEnded:
            
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            
            break;
        case MPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case MPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}
-(void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    MPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & MPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
        //        if (_waitingView) {
        //            [_waitingView removeFromSuperview];
        //            _waitingView = nil;
        //        }
        
        
        
    } else if ((loadState & MPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
        //        if (!_waitingView) {
        //            self.playerControl.alpha = 0.0;
        //            _waitingView = [[UIImageView alloc]initWithFrame:self.playerControl.playOrPauseBtn.frame];
        //            UIImage *imgWaiting = [UIImage imageNamed:@"waiting"];
        //            _waitingView.image = imgWaiting;
        //            [self addSubview:_waitingView];
        //            anglet = 0.00;
        //            [NSTimer scheduledTimerWithTimeInterval:0.01 target: self selector:@selector(transformAction) userInfo: nil repeats: YES];
        //        }
        
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}
-(void)setDetailID:(NSString *)detailID
{
    _detailID = detailID;
    
}
-(void)transformAction {
    
    if (_waitingView) {
        anglet = anglet + 0.1;//angle角度 double angle;
        if (anglet > 6.28) {//大于 M_PI*2(360度) 角度再次从0开始
            anglet = 0;
        }
        CGAffineTransform transform=CGAffineTransformMakeRotation(anglet);
        _waitingView.transform = transform;
    }
    
}
#pragma mark - 单击手势方法
- (void)handleSingleTap:(UITapGestureRecognizer *)tap{
    [UIView animateWithDuration:0.5 animations:^{
        if (self.playerControl.alpha == 0.0) {
            self.playerControl.alpha = 1.0;
        }else{
            self.playerControl.alpha = 0.0;
        }
        
    } completion:^(BOOL finished) {
        //            显示之后，3秒钟隐藏
        if (self.playerControl.alpha == 1.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.playerControl.alpha = 0.0;
            });
        }else{
        }
    }];
    
    
}
#pragma mark - 双击手势方法
- (void)handleDoubleTap{
    [self PlayOrPause:self.playerControl.playOrPauseBtn];
}

#pragma mark 播放尺寸类型
-(void)setScreenType:(UIHTPlayerSizeType)screenType{
    _screenType = screenType;
    switch (screenType) {
            //视频全屏,隐藏标题,不隐藏 closeBtn
        case UIHTPlayerSizeFullScreenType:
        {
            self.playerControl.closeBtn.hidden = NO;
            self.playerControl.titleView.hidden = YES;
            self.playerControl.alpha = 1.0;
            
        }
            break;
            //详情大小,都隐藏
        case UIHTPlayerSizeDetailScreenType:
        {
            self.playerControl.closeBtn.hidden = YES;
            self.playerControl.titleView.hidden = YES;
        }
            break;
            //列表详情大小不隐藏标题,隐藏 closeBtn
        case UIHTPlayerSizeRecoveryScreenType:
        {
            self.playerControl.titleView.hidden = NO;
            self.playerControl.closeBtn.hidden = YES;
            
        }
            break;
        case UIHTPlayerSizeOnSiteScreenType:
        {
            self.player.scalingMode = MPMovieScalingModeNone;
            self.playerControl.titleView.hidden = YES;
            self.playerControl.closeBtn.hidden = YES;
            self.playerControl.fullScreenBtn.hidden = YES;
        }
            break;
        default:
            break;
    }
    
}
#pragma mark 控件方法
//全屏时返回原大小
- (void)toNormalSize:(UIButton *)sender{
    [self fullScreenAction:nil];
}
-(void)videoPlay
{
    self.playerControl.playOrPauseBtn.selected = NO;
    [self.player play];
    
}
-(void)videoPause
{
    self.playerControl.playOrPauseBtn.selected = YES;
    [self.player pause];
}

-(void)fullScreenAction:(UIButton *)sender{
    
    if (self.playerControl.alpha == 0.0) return;
    sender.selected = !sender.selected;
    [[NSNotificationCenter defaultCenter] postNotificationName:kHTPlayerFullScreenBtnNotificationKey object:sender];
}
- (void)PlayOrPause:(UIButton *)sender{
    if (!sender.selected) {
        [self.player play];
        sender.selected = !sender.selected;
    } else {
        sender.selected = !sender.selected;
        [self.player pause];
    }
}
// slider结束滑动事件
-(void)updateProgress:(UISlider *)slider
{
    self.player.currentPlaybackTime =self.playerControl.progressSlider.value;
    _isTouchDownProgress = NO;
}
// slider滑动中事件
- (void)changeProgress:(UISlider *)slider{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            self.playerControl.alpha = 0.0;
        }];
    });
    
    _isTouchDownProgress = YES;
    [self refreshMediaControl];
    
}
// slider开始滑动事件
- (void)TouchBeganProgress:(UISlider *)slider{
    _isTouchDownProgress = YES;
    
}
- (void)refreshMediaControl
{
    // duration
    NSTimeInterval duration = _player.duration;
    
    NSInteger intDuration = duration + 0.5;
    if (intDuration > 0) {
        self.playerControl.progressSlider.maximumValue = duration;
        self.playerControl.rightTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intDuration / 60), (int)(intDuration % 60)];
    } else {
        self.playerControl.rightTimeLabel.text = @"/--:--";
        self.playerControl.progressSlider.maximumValue = 1.0f;
    }
    
    // position
    NSTimeInterval position;
    if (_isTouchDownProgress) {
        position = self.playerControl.progressSlider.value;
    } else {
        position = self.player.currentPlaybackTime;
    }
    NSInteger intPosition = position + 0.5;
    if (intDuration > 0) {
        self.playerControl.progressSlider.value = position;
    } else {
        self.playerControl.progressSlider.value = 0.0f;
    }
    self.playerControl.leftTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intPosition / 60),(int)(intPosition % 60)];
    
    // status
    self.playerControl.playOrPauseBtn.selected = [self.player isPlaying];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshMediaControl) object:nil];
    
    [self performSelector:@selector(refreshMediaControl) withObject:nil afterDelay:0.5];
    
}
#pragma mark 横竖屏的各种方法
-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    
    [self removeFromSuperview];
    self.transform = CGAffineTransformIdentity;
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
        self.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.player.view.frame =  CGRectMake(0,0, SCREEN_HEIGHT,SCREEN_WIDTH);;
    self.playerControl.frame =CGRectMake(0,0, SCREEN_HEIGHT,SCREEN_WIDTH);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    self.playerControl.fullScreenBtn.selected = YES;
    self.screenType = UIHTPlayerSizeFullScreenType;
}

-(void)toDetailScreen:(UIView *)view
{
    [self removeFromSuperview];
    self.playerControl.alpha= 1;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformIdentity;
        self.frame = view.bounds;
        self.playerControl.frame =  view.bounds;
        self.player.view.frame =  view.bounds;
    }completion:^(BOOL finished) {
        
        [view addSubview:self];
        [view bringSubviewToFront:self];
        
        [UIView animateWithDuration:0.7f animations:^{
            self.playerControl.alpha = 0;
        } completion:^(BOOL finished) {
            //            显示之后，3秒钟隐藏
            if (self.playerControl.alpha == 1.0) {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.playerControl.alpha = 0;
                    
                });
            }
        }];
        
        self.screenType = UIHTPlayerSizeDetailScreenType;
        self.playerControl.fullScreenBtn.selected = NO;
    }];
    
    
}
-(void)reductionWithInterfaceOrientation:(UIView *)view{
    
    [self reduction:view];
}
- (void)reduction:(UIView *)view
{
    [self removeFromSuperview];
    
    [view addSubview:self];
    [view bringSubviewToFront:self];
    self.playerControl.alpha= 0;
    float duration = self.screenType == UIHTPlayerSizeFullScreenType?0.5f:0.0f;
    
    [UIView animateWithDuration:duration animations:^{
        self.transform = CGAffineTransformIdentity;
        self.frame = view.bounds;
        self.player.view.frame = self.bounds;
        self.playerControl.frame = self.bounds;
        
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.7f animations:^{
            self.playerControl.alpha = 1;
        } completion:^(BOOL finished) {
            //            显示之后，3秒钟隐藏
            if (self.playerControl.alpha == 1.0) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.playerControl.alpha = 0;
                });
            }
            
        }];
        
        self.screenType = UIHTPlayerSizeRecoveryScreenType;
        self.playerControl.fullScreenBtn.selected = NO;
    }];
    
}
-(void)releaseWMPlayer
{
    if (self.player) {
        [self.player pause];
        [self removeFromSuperview];
        [self.playerControl removeFromSuperview];
        [self.player shutdown];
        self.playerControl = nil;
    }
}
-(void)willRemoveSubview:(UIView *)subview{
    [super willRemoveSubview:subview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeMovieNotificationObservers];
}

#pragma mark alertDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self videoPlay];
    } else {
        [self videoPause];
        self.playerControl.alpha = 1.0;
        //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //            self.playerControl.alpha = 0.0;
        //        });
    }
}

@end
