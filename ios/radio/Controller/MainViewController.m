//
//  MainViewController.m
//  radio
//
//  Created by Peter on 14/7/5.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import "MainViewController.h"
#import "../View/CurrentPlayerView.h"
#import "RadioListViewController.h"

@interface MainViewController ()
{
    CurrentPlayerView *_player;
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
    _player = [[CurrentPlayerView alloc] initWithFrame:CGRectZero];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    {
        CGRect rtClient = self.view.frame;
        
        _player.frame = CGRectMake(rtClient.origin.x, rtClient.origin.y+rtClient.size.height-50, rtClient.size.width, 50);
        
        [self.view addSubview:_player];
    }
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

@end
