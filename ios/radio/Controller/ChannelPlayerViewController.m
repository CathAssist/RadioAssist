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
    [imageViewIcon setImageURL:curChannel.logo];
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
            [scrollViewMain addSubview:btnPlayPause];
            
            //播放器把手
            imageViewHandle = [[UIImageView alloc] init];
            [imageViewHandle setImage:[UIImage imageNamed:@"turntable_ctrl"]];
            [scrollViewMain addSubview:imageViewHandle];
            
            //上一首
            btnPrev = [[UIButton alloc] init];
            [btnPrev setImage:[UIImage imageNamed:@"prev_ctrl"] forState:UIControlStateNormal];
            [scrollViewMain addSubview:btnPrev];
            
            //下一首
            btnNext = [[UIButton alloc] init];
            [btnNext setImage:[UIImage imageNamed:@"next_ctrl"] forState:UIControlStateNormal];
            [scrollViewMain addSubview:btnNext];
            
            //当前播放
            labelCurAudio = [[UILabel alloc] init];
            labelCurAudio.text = NSLocalizedString(@"Welcome to radio assist!",nil);
            labelCurAudio.font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            [labelCurAudio setTextAlignment:NSTextAlignmentCenter];
            [scrollViewMain addSubview:labelCurAudio];
            
            //播放进度条
            sliderDuration = [[UISlider alloc] init];
            [scrollViewMain addSubview:sliderDuration];
            
            //上一日、下一日、当前日期
            btnPrevDay = [[UIButton alloc] init];
            [btnPrevDay setTitle:NSLocalizedString(@"Prev day", nil) forState:UIControlStateNormal];
            [btnPrevDay setTitleColor:RGBCOLOR(56, 114, 250) forState:UIControlStateNormal];
            [scrollViewMain addSubview:btnPrevDay];
            
            btnNextDay = [[UIButton alloc] init];
            [btnNextDay setTitle:NSLocalizedString(@"Next day", nil) forState:UIControlStateNormal];
            [btnNextDay setTitleColor:RGBCOLOR(56, 114, 250) forState:UIControlStateNormal];
            [scrollViewMain addSubview:btnNextDay];
            
            btnNowDay = [[UIButton alloc] init];
            [btnNowDay setTitle:@"2014-08-15" forState:UIControlStateNormal];
            [btnNowDay setTitleColor:RGBCOLOR(56, 114, 250) forState:UIControlStateNormal];
            [scrollViewMain addSubview:btnNowDay];
            
            //关于本广播
            btnAbout = [[UIButton alloc] init];
            [btnAbout setTitle:@"About this channel" forState:UIControlStateNormal];
            [btnAbout setTitleColor:RGBCOLOR(128, 128, 128) forState:UIControlStateNormal];
            [scrollViewMain addSubview:btnAbout];
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
    CGRect rtClient = self.view.frame;
    
    scrollViewMain.frame = CGRectMake(rtClient.origin.x, rtClient.origin.y, rtClient.size.width, rtClient.size.height-50);
    
    CGFloat width = rtClient.size.width;
    CGFloat height = rtClient.size.height;
    
    
    [imageViewBg setFrame:CGRectMake(width*0.1, width*0.05, width*0.8, width*0.8)];
    
    CGFloat fIcon = 0.42;
    [imageViewIcon setFrame:CGRectMake(width*(0.5-fIcon/2), width*(0.45-fIcon/2), width*fIcon, width*fIcon)];
    imageViewIcon.layer.cornerRadius = width*fIcon/2;
    
    [imageViewTimeMask setFrame:CGRectMake(width*(0.5-fIcon/2), width*(0.45-fIcon/2), width*fIcon, width*fIcon)];
    imageViewTimeMask.layer.cornerRadius = width*fIcon/2;
    
    [labelCurTime setFrame:CGRectMake(0,width*(0.45+fIcon/2)-32,width,32)];
    
    [btnPlayPause setFrame:CGRectMake((width-41)/2, (width*0.95-41)/2, 41, 41)];
    
    [imageViewHandle setFrame:CGRectMake(width*0.55, width*0.1, width*0.45, width*0.45*1.4)];
    
    [btnPrev setFrame:CGRectMake(width*0.05, width*0.85, 40, 40)];
    [btnNext setFrame:CGRectMake(width*0.95-40, width*0.85, 40, 40)];
    [labelCurAudio setFrame:CGRectMake(width*0.05+40, width*0.85, width*0.9-80, 40)];
    
    [sliderDuration setFrame:CGRectMake(width*0.05, width, width*0.9, 30)];
    
    [btnPrevDay setFrame:CGRectMake(width*0.05, width+40, 80, 30)];
    [btnNextDay setFrame:CGRectMake(width*0.95-80, width+40, 80, 30)];
    [btnNowDay setFrame:CGRectMake(width*0.05+80, width+40, width*0.9-160, 30)];
    
    [btnAbout setFrame:CGRectMake(width*0.1, width+80, width*0.8, 20)];
    
    
    scrollViewMain.contentSize = CGSizeMake(width, width+115);
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
