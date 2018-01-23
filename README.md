# HK_VideoPlayerDemo
使用IJKMediaFramework做视频列表播
IJKMediaFramework.framework过大，无法上传，需自行下载或去本地查找
需要引入的依赖库：
UIKit.framework
VideoToolbox.framework
QuartzCore.framework
OpenGLES.framework
MobileCoreServices.framework
MediaPlayer.framework
libz.tbd
libbz2.tbd
CoreVideo.framework
CoreMedia.framework
CoreGraphics.framework
AVFoundation.framework
AudioToolbox.framework
libc++.tbd

视频列表播放 cell 主要包含：
1、cell  的 UI 控件：标题、分享按钮、VideoListPlayer等
2、VideoListPlayer（继承自 UIView）
3、VideoListPlayer 主要包含：
1、 IJKPlayer（三方的核心播放工具）
2、VideoPlayerControlView（播放进度控制、全屏）
通过 silder 的操作状态的监听控制视频流的当前播放时间
self.player.currentPlaybackTime =self.playerControl.progressSlider.value;
通过IJKPlayer播放器  注册通知监听获取视频的播放进度，同时控制VideoPlayerControlView的 silder进度

视频列表在播放状态滑动机制：
1、定义一个currentCell，
2、将_videolistPlayer仅加到当前 cell  上
3、点击播放按钮时 1、_videolistPlayer从上一个 cell 的父view 移除但不销毁  2、取到当前播放地址开始加载3、开始播放视频时在新的当前cell 即currentCell 重新添加_videolistPlayer再进行播放

视频详情页
可将正在播放中的_videolistPlayer传给详情页，持续播放进度
返回时将 player 销毁
