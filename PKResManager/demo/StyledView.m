//
//  StyledView.m
//  PKResManager
//
//  Created by zhong sheng on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StyledView.h"

@implementation StyledView

- (void)dealloc
{
//    DLog(@" dealloc :%@",[self description]);
    [[PKResManager getInstance] removeChangeStyleObject:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[PKResManager getInstance] addChangeStyleObject:self];
        self.backgroundColor = [UIColor pk_colorForKey:@"DemoModule-StyleViewColor" alpha:0.3f];
        _isDefault = YES;
        UIImage *image = [UIImage pk_imageForKey:@"sendbutton"];
        _imageView = [[UIImageView alloc] initWithImage:image];
        [self addSubview:_imageView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 80, 30)];
        _label.backgroundColor = [UIColor clearColor];
        _label.text = @"Font Test";
        _label.font = [UIFont pk_fontForKey:@"DemoModule-LabelFont"];
        [_label setTextColor:[UIColor pk_colorForKey:@"DemoModule-SubModule-LabelColor"]];
        [self addSubview:_label];
    }
    return self;
}

#pragma mark - delegate
- (void)didChangeStyleWithManager:(PKResManager *)manager
{
//    DLog(@" change :%@",[self description]);
    self.backgroundColor = [UIColor pk_colorForKey:@"DemoModule-StyleViewColor" alpha:0.3f];
    UIImage *image = [UIImage pk_imageForKey:@"sendbutton"];
    _imageView.image = image;
    _label.font = [UIFont pk_fontForKey:@"DemoModule-LabelFont"];
    [_label setTextColor:[UIColor pk_colorForKey:@"DemoModule-SubModule-LabelColor"]];
    
    [self setNeedsLayout];
}

@end
