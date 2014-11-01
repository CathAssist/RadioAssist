//
//  ChannelPlayerViewController.m
//  radio
//
//  Created by Peter on 14/7/13.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import "ChannelPlayerViewController.h"
#import "MainViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "STKAudioPlayer.h"
#import "TrackListViewController.h"
#import "RMDateSelectionViewController.h"
#import "MBProgressHUD.h"
#import "ImageCache.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ChannelPlayerViewController () <STKAudioPlayerDelegate,RMDateSelectionViewControllerDelegate>
{
    ChannelModel* curChannel;               //当前显示的频道
    ChannelModel* channelPlaying;           //正在播放的频道
    NSString* trackPlaying;                 //当前播放器正在播放的Track
    STKAudioPlayer* trackPlayer;            //播放器
    
    NSTimer* timerProgress;                 //执行每1秒刷新一下进度
    NSDateFormatter* dateFormatter;         //数据格式化
    
    //UI
    UIScrollView* scrollViewMain;       //界面下的mainview;
    UIButton* btnPlayPause;             //播放按钮
    UIButton* btnCurDay;
    
    UIImageView* imageViewBg;          //背景
    UIImageView* imageViewIcon;        //当前的图标
    UIImageView* imageViewTimeMask;
    UIImageView* imageViewHandle;      //CD上的把手
    
    UILabel* labelCurTime;             //当前时间
    UILabel* labelCurAudio;            //当前播放的音频名称
    UISlider* sliderDuration;
    
    UIButton* btnPrev;
    UIButton* btnNext;
    
    UIButton* btnPrevDay;
    UIButton* btnNextDay;
    UIButton* btnNowDay;
    
    UIButton* btnAbout;
}
@end

@implementation ChannelPlayerViewController

-(ChannelModel*) playingChannel
{
    return channelPlaying;
}


+ (ChannelPlayerViewController*) getInstance
{
    static ChannelPlayerViewController* theInstance = nil;
    if(theInstance == nil)
    {
        theInstance = [[ChannelPlayerViewController alloc] initWithNibName:nil bundle:nil];
    }
    
    return theInstance;
}

- (void) setChannel:(ChannelModel*) channel
{
    if(channel == nil)
    {
        channel = channelPlaying;
    }
    else if(channel != channelPlaying)
    {
        [channel setTrackWithIndex:-1];
    }
    
    curChannel = channel;
    [self setTitle:curChannel.title];
    [imageViewIcon setImageURL:curChannel.logo];
    
    [self updateUI];
}

- (void) setCurrentDate:(NSDate*)_date
{
    NSString* strDate = [dateFormatter stringFromDate:_date];
    
    NSString* strUrl = [NSString stringWithFormat:@"http://www.cathassist.org/radio/getradio.php?channel=%@&date=%@",curChannel.key,strDate];
    NSLog(@"Fetch channel from:%@",strUrl);
    
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = NSLocalizedString(@"Loading",nil);
    [hud show:true];
    
    //    [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"text/html"]];
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    [manager GET:strUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if(responseObject!=nil)
         {
             NSDictionary* dict = responseObject;
             
             ChannelModel* model = [[ChannelModel alloc] initWithDictionary:dict];
             NSLog(@"Load channel:%@",model.title);
             [self setChannel:model];
             [hud removeFromSuperview];
         }
     }
         failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         [hud removeFromSuperview];
     }];
}

-(void) updateLockScreen
{
    if(channelPlaying == nil && channelPlaying.currentTrack == nil)
        return;
    
    //更新锁屏时的歌曲信息
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        [dict setObject:channelPlaying.currentTrack.title forKey:MPMediaItemPropertyTitle];
        [dict setObject:channelPlaying.title forKey:MPMediaItemPropertyArtist];
        //            [dict setObject:@"专辑名" forKey:MPMediaItemPropertyAlbumTitle];
        
        [UIImage imageWithURL:channelPlaying.logo callback:^(UIImage *image) {
            [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:image]
                     forKey:MPMediaItemPropertyArtwork];
            
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
        }];
    }
}

- (void) updateUI
{
    if(curChannel == nil)
        return;
    
    [btnNowDay setTitle:curChannel.date forState:UIControlStateNormal];
    
    TrackModel* curTrack = curChannel.currentTrack;
    if(curTrack == nil)
    {
        [labelCurAudio setText:curChannel.desc];
        [btnPlayPause setSelected:false];
        return;
    }
    
    [labelCurAudio setText:curChannel.currentTrack.title];
    
    if(curChannel == channelPlaying)
    {
        if(trackPlaying != curChannel.currentTrack.src)
        {
            [trackPlayer pause];
            [self btnPlayPauseClicked];
        }
        else
        {
            [self setPlayingState:(STKAudioPlayerStatePlaying == trackPlayer.state)];
        }
    }
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        {
            //非UI元素的初始化
            //初始化播放器
            trackPlayer = [[STKAudioPlayer alloc] init];
            trackPlayer.delegate = self;
            
            timerProgress = [NSTimer scheduledTimerWithTimeInterval:1 target: self selector: @selector(timerProgressUpdate) userInfo: nil repeats: YES];
            
            
            //设置日期格式化方式
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        }
        {
            self.view.backgroundColor = RGBCOLOR(255, 255, 255);
            
            //UI的创建
            scrollViewMain = [[UIScrollView alloc] initWithFrame:CGRectZero];
            scrollViewMain.contentSize = CGSizeMake(WINDOW_WIDTH, 500);
       //     scrollViewMain.backgroundColor = RGBCOLOR(255, 255, 255);
            [self.view addSubview:scrollViewMain];
            
            //初始化背景
            imageViewBg = [[UIImageView alloc] init];
            imageViewBg.image = [UIImage imageNamed:@"CDBg"];
            [scrollViewMain addSubview:imageViewBg];
            
            //初始化Icon
            imageViewIcon = [[UIImageView alloc] init];
            imageViewIcon.layer.masksToBounds = YES;
            [scrollViewMain addSubview:imageViewIcon];
            
            //设置当前时间下的Mask
            imageViewTimeMask = [[UIImageView alloc] init];
            {
                CGSize imageSize = CGSizeMake(250, 250);
                UIGraphicsBeginImageContextWithOptions(imageSize, 0, [UIScreen mainScreen].scale);
                [[UIColor colorWithRed:0x0 green:0x0 blue:0x0 alpha:0.6] set];
                UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height));
                
                [[UIColor colorWithRed:0x0 green:0x0 blue:0x0 alpha:0] set];
                UIRectFill(CGRectMake(0, 0, imageSize.width, imageSize.height*0.75));
                UIImage* imageTimeMask = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                imageViewTimeMask.image = imageTimeMask;
                imageViewTimeMask.layer.masksToBounds = YES;
            }
            [scrollViewMain addSubview:imageViewTimeMask];
            
            labelCurTime = [[UILabel alloc] init];
            labelCurTime.text = @"00:00";
//            [labelCurTime setBackgroundColor:RGBCOLOR(255, 0, 0)];
            [labelCurTime setTextAlignment:NSTextAlignmentCenter];
            [labelCurTime setTextColor:RGBCOLOR(220, 220, 220)];
            [scrollViewMain addSubview:labelCurTime];
            
            //初始化播放/暂停按钮
            btnPlayPause = [[UIButton alloc] init];
            [btnPlayPause setBackgroundImage:[UIImage imageNamed:@"play_ctrl"] forState:UIControlStateNormal];
            [btnPlayPause setBackgroundImage:[UIImage imageNamed:@"pause_ctrl"] forState:UIControlStateSelected];
            [btnPlayPause addTarget:self action:@selector(btnPlayPauseClicked) forControlEvents:UIControlEventTouchUpInside];
            [scrollViewMain addSubview:btnPlayPause];
            
            //播放器把手
            imageViewHandle = [[UIImageView alloc] init];
            [imageViewHandle setImage:[UIImage imageNamed:@"turntable_ctrl"]];
            [scrollViewMain addSubview:imageViewHandle];
            
            //上一首
            btnPrev = [[UIButton alloc] init];
            [btnPrev setImage:[UIImage imageNamed:@"prev_ctrl"] forState:UIControlStateNormal];
            [btnPrev addTarget:self action:@selector(btnPlayPrev) forControlEvents:UIControlEventTouchUpInside];
            [scrollViewMain addSubview:btnPrev];
            
            //下一首
            btnNext = [[UIButton alloc] init];
            [btnNext setImage:[UIImage imageNamed:@"next_ctrl"] forState:UIControlStateNormal];
            [btnNext addTarget:self action:@selector(btnPlayNext) forControlEvents:UIControlEventTouchUpInside];
            [scrollViewMain addSubview:btnNext];
            
            //当前播放
            labelCurAudio = [[UILabel alloc] init];
            labelCurAudio.text = NSLocalizedString(@"Welcome to radio assist!",nil);
            labelCurAudio.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            [labelCurAudio setTextAlignment:NSTextAlignmentCenter];
            [scrollViewMain addSubview:labelCurAudio];
            
            //播放进度条
            sliderDuration = [[UISlider alloc] init];
            [sliderDuration addTarget:self action:@selector(sliderDurationChanged:) forControlEvents:UIControlEventValueChanged];
            [scrollViewMain addSubview:sliderDuration];
            
            //上一日、下一日、当前日期
            btnPrevDay = [[UIButton alloc] init];
            [btnPrevDay setTitle:NSLocalizedString(@"Prev day", nil) forState:UIControlStateNormal];
            [btnPrevDay setTitleColor:RGBCOLOR(56, 114, 250) forState:UIControlStateNormal];
            [btnPrevDay addTarget:self action:@selector(btnPrevDay) forControlEvents:UIControlEventTouchUpInside];
            [scrollViewMain addSubview:btnPrevDay];
            
            btnNextDay = [[UIButton alloc] init];
            [btnNextDay setTitle:NSLocalizedString(@"Next day", nil) forState:UIControlStateNormal];
            [btnNextDay setTitleColor:RGBCOLOR(56, 114, 250) forState:UIControlStateNormal];
            [btnNextDay addTarget:self action:@selector(btnNextDay) forControlEvents:UIControlEventTouchUpInside];
            [scrollViewMain addSubview:btnNextDay];
            
            btnNowDay = [[UIButton alloc] init];
            [btnNowDay setTitle:@"2014-08-15" forState:UIControlStateNormal];
            [btnNowDay setTitleColor:RGBCOLOR(56, 114, 250) forState:UIControlStateNormal];
            [btnNowDay addTarget:self action:@selector(btnNowDay) forControlEvents:UIControlEventTouchUpInside];
            [scrollViewMain addSubview:btnNowDay];
            
            //关于本广播
            btnAbout = [[UIButton alloc] init];
            [btnAbout setTitle:@"About this channel" forState:UIControlStateNormal];
            [btnAbout setTitleColor:RGBCOLOR(128, 128, 128) forState:UIControlStateNormal];
            [btnAbout addTarget:self action:@selector(btnAboutChannel) forControlEvents:UIControlEventTouchUpInside];
            [scrollViewMain addSubview:btnAbout];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //添加右侧的列表按钮
    UIImage *image = [UIImage imageNamed:@"MenuIcon"];
    
    CGRect frame = CGRectMake(0, 0, 24, 24);
    
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setShowsTouchWhenHighlighted:YES];
    
    [button addTarget:self action:@selector(showTrackList) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem* menuItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    [self.navigationItem setRightBarButtonItem:menuItem];
    
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] init];
    backItem.title = NSLocalizedString(@"Back",nil);
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect rtClient = self.view.frame;
    
    scrollViewMain.frame = CGRectMake(rtClient.origin.x, rtClient.origin.y, rtClient.size.width, rtClient.size.height);
    
    CGFloat width = rtClient.size.width;
    
    
    [imageViewBg setFrame:CGRectMake(width*0.1, width*0.05, width*0.8, width*0.8)];
    
    CGFloat fIcon = 0.42;
    [imageViewIcon setFrame:CGRectMake(width*(0.5-fIcon/2), width*(0.45-fIcon/2), width*fIcon, width*fIcon)];
    imageViewIcon.layer.cornerRadius = width*fIcon/2;
    
    [imageViewTimeMask setFrame:CGRectMake(width*(0.5-fIcon/2), width*(0.45-fIcon/2), width*fIcon, width*fIcon)];
    imageViewTimeMask.layer.cornerRadius = width*fIcon/2;
    
    [labelCurTime setFrame:CGRectMake(0,width*(0.45+fIcon/2)-32,width,32)];
    
    [btnPlayPause setFrame:CGRectMake((width-41)/2, (width*0.95-41)/2, 41, 41)];
    [btnPlayPause setSelected:false];
    
    imageViewHandle.transform = CGAffineTransformMakeRotation(0);
    imageViewHandle.layer.anchorPoint = CGPointMake(1.0, 0);
    [imageViewHandle setFrame:CGRectMake(width*0.55, width*0.1, width*0.45, width*0.45*1.4)];
    imageViewHandle.transform = CGAffineTransformMakeRotation(-0.4);
    
    
    [btnPrev setFrame:CGRectMake(width*0.05, width*0.85, 40, 40)];
    [btnNext setFrame:CGRectMake(width*0.95-40, width*0.85, 40, 40)];
    [labelCurAudio setFrame:CGRectMake(width*0.05+40, width*0.85, width*0.9-80, 40)];
    
    [sliderDuration setFrame:CGRectMake(width*0.05, width, width*0.9, 30)];
    
    [btnPrevDay setFrame:CGRectMake(width*0.05, width+40, 80, 30)];
    [btnNextDay setFrame:CGRectMake(width*0.95-80, width+40, 80, 30)];
    [btnNowDay setFrame:CGRectMake(width*0.05+80, width+40, width*0.9-160, 30)];
    
    [btnAbout setFrame:CGRectMake(width*0.1, width+80, width*0.8, 20)];
    
    
    scrollViewMain.contentSize = CGSizeMake(width, width+115);
    
    [self updateUI];
    
    
    //注册进程挂起和进程激活消息，用于控制动画的显示
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:@"applicationDidEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:@"applicationWillEnterForeground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:@"applicationDidBecomeActive" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteControlReceivedWithEvent:) name:@"remoteControlReceivedWithEvent" object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)applicationDidEnterBackground
{
    [self setPlayingState:false];
}

-(void)applicationWillEnterForeground
{
    if(trackPlayer.state == STKAudioPlayerStatePlaying
       || trackPlayer.state == STKAudioPlayerStateBuffering)
    {
        [self setPlayingState:true];
    }
}

-(void)applicationDidBecomeActive
{
    if(trackPlayer.state == STKAudioPlayerStatePlaying
       || trackPlayer.state == STKAudioPlayerStateBuffering)
    {
        [self setPlayingState:true];
    }
}

-(void)remoteControlReceivedWithEvent:(NSNotification*) notification
{
    UIEvent* e = [notification object];
    
    if (e.type == UIEventTypeRemoteControl)
    {
        switch (e.subtype)
        {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                if(trackPlayer.state == STKAudioPlayerStatePlaying)
                {
                    [trackPlayer pause];
                    [self setPlayingState:NO];
                }
                else
                {
                    [trackPlayer resume];
                    [self setPlayingState:YES];
                }
                NSLog(@"RemoteControlEvents: pause");
                break;
            case UIEventSubtypeRemoteControlNextTrack:
//                [self setCurrentTrack:channelPlaying.nextTrack];
                NSLog(@"RemoteControlEvents: playModeNext");
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
//                [self setCurrentTrack:channelPlaying.prevTrack];
                NSLog(@"RemoteControlEvents: playPrev");
                break;
            default:
                break;
        }
    }
}

- (void)showTrackList
{
    TrackListViewController* tc = [[TrackListViewController alloc] init];
    [tc setChannel:curChannel];
    
    
/*    [UIView animateWithDuration:0.7f
                     animations:^{
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
                         
                         [[MainViewController getInstance] pushViewController:tc animated:NO];
                         [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.navigationController.view cache:NO];
                     }];
    */
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromTop;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    self.navigationController.navigationBarHidden = NO;
    [[MainViewController getInstance] pushViewController:tc animated:NO];
}

- (void) setPlayingState:(BOOL)_playing
{
    if(btnPlayPause.selected == _playing)
        return;
    btnPlayPause.selected = _playing;
    
    //当前播放时间
    //    self.labelCurTime.text = !_playing ? @"10:11" : @"11:00:21";
    
    //调整Icon的状态(旋转/停止)
    if(_playing)
    {
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
        rotationAnimation.duration = 10;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = 100000;
        
        [imageViewIcon.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    }
    else
    {
        [imageViewIcon.layer removeAllAnimations];
    }
    
    
    //调整handle的状态
    [UIView beginAnimations:@"handleOn" context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    
    imageViewHandle.transform = CGAffineTransformMakeRotation(_playing ? 0 : -0.4);
    
    [UIView commitAnimations];
}

- (void)btnPlayPauseClicked
{
    if(curChannel == channelPlaying &&
       STKAudioPlayerStatePlaying == trackPlayer.state)
    {
        [trackPlayer pause];
    }
    else
    {
        if(nil==curChannel.currentTrack)
        {
            [curChannel setTrackWithIndex:0];
        }
        
        TrackModel* curTrack = curChannel.currentTrack;
        if(curTrack == nil)
        {
            [labelCurAudio setText:curChannel.title];
            return;
        }
        else
        {
            [labelCurAudio setText:curTrack.title];
        }
        
        if(trackPlaying == curTrack.src)
        {
            [trackPlayer resume];
        }
        else
        {
            trackPlaying = curTrack.src;
            channelPlaying = curChannel;
            [trackPlayer play:trackPlaying];
        }
    }
    
    
    [self setPlayingState:!btnPlayPause.isSelected];
}

- (void)btnPlayNext
{
    TrackModel* curTrack = [curChannel nextTrack];
    if(curTrack == nil)
    {
        [trackPlayer stop];
        return;
    }
    
    [self updateUI];
    [self updateLockScreen];
}

- (void)btnPlayPrev
{
    TrackModel* curTrack = [curChannel prevTrack];
    if(curTrack == nil)
    {
        [trackPlayer stop];
        return;
    }
    
    [self updateUI];
    [self updateLockScreen];
}

-(void)sliderDurationChanged:(id)sender
{
    [trackPlayer seekToTime:sliderDuration.value];
}

-(void)btnNextDay
{
    if(curChannel == nil)
        return;
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents* adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:0];
    [adcomps setDay:1];
    
    NSDate* newdate = [calendar dateByAddingComponents:adcomps toDate:[dateFormatter dateFromString:curChannel.date] options:0];
    
    [self setCurrentDate:newdate];
}

-(void)btnPrevDay
{
    if(curChannel == nil)
        return;
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents* adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:0];
    [adcomps setDay:-1];
    
    NSDate* newdate = [calendar dateByAddingComponents:adcomps toDate:[dateFormatter dateFromString:curChannel.date] options:0];
    
    [self setCurrentDate:newdate];
}

-(void)btnNowDay
{
    RMDateSelectionViewController* dateSelectionVC = [RMDateSelectionViewController dateSelectionController];
    dateSelectionVC.delegate = self;
    dateSelectionVC.datePicker.datePickerMode = UIDatePickerModeDate;
    if(curChannel!=nil)
    {
        dateSelectionVC.datePicker.date = [dateFormatter dateFromString:curChannel.date];
    }
    
    [dateSelectionVC show];
}

-(void)btnAboutChannel
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.cathassist.org/radio/about.php?channel=%@",curChannel.key]]];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/



///////timer update
-(void) timerProgressUpdate
{
    if(curChannel.currentTrack == nil || curChannel.currentTrack.src != trackPlaying)
    {
        [labelCurTime setText:@"00:00"];
        sliderDuration.value = 0;
        return;
    }
    
    double duration = trackPlayer.duration;
    if(duration < 0.1)
    {
        [labelCurTime setText:@"00:00"];
        return;
    }
    
    double progress = trackPlayer.progress;
    NSString* curTime = [NSString stringWithFormat:@"%02d:%02d", (int)(progress)/60,(int)(progress)%60];
    [labelCurTime setText:curTime];
    
    sliderDuration.maximumValue = duration;
    sliderDuration.minimumValue = 0.0;
    sliderDuration.value = progress;
}


/////audio player delegate
/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId;
{
}
/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId;
{
    
}
/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState;
{
    if(STKAudioPlayerStatePlaying == state)
    {
        [btnPlayPause setSelected:true];
    }
    else
    {
        [btnPlayPause setSelected:false];
    }
}
/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration;
{
    if(STKAudioPlayerStopReasonEof == stopReason)
    {
        [self btnPlayNext];
    }
}
/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    
}


- (void)dateSelectionViewController:(RMDateSelectionViewController *)vc didSelectDate:(NSDate *)aDate
{
    //选择了新的日期
    [self setCurrentDate:aDate];
}

- (void)dateSelectionViewControllerDidCancel:(RMDateSelectionViewController *)vc
{
    //Do something else
}

@end
