//
//  PKResManager.m
//  TestResManager
//
//  Created by zhong sheng on 12-7-13.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "PKResManager.h"
#import "PKResManagerKit.h"

static const void* RetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
static void ReleaseNoOp(CFAllocatorRef allocator, const void *value) { }
NSMutableArray* CreateNonRetainingArray() {
    CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
    callbacks.retain = RetainNoOp;
    callbacks.release = ReleaseNoOp;
    return (NSMutableArray*)CFBridgingRelease(CFArrayCreateMutable(nil, 0, &callbacks));
}

@interface PKResManager ()
@property (nonatomic, strong) NSMutableArray *styleChangedHandlers; // delegates
@property (nonatomic, strong) NSMutableArray *resObjectsArray;
@property (nonatomic, strong) NSMutableArray *defaultStyleArray;
@property (nonatomic, strong) NSMutableArray *customStyleArray;

@property (nonatomic, readwrite, strong) NSBundle *styleBundle;
@property (nonatomic, readwrite, strong) NSMutableDictionary *defaultConfigCache;
@property (nonatomic, readwrite, strong) NSMutableDictionary *defaultConfigColorCache;
@property (nonatomic, readwrite, strong) NSMutableDictionary *defaultConfigFontCache;
@property (nonatomic, readwrite, strong) NSMutableArray *allStyleArray;
@property (nonatomic, readwrite, strong) NSString *styleName;
@property (nonatomic, readwrite, assign) PKResStyleType styleType;
@property (nonatomic, readwrite, assign) BOOL isLoading;
@end

@implementation PKResManager

- (void)dealloc
{
    [self.styleChangedHandlers removeAllObjects];
    if (_allStyleArray.count>0) {
        [_allStyleArray removeAllObjects];
        _allStyleArray= nil;
    }
}

- (void)addChangeStyleObject:(id)object
{
    if (![self.resObjectsArray containsObject:object])
    {
        @synchronized(self.resObjectsArray)
        {
            [self.resObjectsArray addObject:object];
        }
    }
}

- (void)removeChangeStyleObject:(id)object
{
    if ([self.resObjectsArray containsObject:object])
    {
        @synchronized(self.resObjectsArray)
        {
            [self.resObjectsArray removeObject:object];
        }
    }
}
- (void)swithToStyle:(NSString *)name
{
    [self swithToStyle:name onComplete:nil];
}
- (void)swithToStyle:(NSString *)name onComplete:(ResStyleCompleteBlock)block
{
    if ([_styleName isEqualToString:name]
        || name == nil )
    {
        if (block) {
            NSError *error = [NSError errorWithDomain:PK_STYLE_ERROR_DOMAIN code:PKStyleErrorCode_Unavailable userInfo:nil];
            block(YES,error);
        }
        return;
    }
    else if (_isLoading) {
        if (block) {
            block(NO,nil);
        }
        
        return;
    }
    DLog(@"[Style Manager] start change style");
    _isLoading = YES;

    _styleName = [name copy];
    
    // read resource bundle
    _styleBundle = [self bundleByStyleName:name];
    if (self.styleBundle == nil) {
        if (block) {
            NSError *error = [NSError errorWithDomain:PK_STYLE_ERROR_DOMAIN code:PKStyleErrorCode_BundleName userInfo:nil];
            block(YES,error);
        }
        _isLoading = NO;
        return;
    }
    
    // remove cache
    [_resImageCache removeAllObjects];
    [_configCache removeAllObjects];
    
    // get plist dict
    NSString *plistPath=[self.styleBundle pathForResource:CONFIG_PLIST_PATH ofType:@"plist"];
    self.configCache = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    DLog(@"[Style Manager] configCacheCount:%ld",(long)self.configCache.count);
    
    NSString *colorPlistPath = [self.styleBundle pathForResource:CONFIG_COLOR_PLIST_PATH ofType:@"plist"];
    self.configColorCache = [NSMutableDictionary dictionaryWithContentsOfFile:colorPlistPath];
    DLog(@"[Style Manager] configColorCacheCount:%ld",(long)self.configColorCache.count);
    
    NSString *fontPlistPath = [self.styleBundle pathForResource:CONFIG_FONT_PLIST_PATH ofType:@"plist"];
    self.configFontCache = [NSMutableDictionary dictionaryWithContentsOfFile:fontPlistPath];
    DLog(@"[Style Manager] configFontCacheCount:%ld",(long)self.configFontCache.count);
    
    // thread issue
    NSMutableArray *holdResObjectArray = [NSMutableArray arrayWithArray:_resObjectsArray];
    DLog(@"[Style Manager] all res object count:%ld",(long)holdResObjectArray.count);
    
    // change style
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        [holdResObjectArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj respondsToSelector:@selector(didChangeStyleWithManager:)])
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [obj didChangeStyleWithManager:self];
                });
            } else {
                DLog(@"[Style Manager]  change style failed ! => %@",obj);
            }
            __block double progress = (double)(idx+1) / (double)(holdResObjectArray.count);
            for(ResStyleProgressBlock progressBlock in self.styleChangedHandlers)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    progressBlock(progress);
                });
                
            }
        }];
        _isLoading = NO;
        
        // save
        dispatch_sync(dispatch_get_main_queue(), ^{
            // save
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_styleName];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:kNowResStyle];
            // block
            if (block) {
                block(YES,nil);
            }
        });
        DLog(@"[Style Manager] end change style");
    });
    
    while (!_isLoading) {
        return;
    }
    
}
- (BOOL)containsStyle:(NSString *)name
{
    if ([self p_styleTypeIndexByName:name] != NSNotFound) {
        return YES;
    }
    return NO;
}
- (void)changeStyleOnProgress:(ResStyleProgressBlock)progressBlock
{
    ResStyleProgressBlock tempBlock = [progressBlock copy];
    [self.styleChangedHandlers addObject:tempBlock];
}

- (BOOL)deleteStyle:(NSString *)name
{
    NSUInteger index = [self p_styleTypeIndexByName:name];
    // default style ,can not delete
    if (index < self.defaultStyleArray.count
        || index == NSNotFound)
    {
        return NO;
    }
    
    NSDictionary *styleDict = (self.allStyleArray)[index];
    NSString *bundleName = [(NSString *)styleDict[kStyleURL]
                            substringFromIndex:PK_CUSTOM_BUNDLE_PREFIX.length];
    BOOL isDir=NO;
    NSError *error = nil;
    NSString *stylePath = [[self p_getSavedDirectoryWithSubDir:nil]
                           stringByAppendingFormat:@"/%@",bundleName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:stylePath isDirectory:&isDir] && isDir)
    {
        DLog(@"[Style Manager]  No such file or directory");
        return NO;
    }
    if (![fileManager removeItemAtPath:stylePath error:&error])
    {
        DLog(@"[Style Manager]  delete file error:%@",error);
        return NO;
    }
    
    [_allStyleArray removeObjectAtIndex:index];
    
    [self p_saveCustomStyleArray];
    
    DLog(@"[Style Manager]  %@",self.allStyleArray);
    
    // need reset
    if ([_styleName isEqualToString:name]) {
        [self resetStyle];
    }
    
    return YES;
}

- (BOOL)saveStyle:(NSString *)styleId name:(NSString *)name version:(NSNumber *)version withBundle:(NSBundle *)bundle
{
    if (styleId.length <= 0 || name.length <= 0 || version.integerValue < 0 || !bundle) {
        return NO;
    }
    NSString *bundlePath = bundle.resourcePath;
    NSArray *elementArray = [bundlePath componentsSeparatedByString:@"/"];
    NSString *bundleName = [elementArray lastObject];
    if (bundleName != nil)
    {
        NSUInteger index = [self p_styleTypeIndexByName:name];
        NSDictionary *styleDict = @{kStyleID : styleId,
                                    kStyleName : name,
                                    kStyleURL : [NSString stringWithFormat:@"%@%@/%@",PK_CUSTOM_BUNDLE_PREFIX,PK_STYLE_SAVED_DIR,bundleName],
                                    kStyleVersion : kStyleVersion};
        
        // if exists ,replace
        if (index != NSNotFound)
        {
            _allStyleArray[index] = styleDict;
        }
        else
        {
            [_allStyleArray addObject:styleDict];
        }
        [self p_saveCustomStyleArray];
        
        // file operation
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *customStylePath = [[self p_getSavedDirectoryWithSubDir:PK_STYLE_SAVED_DIR]
                                     stringByAppendingFormat:@"/%@",bundleName];
        // if exist , overwrite
        if ([fileManager fileExistsAtPath:customStylePath])
        {
            NSError *updateError = nil;
            DLog(@"[Style Manager]  exist <%@> ,will overwrite",name);
            if (![fileManager removeItemAtPath:customStylePath error:&updateError])
            {
                DLog(@"[Style Manager] updateError:%@",updateError);
            }
        }
        if (![fileManager copyItemAtPath:bundlePath toPath:customStylePath error:&error])
        {
            DLog(@"[Style Manager] copy file error :%@",error);
            return NO;
        }
        DLog(@"[Style Manager] saved: %@",self.allStyleArray);
        return YES;
    }
    return NO;
}

- (void)clearImageCache
{
    [_resImageCache removeAllObjects];
    //    [_configCache removeAllObjects];
}
- (void)resetStyle
{
    // swith to default style
    _isLoading = NO;
    NSDictionary *defalutStyleDict = _defaultStyleArray[0];
    NSString *styleName = defalutStyleDict[kStyleName];
    [self swithToStyle:styleName];
}

- (NSBundle *)bundleByStyleName:(NSString *)name
{
    NSInteger index = [self p_styleTypeIndexByName:name];
    if (index == NSNotFound) {
        return nil;
    }
    
    NSDictionary *styleDict = (self.allStyleArray)[index];
    NSString *bundleURL = styleDict[kStyleURL];
    NSString *filePath = nil;
    NSString *bundlePath = nil;
    
    //DLog(@"[Style Manager] bundleURL:%@",bundleURL);
    BOOL changeStyle = NO;
    if ([self.styleName isEqualToString:name])
    {
        changeStyle = YES;
    }
    if ([self p_isBundleURL:bundleURL])
    {
        if (changeStyle)
        {
            _styleType = PKResStyleType_System;
        }
        
        filePath = [[NSBundle mainBundle] bundlePath];
        bundlePath = [NSString stringWithFormat:@"%@/%@",filePath,[bundleURL substringFromIndex:PK_DEFAULT_BUNDLE_PREFIX.length]];
    }
    else if([self p_isCustomBundleURL:bundleURL])
    {
        if (changeStyle)
        {
            _styleType = PKResStyleType_Custom;
        }
        filePath = [self p_getSavedDirectoryWithSubDir:nil];
        bundlePath = [NSString stringWithFormat:@"%@/%@",filePath,[bundleURL substringFromIndex:PK_CUSTOM_BUNDLE_PREFIX.length]];
    }
    else
    {
        DLog(@"[Style Manager] na ni !!! bundleName:%@",bundleURL);
        if (changeStyle)
        {
            _styleType = PKResStyleType_Unknow;
        }
        return nil;
    }
    
    return [NSBundle bundleWithPath:bundlePath];
}

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

- (UIImage *)previewImage
{
    return [self previewImageByStyleName:_styleName];
}
- (UIImage *)previewImageByStyleName:(NSString *)name
{
    UIImage *image = nil;
    NSBundle *bundle = [self bundleByStyleName:name];
    if (bundle!=nil) {
        NSString *imagePath = [bundle pathForResource:PREVIEW_PATH ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    return image;
}

- (NSMutableDictionary *)defaultConfigCache
{
    if (!_defaultConfigCache)
    {
        NSDictionary *defalutStyleDict = _defaultStyleArray[0];
        NSString *defaultStyleName = defalutStyleDict[kStyleName];
        NSBundle *tempBundle = [self bundleByStyleName:defaultStyleName];
        NSString *plistPath=[tempBundle pathForResource:CONFIG_PLIST_PATH ofType:@"plist"];
        _defaultConfigCache = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return _defaultConfigCache;
}

- (NSMutableDictionary *)defaultConfigColorCache {
    if (!_defaultConfigColorCache) {
        NSDictionary *defalutStyleDict = _defaultStyleArray[0];
        NSString *defaultStyleName = defalutStyleDict[kStyleName];
        NSBundle *tempBundle = [self bundleByStyleName:defaultStyleName];
        NSString *plistPath=[tempBundle pathForResource:CONFIG_COLOR_PLIST_PATH ofType:@"plist"];
        _defaultConfigColorCache = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return _defaultConfigColorCache;
}

- (NSMutableDictionary *)defaultConfigFontCache {
    if (!_defaultConfigFontCache) {
        NSDictionary *defalutStyleDict = _defaultStyleArray[0];
        NSString *defaultStyleName = defalutStyleDict[kStyleName];
        NSBundle *tempBundle = [self bundleByStyleName:defaultStyleName];
        NSString *plistPath=[tempBundle pathForResource:CONFIG_FONT_PLIST_PATH ofType:@"plist"];
        _defaultConfigFontCache = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return _defaultConfigFontCache;
}

#pragma mark - Private

- (BOOL)p_isBundleURL:(NSString *)URL
{
    return [URL hasPrefix:PK_DEFAULT_BUNDLE_PREFIX];
}
- (BOOL)p_isCustomBundleURL:(NSString *)URL
{
    return [URL hasPrefix:PK_CUSTOM_BUNDLE_PREFIX];
}
- (void)p_saveCustomStyleArray
{
    self.customStyleArray = [NSMutableArray arrayWithArray:self.allStyleArray];
    NSRange range;
    range.location = 0;
    range.length = self.defaultStyleArray.count;
    [self.customStyleArray removeObjectsInRange:range];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.customStyleArray];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kAllResStyle];
}
- (NSMutableArray*)p_getSavedStyleArray
{
    if (!_defaultStyleArray) {
        NSDictionary *defaultStyleDict = @{kStyleID : PK_SYSTEM_STYLE_ID,
                                           kStyleName : PK_SYSTEM_STYLE_DEFAULT,
                                           kStyleURL : PK_SYSTEM_STYLE_DEFAULT_URL,
                                           kStyleVersion : PK_SYSTEM_STYLE_VERSION};
        
        _defaultStyleArray = [[NSMutableArray alloc] initWithObjects:defaultStyleDict, nil];
    }
    NSMutableArray *retArray = [NSMutableArray arrayWithArray:self.defaultStyleArray];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kAllResStyle];
    NSArray *customStyleArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [retArray addObjectsFromArray:customStyleArray];
    return retArray;
}

- (NSUInteger)p_styleTypeIndexByName:(NSString *)name
{
    __block NSUInteger styleIndex = NSNotFound;
    [_allStyleArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSDictionary *styleDict = (NSDictionary *)obj;
         NSString *styleName = styleDict[kStyleName];
         if ([styleName isEqualToString:name])
         {
             styleIndex = idx;
             return;
         }
     }];
    
    return styleIndex;
}
//
- (NSString *)p_getSavedDirectoryWithSubDir:(NSString *)subDir
{
    NSString *newDirectory = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)[0];
    if (subDir)
    {
        newDirectory = [newDirectory stringByAppendingPathComponent:subDir];
    }
    
    BOOL isDir = NO;
	BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:newDirectory isDirectory:&isDir];
    NSError *error;
	if(!isDir){
		[[NSFileManager defaultManager] removeItemAtPath:newDirectory error:nil];
	}
	if(!isExist || !isDir){
        if(![[NSFileManager defaultManager] createDirectoryAtPath:newDirectory
                                      withIntermediateDirectories:NO attributes:nil error:&error])
        {
            DLog(@"[Style Manager] create file error：%@",error);
        }
	}
    return newDirectory;
}


#pragma mark - Singeton

- (instancetype)init {
    self = [super init];
    if (self) {
        _styleChangedHandlers = [[NSMutableArray alloc] init];
        _resObjectsArray = CreateNonRetainingArray(); // 不retain的数组
        _resImageCache = [[NSMutableDictionary alloc] init];
        _configCache = [[NSMutableDictionary alloc] init];
        
        // get all style ( will get defalut style array)
        _allStyleArray = [self p_getSavedStyleArray];
        
        // read
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kNowResStyle];
        if (nil != data) {
            _isLoading = NO;
            NSString *nowStyleName = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            [self swithToStyle:nowStyleName];
        }else{
            [self resetStyle];
        }
        
    }
    return self;
}

+ (PKResManager*)getInstance{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

@end
