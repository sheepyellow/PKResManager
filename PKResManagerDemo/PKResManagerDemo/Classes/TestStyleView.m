//
//  TestStyleView.m
//  PKResManager
//
//  Created by passerbycrk on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TestStyleView.h"

@implementation TestStyleView

- (void)dealloc {
    [[PKResManager getInstance] removeChangeStyleObserver:self];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _isDefault = YES;
        UIImage *image = [UIImage pk_imageForKey:@"sendbutton"];
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.frame = CGRectMake(5.f, (frame.size.height - image.size.height)/2.f, image.size.width, image.size.height);
        [self addSubview:_imageView];
        
        _label = [[UILabel alloc] initWithFrame:CGRectMake(image.size.width + 10.f, 10, 80, 30)];
        _label.backgroundColor = [UIColor clearColor];
        _label.text = @"Font Test";
        [self addSubview:_label];
        
        [[PKResManager getInstance] addChangeStyleObserver:self];
    }
    return self;
}

#pragma mark - PKResChangeStyleDelegate

- (void)didChangeStyleWithManager:(PKResManager *)manager {
    self.backgroundColor = [UIColor pk_colorForKey:@"DemoModule-StyleViewColor" alpha:0.3f];
    UIImage *image = [UIImage pk_imageForKey:@"sendbutton"];
    _imageView.image = image;
    _label.font = [UIFont pk_fontForKey:@"DemoModule-LabelFont"];
    [_label setTextColor:[UIColor pk_colorForKey:@"DemoModule-SubModule-LabelColor"]];
    
    [self setNeedsLayout];
}

@end
