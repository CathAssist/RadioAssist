//
//  RadioListViewCell.m
//  radio
//
//  Created by Peter on 14/7/6.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import "RadioListViewCell.h"

@interface RadioListViewCell()
{
    ChannelModel* _channel;
    UIImageView* _imageView;
    UILabel* _nameLabel;
}
@end

@implementation RadioListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (instancetype) initWithChannel : (ChannelModel*)channel
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        // Initialization code
        static NSInteger CellHeight = 80;
        
        _channel = channel;
        
        CGRect rect = self.frame;
        rect.size.height = CellHeight;
        
        [self setFrame:rect];
//        [self.layer setBorderWidth:1.0];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, CellHeight-20, CellHeight-20)];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_channel.logo]];
        _imageView.image = [UIImage imageWithData:imageData];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CellHeight, 0, rect.size.width-CellHeight, CellHeight)];
        _nameLabel.text = _channel.title;
        
        [self addSubview:_imageView];
        [self addSubview:_nameLabel];
    }
    
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
