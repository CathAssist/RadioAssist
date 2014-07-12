//
//  RadioListViewCell.h
//  radio
//
//  Created by Peter on 14/7/6.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Model/ChannelModel.h"

@interface RadioListViewCell : UITableViewCell

- (instancetype) initWithChannel : (ChannelModel*)channel : (NSInteger)width;

@property (strong,nonatomic,readonly) ChannelModel* channel;
@end
