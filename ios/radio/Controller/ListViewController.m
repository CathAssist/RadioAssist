//
//  ListViewController.m
//  radio
//
//  Created by Peter on 14/7/5.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import "ListViewController.h"
#import "../View/RadioListView.h"

@interface ListViewController ()
{
    RadioListView *_radioList;
}
@end

@implementation ListViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (BOOL) shouldAutorotate
{
    //不支持自动旋转
    return FALSE;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:NSLocalizedString(@"App Name",nil)];
    
    _radioList = [[RadioListView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_radioList];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    {
        //Initialize user interface
        
        CGRect rtClient = self.view.frame;
        
        _radioList.frame = CGRectMake(rtClient.origin.x, rtClient.origin.y, rtClient.size.width, rtClient.size.height-50);
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
