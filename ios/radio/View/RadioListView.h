//
//  RadioListView.h
//  radio
//
//  Created by Peter on 14/7/5.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Controller/RadioListViewController.h"

@interface RadioListView : UITableView

- (instancetype) initWithController : (RadioListViewController*)controller;

@end
