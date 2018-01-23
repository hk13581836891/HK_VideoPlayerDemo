//
//  THVideoCell.m
//  THPlayer
//
//  Created by inveno on 16/3/23.
//  Copyright © 2016年 inveno. All rights reserved.
//

#import "VideoListTableViewCell.h"
#import "UIViewExt.h"
#import "Color+Hex.h"
#import "UIImageView+WebCache.h"
#import "VideoListViewController.h"
#import "Header.h"

#define kRadianToDegrees(radian) (radian*180.0)/(M_PI)

@implementation VideoListTableViewCell
{
    UIImageView *potrait;
    UILabel *nickName;
    UIImageView *bgV;
    UIView *sepLine;
    UILabel *commentLab;
    UIImageView *commentIMG;
    UIButton *durationBtn;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubView];
    }
    return self;
}
- (void)initSubView
{
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/16*9)];
    [self.contentView addSubview:self.backView];

    
    _imgView = [[UIImageView alloc] initWithFrame:self.backView.bounds];
    _imgView.backgroundColor = [UIColor whiteColor];
    _imgView.layer.masksToBounds = YES;
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
    [_imgView layer].shadowPath =[UIBezierPath bezierPathWithRect:_imgView.bounds].CGPath;
    _imgView.userInteractionEnabled = YES;
    [self.backView addSubview:_imgView];

    UIImage *img = [UIImage imageNamed:@"custom_list_play"];
    _playBtn = [[UIButton alloc]init];
    _playBtn.frame = self.backView.bounds;
    _playBtn.contentMode = UIViewContentModeCenter;
    [_playBtn setImage:img forState:UIControlStateNormal];
    [self.backView addSubview:_playBtn];
    
    durationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    durationBtn.layer.cornerRadius = 10.;
    durationBtn.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.7];
    [durationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    durationBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [_imgView addSubview:durationBtn];

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 30, 33)];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.numberOfLines = 0;
    _titleLabel.textColor = [UIColor whiteColor];
    [self.backView addSubview:_titleLabel];
    //背景
    bgV = [[UIImageView alloc] init];
    bgV.image = [UIImage imageNamed:@"video_title_bg"];
    [self.backView insertSubview:bgV belowSubview:_titleLabel];
  
    _waitingView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,img.size.width, img.size.height)];
    _waitingView.center = self.backView.center;
    UIImage *imgWaiting = [UIImage imageNamed:@"waiting"];
    _waitingView.image = imgWaiting;
    _waitingView.hidden = YES;
    [self.backView addSubview:_waitingView];
    [NSTimer scheduledTimerWithTimeInterval:0.001 target: self selector:@selector(transformAction) userInfo: nil repeats: YES];
    
    //头像
    potrait = [[UIImageView alloc] init];
    potrait.clipsToBounds = YES;
    potrait.frame = CGRectMake(15,_imgView.height+10, 30, 30);
    potrait.layer.cornerRadius = potrait.width/2.0;
    [self.contentView addSubview:potrait];
    
    //昵称
    nickName = [[UILabel alloc] init];
    nickName.text = @"酷爱巴西";
    nickName.font = [UIFont systemFontOfSize:14];
    nickName.textColor = [UIColor lightGrayColor];
    nickName.frame = CGRectMake(potrait.right+10, potrait.top, 150, potrait.height);
    [self.contentView addSubview:nickName];
    sepLine =[[UIView alloc] init];
    [self.contentView addSubview:sepLine];
    
    //评论
    commentLab = [[UILabel alloc] init];
    commentLab.adjustsFontSizeToFitWidth = YES;
    commentLab.text = @"521";
    commentLab.font = [UIFont systemFontOfSize:14];
    commentLab.textColor = [UIColor lightGrayColor];
    [self.contentView addSubview:commentLab];
    commentLab.frame =  CGRectMake(SCREEN_WIDTH-140, potrait.top, 50, potrait.height);
    commentLab.textAlignment = NSTextAlignmentRight;
    commentIMG = [[UIImageView alloc] init];
    commentIMG.image = [UIImage imageNamed:@"video_comment"];
    commentIMG.contentMode = UIViewContentModeScaleAspectFit;
    commentIMG.frame = CGRectMake(commentLab.right+8, commentLab.top+(commentLab.height-20)/2.0, 20, 20);
    [self.contentView addSubview:commentIMG];
    _jumpBtn= [[UIButton alloc]initWithFrame:CGRectMake(0, _imgView.height, SCREEN_WIDTH, 48)];
    [self.contentView addSubview:_jumpBtn];
    
    //分享
    _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_shareButton setImage:[UIImage imageNamed:@"video_share"] forState:UIControlStateNormal];
    _shareButton.frame = CGRectMake(SCREEN_WIDTH-40, commentLab.top+(commentLab.height-25)/2.0, 25, 25);
    [self.contentView addSubview:_shareButton];

}

-(void)setModel:(VideoListModel *)model
{
    CGFloat height = SCREEN_WIDTH/16*9+55;

    _model = model;
    if (_model == nil) return;
    
    CGRect _frame;
    _titleLabel.font = [UIFont systemFontOfSize:18];
    _titleLabel.text = model.title;
    
    
        _titleLabel.frame = CGRectMake(8, 5, SCREEN_WIDTH-16,50);
        
        bgV.frame = CGRectMake(0, 0, SCREEN_WIDTH, 55);
        
        nickName.text = model.authorName;
        
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:_model.imgurl] placeholderImage:[UIImage imageNamed:@"piclod.png"]];

    sepLine.frame = CGRectMake(0, height-5, SCREEN_WIDTH, 5);
    sepLine.backgroundColor = [UIColor grayColor];
    commentLab.text = model.commentnum;
    
    if (model.duration) {
        NSString *durationStr = [self timeFormatted:[model.duration intValue]] ;
        [durationBtn setTitle:durationStr forState:UIControlStateNormal];
        CGFloat durationBtnW = 80;
        durationBtn.frame = CGRectMake(_imgView.width -10-durationBtnW, _imgView.height-30, durationBtnW, 20);
    }
}
-(NSString *)timeFormatted:(int)totalSeconds
{
    
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    NSString *duration ;
    if (hours>0) {
        duration = [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    }else{
        duration = [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
    }
    return duration;
}
-(void)transformAction {
    self.waitingView.hidden = !self.playBtn.hidden;
    if (self.waitingView.hidden) {
        
    }
    else
    {
        anglet = anglet + 0.01;//angle角度 double angle;
        if (anglet > 6.28) {//大于 M_PI*2(360度) 角度再次从0开始
            anglet = 0;
        }
        CGAffineTransform transform=CGAffineTransformMakeRotation(anglet);
        _waitingView.transform = transform;
    }
  
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end

