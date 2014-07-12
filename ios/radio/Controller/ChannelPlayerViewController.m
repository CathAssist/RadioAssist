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

@interface ChannelPlayerViewController () <STKAudioPlayerDelegate>
{
    ChannelModel* curChannel;               //当前频道
    STKAudioPlayer* trackPlayer;            //播放器
    NSTimer* timerProgress;                 //执行每1秒刷新一下进度
    NSDateFormatter* dateFormatter;         //数据格式化
    NSDate* dateCurrent;                    //当前时间
    
    //UI
    UIButton* btnPlayPause;             //播放按钮
    UIButton* btnCurDay;
    
    UIImageView* imageViewHandle;      //CD上的把手
    UIImageView* imageViewIcon;        //当前的图标
    UIImageView* imageViewTimeMask;
    
    UILabel* labelCurTime;             //当前时间
    UILabel* labelCurAudio;            //当前播放的音频名称
    UISlider* sliderDuration;
    
    UIImage* imageIcon;
    UIScrollView *scrollViewMain;
    
    UIButton* btnRadioRight;
    UIButton* btnSoftRight;
}
@end

@implementation ChannelPlayerViewController


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
    curChannel = channel;
    [self setTitle:curChannel.title];
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
            
            //获取当前时间
            dateCurrent = [NSDate date];
        }
        {
            //UI的初始化
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    if(curChannel==nil)
        return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
}
/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration;
{
}
/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    
}
@end
