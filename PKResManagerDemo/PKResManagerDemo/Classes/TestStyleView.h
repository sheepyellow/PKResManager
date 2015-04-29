//
//  TestStyleView.h
//  PKResManager
//
//  Created by passerbycrk on 12-7-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PKResManagerKit.h"

@interface TestStyleView : UIView <PKResChangeStyleDelegate>
{
    BOOL _isDefault;
    UIImageView *_imageView;
    UILabel *_label;
}

@end
