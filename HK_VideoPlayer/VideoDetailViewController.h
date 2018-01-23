//
//  VideoDetailViewController.h
//  HK_VideoPlayer
//
//  Created by houke on 2018/1/19.
//  Copyright © 2018年 houke. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoListPlayer.h"

@interface VideoDetailViewController : UIViewController

@property (strong, nonatomic)VideoListPlayer *videoDetailPlayer;
@property (nonatomic,copy) void (^popSuccess)();
@end
