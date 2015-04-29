//
//  UIFont+PKFont.m
//  PKResManager
//
//  Created by zhongsheng on 12-11-27.
//
//

#import "UIFont+PKFont.h"
#import "PKResManager+Private.h"
#import "PKResManagerDefine.h"

@implementation UIFont (PKFont)

+ (UIFont *)pk_fontForKey:(id)aKey
{
    id ret = [[PKResManager getInstance] getConfigDictByKey:aKey withType:PKResConfigType_Font];
    
    if ([ret isKindOfClass:[NSDictionary class]]) {
        NSString *fontName = ret[kPKConfigFontName];
        id        fontSize = ret[kPKConfigFontSize];
        if (fontName.length > 0 && fontSize) {
            return [UIFont fontWithName:fontName
                                   size:[fontSize floatValue]];
        } else {
            return [UIFont systemFontOfSize:[fontSize floatValue]];
        }
    } else if ([ret isKindOfClass:[NSString class]] || [ret isKindOfClass:[NSNumber class]]) {
        return [UIFont systemFontOfSize:[ret floatValue]];
    }

    return nil;
}

@end
