//
//  RadioListViewController.m
//  radio
//
//  Created by Peter on 14/7/5.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import "RadioListViewController.h"
#import "SVPullToRefresh.h"
#import "AFNetworking.h"
#import "../View/RadioListViewCell.h"
#import "../View/RadioListView.h"
#import "../Model/ChannelModel.h"

@interface RadioListViewController ()
{
    RadioListView *_radioList;
    NSDateFormatter* _dateFormatter;
    NSMutableArray* _channels;
}
@end

@implementation RadioListViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        //设置日期格式化方式
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[NSLocale currentLocale]];
        [_dateFormatter setDateFormat:@"YYYY-MM-dd"];
        
        _channels = [NSMutableArray new];
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setTitle:NSLocalizedString(@"App Name",nil)];
    
    _radioList = [[RadioListView alloc] initWithController:self];
}

- (void) viewDidAppear:(BOOL)animated
{
    CGRect rtClient = self.view.frame;
    
    _radioList.frame = CGRectMake(rtClient.origin.x, rtClient.origin.y, rtClient.size.width, rtClient.size.height-50);
    
    [self.view addSubview:_radioList];
    
    
    //防止SVPullToRefresh在iOS7上会缩到导航栏和状态栏后。
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        UIEdgeInsets insets = _radioList.contentInset;
        insets.top = self.navigationController.navigationBar.bounds.size.height +
        [UIApplication sharedApplication].statusBarFrame.size.height;
        _radioList.contentInset = insets;
        _radioList.scrollIndicatorInsets = insets;
    }
    
    __weak typeof(self) weakSelf = self;
    [_radioList addPullToRefreshWithActionHandler:^{
        [weakSelf refreshRadioList];
    }];
    
    _radioList.showsPullToRefresh = true;
    [self loadDefaultRadioList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


+ (NSString*) getDataCacheDir
{
    NSString* strDataDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/datacache"];
    
    //如果目录不存在，则创建
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if (![defaultManager fileExistsAtPath:strDataDir]) {
        [defaultManager createDirectoryAtPath:strDataDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return strDataDir;
}

- (BOOL) loadDefaultRadioList
{
    NSString* strUrl = @"http://www.cathassist.org/radio/getradio.php";
    
    NSString* strFile = [[RadioListViewController getDataCacheDir] stringByAppendingPathComponent:[strUrl md5]];
    
    
    //判断是否存在缓存文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:strFile] == FALSE)
    {
        //不存在缓存文件，刷新界面
        [_radioList triggerPullToRefresh];
        return FALSE;
    }
    
    
    //从缓存文件中加载数据
    FLOG(@"Fetch radio list from cache...");
    NSData *data=[NSData dataWithContentsOfFile:strFile];
    
    id result=[NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingAllowFragments
                                                    error:nil];
    
    [_channels removeAllObjects];
    
    NSDictionary* dict = result;
    NSArray *keys = [dict allKeys];// 所有key
    for(int i=0;i<[keys count];i++)
    {
        NSString *key = [keys objectAtIndex:i];
        ChannelModel* model = [[ChannelModel alloc] initWithDictionary:[dict objectForKey:key]];
        model.key = key;
        
        [_channels addObject:model];
    }
    [_radioList reloadData];
    
    return TRUE;
}

- (BOOL) refreshRadioList
{
    NSString* strUrl = @"http://www.cathassist.org/radio/getradio.php";
    FLOG(@"Fetch channel from:%@",strUrl);
    
    NSString* strFile = [[RadioListViewController getDataCacheDir] stringByAppendingPathComponent:[strUrl md5]];
    
    [[HttpManager defaultManager] downloadFromUrl:strUrl
                                filePath:strFile
                                complete:^(BOOL successed, NSDictionary *result)
                                {
                                    if (successed && result!=nil)
                                    {
                                        [_channels removeAllObjects];
                                        
                                        NSDictionary* dict = result;
                                        NSArray *keys = [dict allKeys];// 所有key
                                        for(int i=0;i<[keys count];i++)
                                        {
                                            NSString *key = [keys objectAtIndex:i];
                                            ChannelModel* model = [[ChannelModel alloc] initWithDictionary:[dict objectForKey:key]];
                                                     model.key = key;
                                            
                                            [_channels addObject:model];
                                            FLOG(@"Load channel:%@",model.title);
                                        }
                                        [_radioList reloadData];
                                    }
                                    
                                    [_radioList.pullToRefreshView stopAnimating];
                                }
     ];
    
    /*
    AFHTTPRequestOperationManager* manager = [AFHTTPRequestOperationManager manager];
    [manager GET:strUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if(responseObject!=nil)
         {
             [_channels removeAllObjects];
             
             NSDictionary* dict = responseObject;
             
             NSArray *keys = [dict allKeys];// 所有key
             for(int i=0;i<[keys count];i++)
             {
                 NSString *key = [keys objectAtIndex:i];
                 ChannelModel* model = [[ChannelModel alloc] initWithDictionary:[dict objectForKey:key]];
                 model.key = key;
                 
                 [_channels addObject:model];
                 NSLog(@"Load channel:%@",model.title);
             }
             
             [_radioList reloadData];
         }
         [_radioList.pullToRefreshView stopAnimating];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"Error: %@", error);
         [_radioList.pullToRefreshView stopAnimating];
     }];*/
    
    return TRUE;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_channels count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:_radioList cellForRowAtIndexPath:indexPath];
    
    
    return cell.frame.size.height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RadioCell = @"RadioCell";
    
    if(indexPath.row>=[_channels count])
        return nil;
    
    ChannelModel* c = _channels[indexPath.row];
    
    UITableViewCell *cell = [_radioList dequeueReusableCellWithIdentifier:RadioCell];
    if(cell==nil)
    {
        cell = [[RadioListViewCell alloc] initWithChannel:c:_radioList.frame.size.width];
    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
