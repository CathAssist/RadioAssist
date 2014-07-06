//
//  RadioListView.m
//  radio
//
//  Created by Peter on 14/7/5.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import "RadioListView.h"
#import "RadioListViewCell.h"
#import "../Controller/RadioListViewController.h"

@interface RadioListView()
{
}

@end

@implementation RadioListView


- (instancetype) initWithController : (RadioListViewController*)controller
{
    self = [super initWithFrame:CGRectZero];
    if(self)
    {
        // Initialization code
        self.delegate = controller;
        self.dataSource = controller;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
