//
//  TrackModel.h
//  cxradio
//
//  Created by Peter on 14-5-11.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface TrackModel : NSObject

- (id)initWithDictionary:(NSDictionary*) dict;

@property (strong,nonatomic)NSString* title;
@property (strong,nonatomic)NSString* src;

@end
