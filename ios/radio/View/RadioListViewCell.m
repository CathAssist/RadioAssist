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
    UILabel* _descLabel;
    UILabel* _dateLabel;
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

- (instancetype) initWithChannel : (ChannelModel*)channel : (NSInteger)width
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        // Initialization code
        static NSInteger CellHeight = 80;
        
        _channel = channel;
        
        CGRect rect = self.frame;
        rect.size.height = CellHeight;
        rect.size.width = width;
        
        [self setFrame:rect];
//      [self.layer setBorderWidth:1.0];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, CellHeight-20, CellHeight-20)];
        [_imageView setImageURL:_channel.logo];
        
        //名称
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CellHeight, 15, rect.size.width-CellHeight, 20)];
        _nameLabel.text = _channel.title;
        _nameLabel.textColor = [[UIColor alloc] initWithRed:0 green:122/255 blue:1 alpha:1];
        _nameLabel.font = [UIFont fontWithName:@"Arial" size:20];
        
        //描述
        _descLabel = [[UILabel alloc] initWithFrame:CGRectMake(CellHeight, 35, rect.size.width-CellHeight, rect.size.height-35)];
        _descLabel.text = _channel.desc;
        _descLabel.textColor = [[UIColor alloc] initWithRed:0.4 green:0.4 blue:0.4 alpha:1];
        _descLabel.font = [UIFont fontWithName:@"Arial" size:12];
        
        //日期
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(rect.size.width-200,15, 190, 12)];
        _dateLabel.font = [UIFont fontWithName:@"Arial" size:12];
        _dateLabel.textColor = [[UIColor alloc] initWithRed:0.5 green:0.5 blue:0.5 alpha:1];
        _dateLabel.text = _channel.date;
        _dateLabel.textAlignment = NSTextAlignmentRight;
        
        
        
        [self addSubview:_imageView];
        [self addSubview:_nameLabel];
        [self addSubview:_descLabel];
        [self addSubview:_dateLabel];
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
