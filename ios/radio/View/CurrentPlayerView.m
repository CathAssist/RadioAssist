//
//  CurrentPlayerView.m
//  radio
//
//  Created by Peter on 14/7/5.
//  Copyright (c) 2014年 CathAssist. All rights reserved.
//

#import "CurrentPlayerView.h"

@interface CurrentPlayerView ()
{
    UIButton* _btnPlayPause;     //播放按钮
}
@end


@implementation CurrentPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self setBackgroundColor:[UIColor whiteColor]];
        self.layer.borderWidth = 1.0;
        
        _btnPlayPause = [[UIButton alloc] init];
        _btnPlayPause.frame = CGRectMake(10, 5, 40, 40);
        [_btnPlayPause setBackgroundImage:[UIImage imageNamed:@"play_ctrl"] forState:UIControlStateNormal];
        [_btnPlayPause setBackgroundImage:[UIImage imageNamed:@"pause_ctrl"] forState:UIControlStateSelected];
        
        [self addSubview:_btnPlayPause];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //获得处理的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //设置线条粗细宽度
    CGContextSetLineWidth(context, 1.0);
    
    //设置颜色
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    //开始一个起始路径
    CGContextBeginPath(context);
    //起始点设置为(0,0):注意这是上下文对应区域中的相对坐标，
    CGContextMoveToPoint(context, self.frame.origin.x, self.frame.origin.y);
    //设置下一个坐标点
    CGContextAddLineToPoint(context, self.frame.origin.x+self.frame.size.width, self.frame.origin.y);
    //设置下一个坐标点
    CGContextAddLineToPoint(context, self.frame.origin.x+self.frame.size.width, self.frame.origin.y+self.frame.size.height);
    //设置下一个坐标点
    CGContextAddLineToPoint(context, self.frame.origin.x, self.frame.origin.y+self.frame.size.height);
    //连接上面定义的坐标点
    CGContextStrokePath(context);
}
*/

@end
