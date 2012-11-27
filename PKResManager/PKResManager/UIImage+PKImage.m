//
//  UIImage+PKImage.m
//  PKResManager
//
//  Created by zhongsheng on 12-11-27.
//
//

#import "UIImage+PKImage.h"

@implementation UIImage (PKImage)

+ (UIImage *)imageForKey:(id)key style:(NSString *)name
{
    if (key == nil) {
        DLog(@" imageForKey:style: key = nil");
        return nil;
    }
    NSBundle *tempBundle = [[PKResManager getInstance] bundleByStyleName:name];
    NSAssert(tempBundle != nil,@" tempBundle = nil");
    
    if ([key hasSuffix:@".png"] || [key hasSuffix:@".jpg"]) {
        key = [key substringToIndex:((NSString*)key).length-4];
    }
    
    UIImage *image = nil;
    NSString *imagePath = [tempBundle pathForResource:key ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:imagePath];
    
    if (image == nil) {
        imagePath = [[PKResManager getInstance].styleBundle pathForResource:key ofType:@"jpg"];
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    
    if (image == nil)
    {
        imagePath = [[NSBundle mainBundle] pathForResource:key ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    return image;
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
    NSString *imagePath = nil;
    if (image == nil)
    {
        imagePath = [[PKResManager getInstance].styleBundle pathForResource:key ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:imagePath];
        //DLog(@"imagePath:%@",imagePath);
    }
    if (image == nil) {
        imagePath = [[PKResManager getInstance].styleBundle pathForResource:key ofType:@"jpg"];
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    if (image == nil)
    {
        imagePath = [[NSBundle mainBundle] pathForResource:key ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    // if error ,get default resource
    if (image == nil) {
        DLog(@" will get default style => %@",key);
        NSBundle *defaultBundle = [[PKResManager getInstance] bundleByStyleName:SYSTEM_STYLE_LIGHT];
        NSString *imagePath = [defaultBundle pathForResource:key ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:imagePath];
        NSAssert(image!=nil,@" get default Image error !!!");
    }
    // cache
    if (image != nil && needCache)
    {
        [[PKResManager getInstance].resImageCache setObject:image forKey:key];
    }
    
    return image;
}

+ (UIImage *)imageForKey:(id)key
{
    return [UIImage imageForKey:key cache:YES];
}

@end
