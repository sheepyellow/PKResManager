//
//  PKImage.m
//  PKResManager
//
//  Created by zhongsheng on 13-2-26.
//
//

#import "PKImage.h"

@implementation PKImage
@synthesize
pkKey = _pkKey,
pkPath = _pkPath,
pkStyleName = _pkStyleName,
pkNeedCache = _pkNeedCache;

- (void)dealloc
{
    if (_pkKey) [_pkKey release],_pkKey = nil;
    if (_pkPath) [_pkPath release],_pkPath = nil;
    if (_pkStyleName) [_pkStyleName release], _pkStyleName = nil;
    [[PKResManager getInstance] removeChangeStyleObject:self];
    [super dealloc];    
}

- (void)changeStyle:(id)sender
{
    if (_pkNeedCache) {
        
    }
}

- (id)initWithContentsOfFile:(NSString *)path
{
    self = [super initWithContentsOfFile:path];
    if (self) {
        [[PKResManager getInstance] addChangeStyleObject:self];
        _pkNeedCache = YES; // 默认需要缓存
    }
    return self;
}

+ (PKImage *)imageWithContentsOfFile:(NSString *)path
{
    PKImage *image = [[PKImage alloc] initWithContentsOfFile:path];
    return [image autorelease];
}

- (id)initForKey:(id)key style:(NSString *)name cache:(BOOL)needCache
{
    self = [super init];
    if (self) {
        _pkKey = [key retain];
        _pkStyleName = [name copy];
        _pkNeedCache = needCache;
        
        if (![name isEqualToString:[PKResManager getInstance].styleName])
        {
            NSBundle *tempBundle = [[PKResManager getInstance] bundleByStyleName:name];
            NSAssert(tempBundle != nil,@" tempBundle = nil");
            
            if ([key hasSuffix:@".png"])
            {
                key = [key substringToIndex:((NSString*)key).length-4];
                _pkPath = [tempBundle pathForResource:key ofType:@"png"];
            }
            else if ([key hasSuffix:@".jpg"]) {
                key = [key substringToIndex:((NSString*)key).length-4];
                _pkPath = [tempBundle pathForResource:key ofType:@"png"];
            }
        }
        else
        {
            _pkPath = [[PKResManager getInstance].styleBundle pathForResource:key ofType:@"png"];
        }
//        if (image == nil)
//        {
//            _pkPath = [[PKResManager getInstance].styleBundle pathForResource:key ofType:@"jpg"];
//        }
//        
//        if (image == nil)
//        {
//            DLog(@" will get default style => %@",key);
//            imagePath = [[NSBundle mainBundle] pathForResource:key ofType:@"png"];
//            image = [PKImage imageWithContentsOfFile:imagePath];
//            NSAssert(image!=nil,@" get default Image error !!!");
//        }
        
    }
    return self;
}
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
    if (key == nil) {
        DLog(@" imageForKey:style: key = nil");
        return nil;
    }
    
    UIImage *image = nil;
    NSString *imagePath = nil;
    
    if (![name isEqualToString:[PKResManager getInstance].styleName])
    {
        NSBundle *tempBundle = [[PKResManager getInstance] bundleByStyleName:name];
        NSAssert(tempBundle != nil,@" tempBundle = nil");
        
        if ([key hasSuffix:@".png"] || [key hasSuffix:@".jpg"])
        {
            key = [key substringToIndex:((NSString*)key).length-4];
        }
        imagePath = [tempBundle pathForResource:key ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:imagePath];
        
        if (image == nil)
        {
            imagePath = [[PKResManager getInstance].styleBundle pathForResource:key ofType:@"jpg"];
            image = [UIImage imageWithContentsOfFile:imagePath];
        }
    }
    else
    {
        imagePath = [[PKResManager getInstance].styleBundle pathForResource:key ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    if (image == nil)
    {
        imagePath = [[PKResManager getInstance].styleBundle pathForResource:key ofType:@"jpg"];
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    
    if (image == nil)
    {
        DLog(@" will get default style => %@",key);
        imagePath = [[NSBundle mainBundle] pathForResource:key ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:imagePath];
        NSAssert(image!=nil,@" get default Image error !!!");
    }
    
    return image;
}

@end
