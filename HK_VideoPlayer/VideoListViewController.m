//
//  VideoListViewController.m
//  HK_VideoPlayer
//
//  Created by houke on 2018/1/19.
//  Copyright © 2018年 houke. All rights reserved.
//

#import "VideoListViewController.h"
#import "JSONKit.h"
#import "VideoListModel.h"
#import "VideoListTableViewCell.h"
#import "UIViewExt.h"
#import "VideoListPlayer.h"
#import "MJExtension.h"
#import "Header.h"
#import "VideoDetailViewController.h"

@interface VideoListViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    NSString *lastPid;
    VideoListModel *shareModel;
    BOOL NotWifiVideoPlay;
    NSMutableDictionary *_bottomLoadDic;
}

@property (strong, nonatomic)UITableView *table;
@property (strong, nonatomic)NSMutableArray *videoListArr; //数据源
@property (strong, nonatomic)NSIndexPath *currentIndexPath;
@property (strong, nonatomic)VideoListTableViewCell *currentCell;//当前播放的cell
@property (strong, nonatomic)VideoListTableViewCell *lastCell;//上一个播放的cell
@property (strong, nonatomic)VideoListPlayer *videolistPlayer;

@end

@implementation VideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserver];
    _videoListArr = [NSMutableArray array];
    [self getDataResource];
    [self.view addSubview:self.table];
    [self.table registerClass:[VideoListTableViewCell class] forCellReuseIdentifier:@"VideoCell"];
    
    
    // Do any additional setup after loading the view.
}

-(void)getDataResource
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"DataSource" ofType:@"json"];
    NSString *content = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:filePath] encoding:NSUTF8StringEncoding error:nil];
    //使用 jsonkit 解析
    NSArray *array = [content objectFromJSONString];
    [_videoListArr addObjectsFromArray:[VideoListModel mj_objectArrayWithKeyValuesArray:array]];
}

- (void)addObserver
{
    
    //视频播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinished:)
                                                 name:kHTPlayerFinishedPlayNotificationKey object:nil];
    //视频全屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreenBtnClick:)
                                                 name:kHTPlayerFullScreenBtnNotificationKey object:nil];
    
    //视频加载准备完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showVideoPlayer)
                                                 name:kHTPlayerLoadingCompleteNotificationKey
                                               object:nil];
}
-(void)removeObserve
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHTPlayerLoadingCompleteNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHTPlayerFullScreenBtnNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHTPlayerFinishedPlayNotificationKey object:nil];
}

//视频播放完成通知
-(void)videoDidFinished:(NSNotification *)notice{
    
    if (_videolistPlayer.screenType == UIHTPlayerSizeFullScreenType){
        
        [self toCell];//先变回cell
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _videolistPlayer.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_videolistPlayer removeFromSuperview];
        [self releaseWMPlayer];
    }];
    
}

//视频全屏
-(void)fullScreenBtnClick:(NSNotification *)notice{
    
    UIButton *fullScreenBtn = (UIButton *)[notice object];
    if (fullScreenBtn.isSelected) {//全屏显示
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self toCell];
    }
}
//销毁视频显示页面
-(void)releaseWMPlayer{
    
    [_videolistPlayer releaseWMPlayer];
    _videolistPlayer = nil;
    _currentIndexPath = nil;
    _lastCell = nil;
}

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _videoListArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height;
    
    height = SCREEN_WIDTH/16*9+55;
    return height;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"VideoCell";
    VideoListTableViewCell *cell = (VideoListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    cell.model = [_videoListArr objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    [cell.playBtn addTarget:self action:@selector(startPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = indexPath.row;
    cell.shareButton.tag = indexPath.row;
    [cell.shareButton addTarget:self action:@selector(videoshareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.jumpBtn addTarget:self action:@selector(jumpVideoDetail:) forControlEvents:UIControlEventTouchUpInside];
    cell.jumpBtn.backgroundColor = [UIColor yellowColor];
    cell.jumpBtn.tag = indexPath.row;
    return cell;
}
-(void)jumpVideoDetail:(UIButton *)btn
{
    VideoDetailViewController *videoDetail = [[VideoDetailViewController alloc] init];
    //    判断当前播放的视频，是否用户点击的视频。
    if (_currentIndexPath && _currentIndexPath.row != btn.tag) {
        
        if (_videolistPlayer) {
            [self releaseWMPlayer];//关闭视频
        }
        
        _currentIndexPath = [NSIndexPath indexPathForRow:btn.tag inSection:0];
        _currentCell = [self.table cellForRowAtIndexPath:_currentIndexPath];
    }
    videoDetail.videoDetailPlayer = _videolistPlayer;
    VideoListModel *model = [_videoListArr objectAtIndex:btn.tag];
    __weak typeof (self)weakSelf =self;
    videoDetail.popSuccess = ^()
    {
        [weakSelf addObserver];
    };
    [self.navigationController pushViewController:videoDetail animated:YES];
    [self removeObserve];
    if (_videolistPlayer) {
        _videolistPlayer = nil;
    }
}

-(void)toCell{
    
    self.currentCell = (VideoListTableViewCell *)[self.table cellForRowAtIndexPath:_currentIndexPath];
    [_videolistPlayer reductionWithInterfaceOrientation:self.currentCell.backView];
    [self.table reloadData];
}

-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    
    [_videolistPlayer toFullScreenWithInterfaceOrientation:interfaceOrientation];
}

-(void)showVideoPlayer
{
    self.currentCell.waitingView.hidden = YES;
    [self.currentCell.backView addSubview:_videolistPlayer];
    [self.currentCell.backView bringSubviewToFront:_videolistPlayer];
    self.currentCell.playBtn.hidden = NO;
    
    [self.table reloadData];
}
-(void)HiddenVideoPlayer
{
    [_videolistPlayer removeFromSuperview];
    [self releaseWMPlayer];
    [self.table reloadData];
    if (_lastCell) {
        _lastCell.waitingView.hidden = YES;
        _lastCell.playBtn.hidden = NO;
    }
}
//开始播放
-(void)startPlayVideo:(UIButton *)sender{
    
    _currentIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    self.currentCell = (VideoListTableViewCell *)[self.table cellForRowAtIndexPath:_currentIndexPath];
    if (_lastCell) {
        _lastCell.waitingView.hidden = YES;
        _lastCell.playBtn.hidden = NO;
    }
    
    self.currentCell.waitingView.hidden = NO;
    self.currentCell.playBtn.hidden = YES;
    VideoListModel *model = [_videoListArr objectAtIndex:sender.tag];
    if (_videolistPlayer) {
        [_videolistPlayer removeFromSuperview];
        [_videolistPlayer setVideoURLStr:model.pcVideourl];
        
    }else{
        _videolistPlayer = [[VideoListPlayer alloc]initWithFrame:self.currentCell.backView.bounds videoURLStr:model.pcVideourl];
    }
    _videolistPlayer.detailID = model.ID;
    _videolistPlayer.screenType = UIHTPlayerSizeRecoveryScreenType;
    _lastCell = self.currentCell;
    [_videolistPlayer setPlayTitle:model.title];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    return;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VideoDetailViewController *videoDetail = [[VideoDetailViewController alloc] init];
    //    判断当前播放的视频，是否用户点击的视频。
    if (_currentIndexPath && _currentIndexPath.row != indexPath.row) {
        
        if (_videolistPlayer) {
            [self releaseWMPlayer];//关闭视频
        }
        
        _currentIndexPath = indexPath;
        _currentCell = [tableView cellForRowAtIndexPath:indexPath];
    }
    videoDetail.videoDetailPlayer = _videolistPlayer;
    VideoListModel *model = [_videoListArr objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:videoDetail animated:YES];
    
    [self removeObserve];
    
}

#pragma mark scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView ==self.table){
        
        if (_videolistPlayer==nil) return;
        
        if (_videolistPlayer.superview) {
            CGRect rectInTableView = [self.table rectForRowAtIndexPath:_currentIndexPath];
            CGRect rectInSuperview = [self.table convertRect:rectInTableView toView:[self.table superview]];
            
            //            NSLog(@"rectInSuperview = %@",NSStringFromCGRect(rectInSuperview));
            
            if (rectInSuperview.origin.y<-self.currentCell.backView.height||rectInSuperview.origin.y>self.view.height) {//往上拖动
                [self HiddenVideoPlayer];
                //                if (![[UIApplication sharedApplication].keyWindow.subviews containsObject:_videolistPlayer]) {
                //                    //放widow上,小屏显示
                //                    [self toSmallScreen];
                //                }
                
            }else{
                //                if (![self.currentCell.backView.subviews containsObject:_videolistPlayer]) {
                //                    [self toCell];
                //                }
            }
        }
        
        
    }
    
}
- (UITableView *)table
{
    if (_table) return _table;
    _table = [[UITableView alloc] initWithFrame:self.view.bounds];
    _table.dataSource = self;
    _table.delegate = self;
    _table.separatorStyle = UITableViewCellSeparatorStyleNone;
    _table.estimatedRowHeight = 0;
    _table.estimatedSectionHeaderHeight = 0;
    _table.estimatedSectionFooterHeight = 0;
    return _table;
}

-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseWMPlayer];
}


@end
