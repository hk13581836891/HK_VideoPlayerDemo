//
//  VideoListPlayer.h
//  HK_VideoPlayer
//
//  Created by houke on 2018/1/19.
//  Copyright © 2018年 houke. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VideoPlayerControlView.h"

typedef NS_ENUM(NSInteger, UIHTPlayerSizeType) {
    UIHTPlayerSizeFullScreenType     = 0, //全屏
    UIHTPlayerSizeDetailScreenType   = 2,//详情页面显示
    UIHTPlayerSizeRecoveryScreenType = 3,//恢复大小
    UIHTPlayerSizeOnSiteScreenType = 4//在现场
};
extern NSString *const kHTPlayerFinishedPlayNotificationKey; //播放完成通知
extern NSString *const kHTPlayerFullScreenBtnNotificationKey;//全屏通知
extern NSString *const kHTPlayerLoadingCompleteNotificationKey;//视频加载完成通知

@interface VideoListPlayer : UIView

@property(copy,nonatomic)   NSString *detailID;
@property(nonatomic,strong) VideoPlayerControlView *playerControl;
@property(nonatomic,copy) NSString *videoURLStr;//播放地址
@property(nonatomic,copy) NSString *playTitle;//播放地址
@property (assign, nonatomic)UIHTPlayerSizeType screenType;//视频播放形态
//loadingView
@property(nonatomic,retain)UIImageView *waitingView;

- (id)initWithFrame:(CGRect)frame videoURLStr:(NSString *)videoURLStr;
- (void)videoPlay;
-(void)videoPause;
-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation;
-(void)reductionWithInterfaceOrientation:(UIView *)view;
-(void)toDetailScreen:(UIView *)view;
-(void)releaseWMPlayer;

@end
