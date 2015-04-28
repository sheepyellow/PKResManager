//
//  UIImage+PKImage.m
//  PKResManager
//
//  Created by zhongsheng on 12-11-27.
//
//

#import "UIImage+PKImage.h"

@implementation UIImage (PKImage)

+ (UIImage *)pk_imageForKey:(id)aKey
{
    return [UIImage pk_imageForKey:aKey cache:YES];
}

+ (UIImage *)pk_imageForKey:(id)aKey cache:(BOOL)needCache
{
    if (aKey == nil) {
        DLog(@" pk_imageForKey:cache: aKey = nil");
        return nil;
    }
    // 去除扩展名
    if ([aKey hasSuffix:@".png"] || [aKey hasSuffix:@".jpg"]) {
        aKey = [aKey substringToIndex:((NSString*)aKey).length-4];
    }
    
    UIImage *image = [PKResManager getInstance].resImageCache[aKey];
    if (image == nil)
    {
        // no cache
        image = [UIImage pk_imageForKey:aKey style:[PKResManager getInstance].styleName];
    }
    // cache
    if (image != nil && needCache)
    {
        [PKResManager getInstance].resImageCache[aKey] = image;
    }
    
    return image;
}

+ (UIImage *)pk_imageForKey:(id)aKey style:(NSString *)name
{
    if (aKey == nil)
    {
        DLog(@" pk_imageForKey:style: aKey = nil");
        return nil;
    }
    // 去除扩展名
    if ([aKey hasSuffix:@".png"] || [aKey hasSuffix:@".jpg"])
    {
        aKey = [aKey substringToIndex:((NSString*)aKey).length-4];
    }
    
    UIImage *image = nil;
    NSBundle *styleBundle = nil;
    // 不是当前style情况
    if (![name isEqualToString:[PKResManager getInstance].styleName])
    {
        styleBundle = [[PKResManager getInstance] bundleByStyleName:name];
    } else {
        styleBundle = [PKResManager getInstance].styleBundle;
    }
    
    image = [UIImage pk_imageForKey:aKey inBundle:styleBundle];
    
    // @2x情况
    if (image == nil)
    {
        if (![aKey hasSuffix:@"@2x"]) {
            image = [UIImage pk_imageForKey:[NSString stringWithFormat:@"%@@2x",aKey] inBundle:styleBundle];
        } else if ([aKey hasSuffix:@"@2x"]){
            image = [UIImage pk_imageForKey:[aKey substringToIndex:((NSString*)aKey).length-3] inBundle:styleBundle];
        }
    }
    
    // @3x情况
    if (image == nil)
    {
        if (![aKey hasSuffix:@"@3x"]) {
            image = [UIImage pk_imageForKey:[NSString stringWithFormat:@"%@@3x",aKey] inBundle:styleBundle];
        } else if ([aKey hasSuffix:@"@3x"]){
            image = [UIImage pk_imageForKey:[aKey substringToIndex:((NSString*)aKey).length-3] inBundle:styleBundle];
        }
    }
    
    // 最后从mainBundle中找
    if (image == nil)
    {
        DLog(@" will get default style => %@",aKey);
        styleBundle = [NSBundle mainBundle];
        image = [UIImage pk_imageForKey:aKey inBundle:styleBundle];
    }
    
    return image;
}

// 支持png和jpg，可扩展
+ (UIImage *)pk_imageForKey:(id)aKey inBundle:(NSBundle *)bundle
{
    NSString *imagePath = [bundle pathForResource:aKey ofType:@"png"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        imagePath = [bundle pathForResource:aKey ofType:@"jpg"];
    }
    return [UIImage imageWithContentsOfFile:imagePath];
}
@end
