//
//  TrackListViewController.h
//  radio
//
//  Created by Peter on 14/7/26.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Model/ChannelModel.h"

@interface TrackListViewController : UITableViewController

-(void) setChannel:(ChannelModel*)channel;

@end
