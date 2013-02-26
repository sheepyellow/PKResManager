//
//  UIImage+PKImage.m
//  PKResManager
//
//  Created by zhongsheng on 12-11-27.
//
//

#import "UIImage+PKImage.h"

@implementation UIImage (PKImage)

+ (UIImage *)imageForKey:(id)key
{
    return [UIImage imageForKey:key cache:YES];
}

+ (UIImage *)imageForKey:(id)key cache:(BOOL)needCache
{
    if (key == nil) {
        DLog(@" imageForKey:cache: key = nil");
        return nil;
    }
    
    if ([key hasSuffix:@".png"] || [key hasSuffix:@".jpg"]) {
        key = [key substringToIndex:((NSString*)key).length-4];
    }
    
    UIImage *image = [[PKResManager getInstance].resImageCache objectForKey:key];
    if (image == nil)
    {
        image = [UIImage imageForKey:key style:[PKResManager getInstance].styleName];
    }
    // cache
    if (image != nil && needCache)
    {
        [[PKResManager getInstance].resImageCache setObject:image forKey:key];
    }
    
    return image;
}

+ (UIImage *)imageForKey:(id)key style:(NSString *)name
{
    if (key == nil)
    {
        DLog(@" imageForKey:style: key = nil");
        return nil;
    }
    if ([key hasSuffix:@".png"] || [key hasSuffix:@".jpg"])
    {
        key = [key substringToIndex:((NSString*)key).length-4];
    }
    NSString *imagePath = nil;
    UIImage *image = nil;
    NSBundle *styleBundle = nil;
    // 不是当前style情况
    if (![name isEqualToString:[PKResManager getInstance].styleName])
    {
        styleBundle = [[PKResManager getInstance] bundleByStyleName:name];
    }
    else
    {
        styleBundle = [PKResManager getInstance].styleBundle;
    }
    
    imagePath = [styleBundle pathForResource:key ofType:@"png"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        imagePath = [styleBundle pathForResource:key ofType:@"jpg"];
    }
    image = [UIImage imageWithContentsOfFile:imagePath];
    
    // 处理mainBundle情况
    if (image == nil)
    {
        DLog(@" will get default style => %@",key);
        styleBundle = [NSBundle mainBundle];
        imagePath = [styleBundle pathForResource:key ofType:@"png"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
            imagePath = [styleBundle pathForResource:key ofType:@"jpg"];
        }
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    
    return image;
}

@end
