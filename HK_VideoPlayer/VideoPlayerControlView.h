//
//  VideoPlayerControlView.h
//  HK_VideoPlayer
//
//  Created by houke on 2018/1/19.
//  Copyright © 2018年 houke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VideoPlayerControlView : UIView

//播放进度条
@property(nonatomic,retain)UISlider *progressSlider;
//底部工具栏
@property(nonatomic,retain)UIView *bottomBar;
//显示播放时间的UILabel
@property(nonatomic,retain)UILabel *rightTimeLabel;
//显示播放时间的UILabel
@property(nonatomic,retain)UILabel *leftTimeLabel;
//控制全屏的按钮
@property(nonatomic,retain)UIButton *fullScreenBtn;
//播放暂停按钮
@property(nonatomic,retain)UIButton *playOrPauseBtn;
//关闭按钮
@property(nonatomic,retain)UIButton *closeBtn;
//标题
@property(nonatomic, retain)UIView *titleView;
@property(copy,nonatomic) NSString *playTitle;

@end
