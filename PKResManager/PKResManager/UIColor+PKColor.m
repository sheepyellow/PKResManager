//
//  UIColor+PKColor.m
//  PKResManager
//
//  Created by zhongsheng on 12-11-27.
//
//

#import "UIColor+PKColor.h"

@implementation UIColor (PKColor)

+ (UIColor *)colorForKey:(id)key
{
    
    NSArray *keyArray = [key componentsSeparatedByString:@"-"];
    NSAssert1(keyArray.count == 2, @"module key name error!!! [color]==> %@", key);
    
    NSString *moduleKey = [keyArray objectAtIndex:0];
    NSString *memberKey = [keyArray objectAtIndex:1];
    
    NSDictionary *moduleDict = [[PKResManager getInstance].resOtherCache objectForKey:moduleKey];
    NSDictionary *memberDict = [moduleDict objectForKey:memberKey];
    
    NSString *colorStr = [memberDict objectForKey:@"rgb"];
    
    NSNumber *redValue;
    NSNumber *greenValue;
    NSNumber *blueValue;
    NSNumber *alphaValue;
    NSArray *colorArray = [colorStr componentsSeparatedByString:@","];
    if (colorArray != nil && colorArray.count == 3) {
        redValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:0] floatValue]];
        greenValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:1] floatValue]];
        blueValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:2] floatValue]];
        alphaValue = [NSNumber numberWithFloat:1.0];
    } else if (colorArray != nil && colorArray.count == 4) {
        redValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:0] floatValue]];
        greenValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:1] floatValue]];
        blueValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:2] floatValue]];
        alphaValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:3] floatValue]];
    } else {
        return nil;
    }
    
    if ([alphaValue floatValue]<=0.0f) {
        return [UIColor clearColor];
    }
    return [UIColor colorWithRed:[redValue floatValue]/255.0f
                           green:[greenValue floatValue]/255.0f
                            blue:[blueValue floatValue]/255.0f
                           alpha:[alphaValue floatValue]];
    
}
@end
