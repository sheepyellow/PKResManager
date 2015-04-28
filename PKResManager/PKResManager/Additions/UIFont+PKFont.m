//
//  UIFont+PKFont.m
//  PKResManager
//
//  Created by zhongsheng on 12-11-27.
//
//

#import "UIFont+PKFont.h"

@implementation UIFont (PKFont)

+ (UIFont *)pk_fontForKey:(id)aKey
{
//    NSString *fontSize = [[PKResManager getInstance].configFontCache objectForKey:aKey];
//    if (!fontSize) {
//        fontSize = [[PKResManager getInstance].defaultConfigFontCache objectForKey:aKey];
//    }
//    
//    if (fontSize.floatValue > 0) {
//        return [UIFont systemFontOfSize:fontSize.floatValue];
//    }
    
    NSDictionary *retDict = [[PKResManager getInstance] getConfigDictByKey:aKey withType:PKResConfigType_Default];
    NSString *fontName = retDict[kPKConfigFontName];
    NSString *fontSize = retDict[kPKConfigFontSize];
    
    if (fontName.length > 0 && fontSize.length > 0) {
        return [UIFont fontWithName:fontName
                               size:fontSize.floatValue];
    } else {
        return [UIFont systemFontOfSize:fontSize.floatValue];
    }
    
    return nil;
}

@end
