//
//  UIColor+PKColor.m
//  PKResManager
//
//  Created by zhongsheng on 12-11-27.
//
//

#import "UIColor+PKColor.h"

@implementation UIColor (PKColor)

+ (UIColor *)pk_colorForKey:(id)aKey
{
    NSDictionary *retDict = [[PKResManager getInstance] getConfigDictByKey:aKey withType:PKResConfigType_Default];
    NSString *colorStr = retDict[kPKConfigColor];
    
    //NSString *colorStr = [[PKResManager getInstance].configColorCache objectForKey:aKey];
    if (colorStr.length <= 0) {
        colorStr = [[PKResManager getInstance].defaultConfigColorCache objectForKey:aKey];
    }

    NSArray *colorArray = [colorStr componentsSeparatedByString:@","];
    
    NSInteger r = 255;
    NSInteger g = 255;
    NSInteger b = 255;
    CGFloat a = 1.0f;
    if (colorArray.count >= 3) {
        r = [colorArray[0] integerValue];
        g = [colorArray[1] integerValue];
        b = [colorArray[2] integerValue];
        if (colorArray.count >= 4) {
            a = [colorArray[3] floatValue];
        }
        if (a <= .0f) {
            return [UIColor clearColor];
        }
        return [self colorWithRed:((CGFloat)r / 255.f)
                            green:((CGFloat)g / 255.f)
                             blue:((CGFloat)b / 255.f)
                            alpha:a];
    } else {
        if ([colorStr hasPrefix:@"#"]) {
            colorStr = [colorStr substringFromIndex:1];
        }
        if ([[colorStr lowercaseString] hasPrefix:@"0x"]) {
            colorStr = [colorStr substringFromIndex:2];
        }
        if ([colorStr length] == 6) {
            NSScanner *scanner = [[NSScanner alloc] initWithString:colorStr];
            unsigned hexValue = 0;
            if ([scanner scanHexInt:&hexValue] && [scanner isAtEnd]) {
                r = ((hexValue & 0xFF0000) >> 16);
                g = ((hexValue & 0x00FF00) >>  8);
                b = ( hexValue & 0x0000FF)       ;
                return [self colorWithRed:((CGFloat)r / 255.f)
                                    green:((CGFloat)g / 255.f)
                                     blue:((CGFloat)b / 255.f)
                                    alpha:a];
            }
        }
    }
    return nil;
}


+ (UIColor *)pk_colorForKey:(id)aKey alpha:(CGFloat)alpha
{
    return [[UIColor pk_colorForKey:aKey] colorWithAlphaComponent:alpha];
}

@end
