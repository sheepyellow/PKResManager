//
//  PKResManager.m
//  TestResManager
//
//  Created by passerbycrk on 12-7-13.
//  Copyright (c) 2012年 . All rights reserved.
//

#import "PKResManager.h"
#import "PKResManager+Private.h"
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
@property (nonatomic, strong) NSMutableArray *resObserverArray;
@property (nonatomic, strong) NSMutableArray *customStyleArray;
@property (nonatomic,   copy) ResStyleProgressBlock changeStyleProgressBlock;

@property (nonatomic, readwrite, strong) NSBundle *currentStyleBundle;
@property (nonatomic, readwrite, strong) NSString *currentStyleName;
@property (nonatomic, readwrite, assign) PKResStyleType currentStyleType;
@property (nonatomic, readwrite, assign) BOOL isLoading;
@property (nonatomic, readwrite, strong) NSMutableArray *allStyleArray;
@end

@implementation PKResManager

- (void)dealloc
{
    [self.styleChangedHandlers removeAllObjects];
    if (self.allStyleArray.count > 0) {
        [self.allStyleArray removeAllObjects];
        self.allStyleArray= nil;
    }
}

- (void)addChangeStyleObserver:(id<PKResChangeStyleDelegate>)object
{
    if (![self.resObserverArray containsObject:object])
    {
        @synchronized(self.resObserverArray)
        {
            [self.resObserverArray addObject:object];
            if ([object respondsToSelector:@selector(didChangeStyleWithManager:)]) {
                if ([NSThread isMainThread]) {
                    [object didChangeStyleWithManager:self];
                } else {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [object didChangeStyleWithManager:self];
                    });
                }
            }
        }
    }
}

- (void)removeChangeStyleObserver:(id<PKResChangeStyleDelegate>)object
{
    if ([self.resObserverArray containsObject:object])
    {
        @synchronized(self.resObserverArray)
        {
            [self.resObserverArray removeObject:object];
        }
    }
}
- (void)swithToStyle:(NSString *)name
{
    [self swithToStyle:name onComplete:nil];
}
- (void)swithToStyle:(NSString *)name onComplete:(ResStyleCompleteBlock)block
{
    if ([self.currentStyleName isEqualToString:name]
        || name == nil )
    {
        if (block) {
            NSError *error = [NSError errorWithDomain:PK_STYLE_ERROR_DOMAIN code:PKStyleErrorCode_Unavailable userInfo:nil];
            block(YES,error);
        }
        return;
    }
    else if (self.isLoading) {
        if (block) {
            block(NO,nil);
        }
        return;
    }
    DLog(@"[Style Manager] start change style");
    self.isLoading = YES;

    self.currentStyleName = [name copy];
    
    // read resource bundle
    self.currentStyleBundle = [self bundleByStyleName:name];
    if (self.currentStyleBundle == nil) {
        if (block) {
            NSError *error = [NSError errorWithDomain:PK_STYLE_ERROR_DOMAIN code:PKStyleErrorCode_BundleName userInfo:nil];
            block(YES,error);
        }
        self.isLoading = NO;
        return;
    }
    
    // remove cache
    [self.resImageCache removeAllObjects];
    [self.configCache removeAllObjects];
    
    // get plist dict
    NSString *plistPath=[self.currentStyleBundle pathForResource:CONFIG_PLIST_PATH ofType:@"plist"];
    self.configCache = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    DLog(@"[Style Manager] configCacheCount:%ld",(long)self.configCache.count);
    
    NSString *colorPlistPath = [self.currentStyleBundle pathForResource:CONFIG_COLOR_PLIST_PATH ofType:@"plist"];
    self.configColorCache = [NSMutableDictionary dictionaryWithContentsOfFile:colorPlistPath];
    DLog(@"[Style Manager] configColorCacheCount:%ld",(long)self.configColorCache.count);
    
    NSString *fontPlistPath = [self.currentStyleBundle pathForResource:CONFIG_FONT_PLIST_PATH ofType:@"plist"];
    self.configFontCache = [NSMutableDictionary dictionaryWithContentsOfFile:fontPlistPath];
    DLog(@"[Style Manager] configFontCacheCount:%ld",(long)self.configFontCache.count);
    @synchronized(self.resObserverArray) {
        NSArray *theOberverArray = [NSArray arrayWithArray:self.resObserverArray];
        DLog(@"[Style Manager] all res object count:%ld",(long)theOberverArray.count);
        // change style
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            NSInteger idx = 0;
            for (id obj in theOberverArray) {
                if ([obj respondsToSelector:@selector(didChangeStyleWithManager:)])
                {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [obj didChangeStyleWithManager:self];
                    });
                } else {
                    DLog(@"[Style Manager]  change style failed ! => %@",obj);
                }
                __block double progress = (double)(idx+1) / (double)(theOberverArray.count);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (self.changeStyleProgressBlock) {
                        self.changeStyleProgressBlock(progress);
                    }
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:PKResManagerChangeStyleProgressUpdateNotification
                     object:self
                     userInfo:@{PKResManagerChangeStyleProgressUpdateNotificationProgressKey : @(progress)}];
                });
                ++idx;
            }
            self.isLoading = NO;
            
            // save
            dispatch_sync(dispatch_get_main_queue(), ^{
                // save
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.currentStyleName];
                [[NSUserDefaults standardUserDefaults] setObject:data forKey:kNowResStyle];
                // block
                if (block) {
                    block(YES,nil);
                }
            });
            DLog(@"[Style Manager] end change style");
        });
    }
    while (!self.isLoading) {
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
    self.changeStyleProgressBlock = progressBlock;
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
    
    NSDictionary *styleDict = self.allStyleArray[index];
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
    
    [self.allStyleArray removeObjectAtIndex:index];
    
    [self p_saveCustomStyleArray];
    
    DLog(@"[Style Manager]  %@",self.allStyleArray);
    
    // need reset
    if ([self.currentStyleName isEqualToString:name]) {
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
            self.allStyleArray[index] = styleDict;
        }
        else
        {
            [self.allStyleArray addObject:styleDict];
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
    [self.resImageCache removeAllObjects];
}
- (void)resetStyle
{
    // swith to default style
    NSDictionary *defalutStyleDict = self.defaultStyleArray[0];
    NSString *styleName = defalutStyleDict[kStyleName];
    [self swithToStyle:styleName];
}

- (NSMutableArray *)defaultStyleName {
    NSDictionary *defalutStyleDict = self.defaultStyleArray[0];
    return defalutStyleDict[kStyleName];
}

- (NSBundle *)bundleByStyleName:(NSString *)name
{
    NSInteger index = [self p_styleTypeIndexByName:name];
    if (index == NSNotFound) {
        return nil;
    }
    
    NSDictionary *styleDict = self.allStyleArray[index];
    NSString *bundleURL = styleDict[kStyleURL];
    NSString *filePath = nil;
    NSString *bundlePath = nil;
    
    //DLog(@"[Style Manager] bundleURL:%@",bundleURL);
    BOOL changeStyle = NO;
    if ([self.currentStyleName isEqualToString:name])
    {
        changeStyle = YES;
    }
    if ([self p_isBundleURL:bundleURL])
    {
        if (changeStyle)
        {
            self.currentStyleType = PKResStyleType_System;
        }
        
        filePath = [[NSBundle mainBundle] bundlePath];
        bundlePath = [NSString stringWithFormat:@"%@/%@",filePath,[bundleURL substringFromIndex:PK_DEFAULT_BUNDLE_PREFIX.length]];
    }
    else if([self p_isCustomBundleURL:bundleURL])
    {
        if (changeStyle)
        {
            self.currentStyleType = PKResStyleType_Custom;
        }
        filePath = [self p_getSavedDirectoryWithSubDir:nil];
        bundlePath = [NSString stringWithFormat:@"%@/%@",filePath,[bundleURL substringFromIndex:PK_CUSTOM_BUNDLE_PREFIX.length]];
    }
    else
    {
        DLog(@"[Style Manager] na ni !!! bundleName:%@",bundleURL);
        if (changeStyle)
        {
            self.currentStyleType = PKResStyleType_Unknow;
        }
        return nil;
    }
    
    return [NSBundle bundleWithPath:bundlePath];
}

- (UIImage *)previewImage
{
    return [self previewImageByStyleName:self.currentStyleName];
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
    if (range.length > 0) {
        [self.customStyleArray removeObjectsInRange:range];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.customStyleArray];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kAllResStyle];
    }
}
- (NSMutableArray*)p_getSavedStyleArray
{
    NSMutableArray *retArray = [NSMutableArray arrayWithArray:self.defaultStyleArray];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kAllResStyle];
    if (data) {
        NSArray *customStyleArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [retArray addObjectsFromArray:customStyleArray];
    }
    return retArray;
}

- (NSUInteger)p_styleTypeIndexByName:(NSString *)name
{
    __block NSUInteger styleIndex = NSNotFound;
    [self.allStyleArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
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
        self.styleChangedHandlers = [[NSMutableArray alloc] init];
        self.resObserverArray = CreateNonRetainingArray(); // 不retain的数组
        self.resImageCache = [[NSMutableDictionary alloc] init];
        self.configCache = [[NSMutableDictionary alloc] init];
        
        // get all style ( will get defalut style array)
        self.allStyleArray = [self p_getSavedStyleArray];
        
        // read
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kNowResStyle];
        if (nil != data) {
            self.isLoading = NO;
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

NSString* const PKResManagerChangeStyleProgressUpdateNotification = @"PKResManagerChangeStyleProgressUpdateNotification";
NSString* const PKResManagerChangeStyleProgressUpdateNotificationProgressKey = @"PKResManagerChangeStyleProgressUpdateNotificationProgressKey";

