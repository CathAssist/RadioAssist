//
//  ChannelPlayerViewController.h
//  radio
//
//  Created by Peter on 14/7/13.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Model/ChannelModel.h"

@interface ChannelPlayerViewController : UIViewController

+ (ChannelPlayerViewController*) getInstance;

- (void) setChannel:(ChannelModel*) channel;

@end
