//
//  MainViewController.m
//  radio
//
//  Created by Peter on 14/7/5.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import "MainViewController.h"
#import "ListViewController.h"
#import "../View/CurrentPlayerView.h"

@interface MainViewController ()
{
    CurrentPlayerView *_player;
}
@end

@implementation MainViewController

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
    _player = [[CurrentPlayerView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    
    [self.view addSubview:_player];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    {
        CGRect rtClient = self.view.frame;
        
        _player.frame = CGRectMake(rtClient.origin.x, rtClient.origin.y+rtClient.size.height-50, rtClient.size.width, 50);
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
