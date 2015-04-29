//
//  UIImage+PKImage.m
//  PKResManager
//
//  Created by zhongsheng on 12-11-27.
//
//

#import "UIImage+PKImage.h"
#import "PKResManager+Private.h"

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
    // remove ext
    if ([aKey hasSuffix:@".png"] || [aKey hasSuffix:@".jpg"]) {
        aKey = [aKey substringToIndex:((NSString*)aKey).length-4];
    }
    
    UIImage *image = [PKResManager getInstance].resImageCache[aKey];
    if (image == nil)
    {
        // no cache
        image = [UIImage pk_imageForKey:aKey style:[PKResManager getInstance].currentStyleName];
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
    if (aKey == nil || name.length <= 0)
    {
        DLog(@" pk_imageForKey:style: aKey = nil || name.length <= 0");
        return nil;
    }
    // remove ext
    if ([aKey hasSuffix:@".png"] || [aKey hasSuffix:@".jpg"])
    {
        aKey = [aKey substringToIndex:((NSString*)aKey).length-4];
    }
    
    UIImage *image = nil;
    NSBundle *styleBundle = nil;

    if (![name isEqualToString:[PKResManager getInstance].currentStyleName])
    {
        styleBundle = [[PKResManager getInstance] bundleByStyleName:name];
    } else {
        styleBundle = [PKResManager getInstance].currentStyleBundle;
    }
    
    // @3x
    if (![aKey hasSuffix:@"@3x"]) {
        image = [UIImage pk_imageForKey:[NSString stringWithFormat:@"%@@3x",aKey] inBundle:styleBundle];
    } else if ([aKey hasSuffix:@"@3x"]){
        image = [UIImage pk_imageForKey:[aKey substringToIndex:((NSString*)aKey).length-3] inBundle:styleBundle];
    }
    
    // @2x
    if (image == nil)
    {
        if (![aKey hasSuffix:@"@2x"]) {
            image = [UIImage pk_imageForKey:[NSString stringWithFormat:@"%@@2x",aKey] inBundle:styleBundle];
        } else if ([aKey hasSuffix:@"@2x"]){
            image = [UIImage pk_imageForKey:[aKey substringToIndex:((NSString*)aKey).length-3] inBundle:styleBundle];
        }
    }
    
    if (image == nil) {
        image = [UIImage pk_imageForKey:aKey inBundle:styleBundle];
    }

    // mainBundle
    if (image == nil)
    {
        DLog(@" will get default style1 => %@",aKey);
        styleBundle = [NSBundle mainBundle];
        image = [UIImage pk_imageForKey:aKey inBundle:styleBundle];
    }
    if (image == nil) {
        DLog(@" will get default style2 => %@",aKey);
        image = [UIImage imageNamed:aKey];
    }
    
    if (image == nil && ![name isEqualToString:[PKResManager getInstance].defaultStyleName]) {
        DLog(@" pk_imageForKey:style: currentStyle not exist")
        image = [UIImage pk_imageForKey:aKey style:[PKResManager getInstance].defaultStyleName];
    }
    
    return image;
}

// support png&jpg
+ (UIImage *)pk_imageForKey:(id)aKey inBundle:(NSBundle *)bundle
{
    NSString *imagePath = [bundle pathForResource:aKey ofType:@"png"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        imagePath = [bundle pathForResource:aKey ofType:@"jpg"];
    }
    return [UIImage imageWithContentsOfFile:imagePath];
}
@end
