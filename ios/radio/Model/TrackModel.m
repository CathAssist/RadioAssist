//
//  TrackModel.m
//  cxradio
//
//  Created by Peter on 14-5-11.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import "TrackModel.h"

@implementation TrackModel
- (id)initWithDictionary:(NSDictionary*) dict
{
    self = [super init];
    if(self)
    {
        NSAssert([dict isKindOfClass:[NSDictionary class]], @"Error Dict in trackmodel");
        [self setValuesForKeysWithDictionary:dict];
    }
    
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    [super setValue:value forKey:key];
}


@end
