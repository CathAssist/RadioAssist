//
//  MainViewController.m
//  radio
//
//  Created by Peter on 14/7/5.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import "MainViewController.h"
#import "RadioListViewController.h"

@interface MainViewController ()
{
    NSMutableDictionary* dicConfig;
    NSString* configPath;
}
@end

@implementation MainViewController


+ (MainViewController*) getInstance
{
    static MainViewController* theMainViewController = nil;
    if(theMainViewController == nil)
    {
        theMainViewController = [[MainViewController alloc] initWithRootViewController:[[RadioListViewController alloc] initWithNibName:nil bundle:nil]];
    }
    
    return theMainViewController;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    _player = [[CurrentPlayerView alloc] initWithFrame:CGRectZero];
    
    configPath = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"plist"];
    dicConfig = [[NSMutableDictionary alloc] initWithContentsOfFile:configPath];
    NSLog(@"%@", dicConfig);//直接打印数据。
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) isAutoRefresh
{
    NSNumber* nOn = [dicConfig objectForKey:@"AutoRefresh"];
    
    return [nOn isEqualToNumber:[[NSNumber alloc] initWithInt:1]];
}
- (void) setAutoRefresh:(BOOL)isOn
{
    NSNumber* nOn = [[NSNumber alloc] initWithInt:(isOn ? 1 : 0)];
    
    [dicConfig setObject:nOn forKey:@"AutoRefresh"];
    [dicConfig writeToFile:configPath atomically:YES];
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

@end
