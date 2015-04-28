//
//  UIColor+PKColor.h
//  PKResManager
//
//  Created by zhongsheng on 12-11-27.
//
//

#import <UIKit/UIKit.h>

@interface UIColor (PKColor)

+ (UIColor *)pk_colorForKey:(id)aKey;

+ (UIColor *)pk_colorForKey:(id)aKey alpha:(CGFloat)alpha;

@end
