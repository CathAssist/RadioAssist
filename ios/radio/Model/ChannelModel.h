//
//  ChannelModel.h
//  cxradio
//
//  Created by Peter on 14-5-11.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import "TrackModel.h"

@interface ChannelModel : NSObject

- (id)initWithDictionary:(NSDictionary*) dict;
- (TrackModel*)currentTrack;
- (TrackModel*)firstTrack;
- (TrackModel*)nextTrack;
- (TrackModel*)prevTrack;
- (TrackModel*)setTrackWithIndex:(NSInteger) index;


@property (strong,nonatomic) NSString* title;
@property (strong,nonatomic) NSString* desc;
@property (strong,nonatomic) NSString* date;
@property (strong,nonatomic) NSString* logo;
@property (strong,nonatomic) NSString* key;

@property (strong,nonatomic) NSMutableArray* tracks;

@end
