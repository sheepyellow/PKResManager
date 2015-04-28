//
//  PKResManager+Private.m
//  PKResManager
//
//  Created by dabing on 15/4/28.
//
//

#import "PKResManager+Private.h"
#import <objc/runtime.h>

static void *const _kPKResManagerAssociatedResImageCache = (void *)&_kPKResManagerAssociatedResImageCache;

static void *const _kPKResManagerAssociatedDefaultConfigCache = (void *)&_kPKResManagerAssociatedDefaultConfigCache;

static void *const _kPKResManagerAssociatedDefaultConfigColorCache = (void *)&_kPKResManagerAssociatedDefaultConfigColorCache;

static void *const _kPKResManagerAssociatedDefaultConfigFontCache = (void *)&_kPKResManagerAssociatedDefaultConfigFontCache;

static void *const _kPKResManagerAssociatedConfigCache = (void *)&_kPKResManagerAssociatedConfigCache;

static void *const _kPKResManagerAssociatedConfigColorCache = (void *)&_kPKResManagerAssociatedConfigColorCache;

static void *const _kPKResManagerAssociatedConfigFontCache = (void *)&_kPKResManagerAssociatedConfigFontCache;

static void *const _kPKResManagerAssociatedDefaultStyleArray = (void *)&_kPKResManagerAssociatedDefaultStyleArray;

@implementation PKResManager (Private)

#pragma mark - Private

- (void)pk_setAssociatedObject:(id)aObj withKey:(const void *)aKey withPolicy:(objc_AssociationPolicy)aPolicy {
    [self willChangeValueForKey:[aObj description]];
    objc_setAssociatedObject(self, aKey, aObj, aPolicy);
    [self didChangeValueForKey:[aObj description]];
}

#pragma mark - Propertys

- (NSMutableArray *)defaultStyleArray {
    NSMutableArray *ret = (NSMutableArray *)objc_getAssociatedObject(self, _kPKResManagerAssociatedDefaultStyleArray);
    if (!ret) {
        NSDictionary *defaultStyleDict = @{kStyleID : PK_SYSTEM_STYLE_ID,
                                           kStyleName : PK_SYSTEM_STYLE_DEFAULT,
                                           kStyleURL : PK_SYSTEM_STYLE_DEFAULT_URL,
                                           kStyleVersion : PK_SYSTEM_STYLE_VERSION};        
        ret = [NSMutableArray arrayWithObjects:defaultStyleDict, nil];
        self.defaultStyleArray = ret;
    }
    return ret;
}

- (void)setDefaultStyleArray:(NSMutableArray *)defaultStyleArray {
    [self pk_setAssociatedObject:defaultStyleArray
                         withKey:_kPKResManagerAssociatedDefaultStyleArray
                      withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (NSMutableDictionary *)resImageCache {
    NSMutableDictionary *ret = (NSMutableDictionary *)objc_getAssociatedObject(self, _kPKResManagerAssociatedResImageCache);
    return ret;
}

- (void)setResImageCache:(NSMutableDictionary *)resImageCache {
    [self pk_setAssociatedObject:resImageCache
                         withKey:_kPKResManagerAssociatedResImageCache
                      withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

#pragma mark - 

- (NSMutableDictionary *)defaultConfigCache
{
    NSMutableDictionary *ret = (NSMutableDictionary *)objc_getAssociatedObject(self, _kPKResManagerAssociatedDefaultConfigCache);
    if (!ret) {
        NSDictionary *defalutStyleDict = self.defaultStyleArray[0];
        NSString *defaultStyleName = defalutStyleDict[kStyleName];
        NSBundle *tempBundle = [self bundleByStyleName:defaultStyleName];
        NSString *plistPath=[tempBundle pathForResource:CONFIG_PLIST_PATH ofType:@"plist"];
        ret = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        self.defaultConfigCache = ret;
    }
    return ret;
}

- (void)setDefaultConfigCache:(NSMutableDictionary *)defaultConfigCache {
    [self pk_setAssociatedObject:defaultConfigCache
                         withKey:_kPKResManagerAssociatedDefaultConfigCache
                      withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (NSMutableDictionary *)defaultConfigColorCache {
    NSMutableDictionary *ret = (NSMutableDictionary *)objc_getAssociatedObject(self, _kPKResManagerAssociatedDefaultConfigColorCache);
    if (!ret) {
        NSDictionary *defalutStyleDict = self.defaultStyleArray[0];
        NSString *defaultStyleName = defalutStyleDict[kStyleName];
        NSBundle *tempBundle = [self bundleByStyleName:defaultStyleName];
        NSString *plistPath=[tempBundle pathForResource:CONFIG_COLOR_PLIST_PATH ofType:@"plist"];
        ret = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        self.defaultConfigColorCache = ret;
    }
    return ret;
}

- (void)setDefaultConfigColorCache:(NSMutableDictionary *)defaultConfigColorCache {
    [self pk_setAssociatedObject:defaultConfigColorCache
                         withKey:_kPKResManagerAssociatedDefaultConfigColorCache
                      withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (NSMutableDictionary *)defaultConfigFontCache {
    NSMutableDictionary *ret = (NSMutableDictionary *)objc_getAssociatedObject(self, _kPKResManagerAssociatedDefaultConfigColorCache);
    if (!ret) {
        NSDictionary *defalutStyleDict = self.defaultStyleArray[0];
        NSString *defaultStyleName = defalutStyleDict[kStyleName];
        NSBundle *tempBundle = [self bundleByStyleName:defaultStyleName];
        NSString *plistPath=[tempBundle pathForResource:CONFIG_FONT_PLIST_PATH ofType:@"plist"];
        ret = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        self.defaultConfigFontCache = ret;
    }
    return ret;
}

- (void)setDefaultConfigFontCache:(NSMutableDictionary *)defaultConfigFontCache {
    [self pk_setAssociatedObject:defaultConfigFontCache
                         withKey:_kPKResManagerAssociatedDefaultConfigFontCache
                      withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (NSMutableDictionary *)configCache {
    NSMutableDictionary *ret = (NSMutableDictionary *)objc_getAssociatedObject(self, _kPKResManagerAssociatedConfigCache);
    return ret;
}

- (void)setConfigCache:(NSMutableDictionary *)configCache {
    [self pk_setAssociatedObject:configCache
                         withKey:_kPKResManagerAssociatedConfigCache
                      withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (NSMutableDictionary *)configColorCache {
    NSMutableDictionary *ret = (NSMutableDictionary *)objc_getAssociatedObject(self, _kPKResManagerAssociatedConfigColorCache);
    return ret;
}

- (void)setConfigColorCache:(NSMutableDictionary *)configColorCache {
    [self pk_setAssociatedObject:configColorCache
                         withKey:_kPKResManagerAssociatedConfigColorCache
                      withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

- (NSMutableDictionary *)configFontCache {
    NSMutableDictionary *ret = (NSMutableDictionary *)objc_getAssociatedObject(self, _kPKResManagerAssociatedConfigFontCache);
    return ret;
}

- (void)setConfigFontCache:(NSMutableDictionary *)configFontCache {
    [self pk_setAssociatedObject:configFontCache
                         withKey:_kPKResManagerAssociatedConfigFontCache
                      withPolicy:OBJC_ASSOCIATION_RETAIN_NONATOMIC];
}

#pragma mark - Medthod

- (id)getConfigDictByKey:(id)aKey withType:(PKResConfigType)type {
    id ret = nil;
    
    NSMutableDictionary *styleConfigCache = nil;
    NSMutableDictionary *defaultStyleConfigCache = nil;
    switch (type) {
        case PKResConfigType_Color:
            styleConfigCache = self.configColorCache;
            defaultStyleConfigCache = self.defaultConfigColorCache;
            break;
        case PKResConfigType_Font:
            styleConfigCache = self.configFontCache;
            defaultStyleConfigCache = self.defaultConfigFontCache;
            break;
        default:
            styleConfigCache = self.configCache;
            defaultStyleConfigCache = self.defaultConfigCache;
            break;
    }
    
    NSArray *keyArray = [aKey componentsSeparatedByString:PK_CONFIG_SEPARATE_KEY];
    for (id aKey in keyArray) {
        if (0 == [keyArray indexOfObject:aKey]) {
            ret = styleConfigCache[keyArray.firstObject];
        } else if (ret) {
            ret = [ret objectForKey:aKey];
        } else {
            break;
        }
    }
    
    if (nil == ret) {
        for (id aKey in keyArray) {
            if (0 == [keyArray indexOfObject:aKey]) {
                ret = defaultStyleConfigCache[keyArray.firstObject];
            } else if (ret) {
                ret = [ret objectForKey:aKey];
            } else {
                break;
            }
        }
    }
    
    return ret;
}

@end
