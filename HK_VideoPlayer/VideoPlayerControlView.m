//
//  VideoPlayerControlView.m
//  HK_VideoPlayer
//
//  Created by houke on 2018/1/19.
//  Copyright © 2018年 houke. All rights reserved.
//

#import "VideoPlayerControlView.h"
#import "UIViewExt.h"
#define kBottomViewHeight 40.0f

@implementation VideoPlayerControlView


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}
-(void)setPlayTitle:(NSString *)playTitle
{
    UILabel *label = [_titleView viewWithTag:100];
    if (label) {
        label.text = playTitle;
    }
}
-(void)setupUI
{
    //   开始或者暂停按钮
    UIImage *img = [UIImage imageNamed:@"video_play"];
    _playOrPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playOrPauseBtn.showsTouchWhenHighlighted = YES;
    [self.playOrPauseBtn setImage:img forState:UIControlStateNormal];
    [self.playOrPauseBtn setImage:[UIImage imageNamed:@"video_pause"] forState:UIControlStateSelected];
    self.playOrPauseBtn.frame = CGRectMake((self.width - img.size.width)/2, (self.height - img.size.height)/2, img.size.width, img.size.height);
    [self addSubview:self.playOrPauseBtn];
    [self addSubview:self.bottomBar];
    [self addSubview:self.closeBtn];
    [self addSubview:self.titleView];
    
}
- (UIView *)titleView
{
    if (_titleView) return _titleView;
    
    _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 33)];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];  // 设置渐变效果
    gradientLayer.bounds = _titleView.bounds;
    gradientLayer.frame = _titleView.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor blackColor] CGColor],(id)[[UIColor clearColor] CGColor], nil];
    gradientLayer.startPoint = CGPointMake(0.0, -3.0);
    gradientLayer.endPoint = CGPointMake(0.0, 1.0);
    [_titleView.layer insertSublayer:gradientLayer atIndex:0];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, self.width - 30, _titleView.height)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:17.0f];
    titleLabel.tag = 100;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    [_titleView addSubview:titleLabel];
    
    return _titleView;
}
//关闭当前视频按钮。
- (UIButton *)closeBtn{
    if (_closeBtn) return _closeBtn;
    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeBtn.showsTouchWhenHighlighted = YES;
    [_closeBtn setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateNormal];
    [_closeBtn setImage:[UIImage imageNamed:@"back_black"] forState:UIControlStateSelected];
    _closeBtn.layer.cornerRadius = 30/2;
    _closeBtn.frame = CGRectMake(0, 0, 50, 50);
    _closeBtn.hidden = YES;
    return _closeBtn;
}


//底部工具栏
- (UIView *)bottomBar{
    if (_bottomBar) return _bottomBar;
    
    _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-kBottomViewHeight , self.width, kBottomViewHeight)];
    
    UIView *backView = [[UIView alloc] initWithFrame:_bottomBar.bounds];
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0.5;
    backView.tag = 10001;
    [_bottomBar addSubview:backView];
    
    //    全屏按钮
    UIImage *img = [UIImage imageNamed:@"video_fullscreen"];
    self.fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.fullScreenBtn.showsTouchWhenHighlighted = YES;
    [self.fullScreenBtn setImage:img forState:UIControlStateNormal];
    [self.fullScreenBtn setImage:[UIImage imageNamed:@"video_nonfullscreen"] forState:UIControlStateSelected];
    self.fullScreenBtn.frame = CGRectMake(_bottomBar.width-img.size.width - 10, (_bottomBar.height-img.size.height)/2,img.size.width ,img.size.height);
    [self.bottomBar addSubview:self.fullScreenBtn];
    
    //视频播放时间
    self.leftTimeLabel = [[UILabel alloc]init];
    self.leftTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.leftTimeLabel.textColor = [UIColor whiteColor];
    self.leftTimeLabel.backgroundColor = [UIColor clearColor];
    self.leftTimeLabel.font = [UIFont systemFontOfSize:11];
    self.leftTimeLabel.adjustsFontSizeToFitWidth = YES;
    self.leftTimeLabel.frame = CGRectMake(0, 0, 60, self.bottomBar.height);
    [self.bottomBar addSubview:self.leftTimeLabel];
    
    self.rightTimeLabel = [[UILabel alloc]init];
    self.rightTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.rightTimeLabel.textColor = [UIColor whiteColor];
    self.rightTimeLabel.backgroundColor = [UIColor clearColor];
    self.rightTimeLabel.font = [UIFont systemFontOfSize:11];
    self.rightTimeLabel.adjustsFontSizeToFitWidth = YES;
    self.rightTimeLabel.frame = CGRectMake(_bottomBar.width - self.fullScreenBtn.width-self.leftTimeLabel.width - 5,
                                           self.leftTimeLabel.top, self.leftTimeLabel.width, self.leftTimeLabel.height);
    [self.bottomBar addSubview:self.rightTimeLabel];
    
    //播放进度条
    self.progressSlider = [[UISlider alloc]init];
    self.progressSlider.minimumValue = 0.0;
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"video_dot"] forState:UIControlStateNormal];
    self.progressSlider.minimumTrackTintColor = [UIColor redColor];
    self.progressSlider.value = 0.0;//指定初始值
    float width = _bottomBar.width - (self.leftTimeLabel.right) - (_bottomBar.width - self.rightTimeLabel.left);
    self.progressSlider.frame = CGRectMake(self.leftTimeLabel.right, 0, width ,_bottomBar.height);
    [self.bottomBar addSubview:self.progressSlider];
    
    [self bringSubviewToFront:self.bottomBar];
    
    return _bottomBar;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    _closeBtn.frame = CGRectMake(5, 5, 30, 30);
    UIImage *img = [UIImage imageNamed:@"video_pause"];
    self.playOrPauseBtn.frame = CGRectMake((self.width - img.size.width)/2, (self.height - img.size.height)/2, img.size.width, img.size.height);
    _bottomBar.frame = CGRectMake(0, self.height-kBottomViewHeight , self.width, kBottomViewHeight);
    [_bottomBar viewWithTag:10001].frame = _bottomBar.bounds;
    self.fullScreenBtn.frame = CGRectMake(_bottomBar.width-img.size.width - 10, (_bottomBar.height-img.size.height)/2,img.size.width ,img.size.height);
    self.leftTimeLabel.frame = CGRectMake(0, 0, 60, _bottomBar.height);
    self.rightTimeLabel.frame = CGRectMake(_bottomBar.width - self.fullScreenBtn.width-self.leftTimeLabel.width - 5,
                                           self.leftTimeLabel.top, self.leftTimeLabel.width, self.leftTimeLabel.height);
    float width = _bottomBar.width - (self.leftTimeLabel.right) - (_bottomBar.width - self.rightTimeLabel.left);
    self.progressSlider.frame = CGRectMake(self.leftTimeLabel.right, 0, width ,_bottomBar.height);
    self.titleView.frame = CGRectMake(0, 0, self.width, self.titleView.height);
    [self.titleView viewWithTag:100].frame = CGRectMake(15, 0, self.width - 30, _titleView.height);
    
    for (CALayer *layer in _titleView.layer.sublayers) {
        if ([layer isMemberOfClass:[CAGradientLayer class]]) {
            CAGradientLayer *gradientLayer = (CAGradientLayer *)layer;
            gradientLayer.bounds = _titleView.bounds;
            gradientLayer.frame = _titleView.bounds;
        }
    }
    
}

@end
