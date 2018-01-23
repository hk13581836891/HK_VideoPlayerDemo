//
//  THVideoCell.h
//  THPlayer
//
//  Created by inveno on 16/3/23.
//  Copyright © 2016年 inveno. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoListModel.h"
@interface VideoListTableViewCell : UITableViewCell<CAAnimationDelegate,UIGestureRecognizerDelegate>
{
    double anglet;
}
@property (strong, nonatomic)VideoListModel *model;
@property (strong, nonatomic)UIImageView *imgView;
@property (strong, nonatomic)UILabel *titleLabel;
@property (strong, nonatomic)UIButton *playBtn;
@property(nonatomic,retain)UIImageView *waitingView;
@property (strong, nonatomic)UIView *backView;
@property(nonatomic,strong)UIButton *shareButton;
@property(nonatomic,strong)UIButton *jumpBtn;

@end

