//
//  SettingsViewController.m
//  radio
//
//  Created by Peter on 14/12/27.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import "SettingsViewController.h"
#import "MainViewController.h"

static NSString* kDefaultCell = @"DefaultCell";
static NSString* kSwtichCell = @"SwitchCell";

@interface SettingsViewController ()
{
    UISwitch* _switchAutoGospel;
    UISwitch* _switchAutoRefresh;
}
@end

@implementation SettingsViewController

+ (SettingsViewController*) getInstance
{
    static SettingsViewController* theInstance = nil;
    if(theInstance == nil)
    {
        theInstance = [[SettingsViewController alloc] initWithNibName:nil bundle:nil];
    }
    
    return theInstance;
}

- (id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nil bundle:nil];
    if(self)
    {
        _switchAutoGospel = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_switchAutoGospel addTarget:self action:@selector(switchAutoGospelChanged:) forControlEvents:UIControlEventValueChanged];
        
        _switchAutoRefresh = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_switchAutoRefresh addTarget:self action:@selector(switchAutoRefreshChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kDefaultCell];
    [_switchAutoRefresh setOn:[[MainViewController getInstance] isAutoRefresh] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [_switchAutoRefresh setOn:[[MainViewController getInstance] isAutoRefresh] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)switchAutoGospelChanged:(id)sender
{
    
}

- (void)switchAutoRefreshChanged:(id)sender
{
    [[MainViewController getInstance] setAutoRefresh:[_switchAutoRefresh isOn]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 4;
            break;
        default:
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDefaultCell forIndexPath:indexPath];
    
    if(indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0:
            {
                cell.accessoryView = _switchAutoRefresh;
                [cell.textLabel setText:NSLocalizedString(@"Auto refresh", nil)];
            }
                break;
                
            default:
                break;
        }
    }
    else if(indexPath.section == 1)
    {
        switch (indexPath.row) {
            case 0:
                [[cell textLabel] setText:NSLocalizedString(@"About us", nil)];
                break;
            case 1:
                [[cell textLabel] setText:NSLocalizedString(@"Share RadioAssist", nil)];
                break;
            case 2:
                [[cell textLabel] setText:NSLocalizedString(@"Vote for RadioAssist", nil)];
                break;
            case 3:
                [[cell textLabel] setText:NSLocalizedString(@"Our taobao", nil)];
                break;
            default:
                break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
    {
        switch (indexPath.row) {
            case 0:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.cathassist.org/3rd/aboutus.html"]];
            }
                break;
            case 1:
            {
                dispatch_async(dispatch_queue_create("share", NULL), ^{
                    NSArray *activityItems = @[[NSString stringWithFormat:@"电台小助手 http://t.cn/RZU0uz3 \n提供梵蒂冈广播、晨星电台、福音i广播、每日福音等多个电台频道。"]];
                    
                    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                                     applicationActivities:nil];
                    activityController.excludedActivityTypes = @[UIActivityTypeAssignToContact,
                                                                 UIActivityTypePrint,];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self presentViewController:activityController  animated:YES completion:nil];
                    });
                });
            }
                break;
            case 2:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/dian-tai-xiao-zhu-shou/id954975179"]];
            }
                break;
            case 3:
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://taobao.cathassist.org"]];
            }
                break;
            default:
                break;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
