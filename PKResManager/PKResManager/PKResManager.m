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
    return (NSMutableArray*)CFArrayCreateMutable(nil, 0, &callbacks);
}

static PKResManager *_instance = nil;

@interface PKResManager (/*private*/)
@property (nonatomic, retain) NSMutableArray *styleChangedHandlers; // delegates
@property (nonatomic, retain) NSBundle *styleBundle;                
@property (nonatomic, retain) NSMutableArray *resObjectsArray;      
@property (nonatomic, retain) NSMutableDictionary *resImageCache;
@property (nonatomic, retain) NSMutableDictionary *resOtherCache;
@property (nonatomic, retain) NSMutableArray *defaultStyleArray;
@property (nonatomic, retain) NSMutableArray *customStyleArray;

- (NSString *)getDocumentsDirectoryWithSubDir:(NSString *)subDir;
- (BOOL)isBundleURL:(NSString *)URL;
- (BOOL)isDocumentsURL:(NSString *)URL;
- (NSUInteger)styleTypeIndexByName:(NSString *)name;
- (void)saveCustomStyleArray;
- (NSMutableArray*)getSavedStyleArray;
- (NSBundle *)bundleByStyleName:(NSString *)name;
@end

@implementation PKResManager

// public
@synthesize 
allStyleArray = _allStyleArray,
styleName = _styleName,
styleType = _styleType,
isLoading = _isLoading;

// private
@synthesize 
styleChangedHandlers = _styleChangedHandlers,
styleBundle = _styleBundle,
resObjectsArray = _resObjectsArray,
resImageCache = _resImageCache,
resOtherCache = _resOtherCache,
defaultStyleArray = _defaultStyleArray,
customStyleArray = _customStyleArray;

- (void)dealloc
{
    if (_styleName) {
        [_styleName release];
    }
    [self.styleChangedHandlers removeAllObjects];
    self.styleChangedHandlers = nil;
    self.styleBundle = nil;
    self.resObjectsArray = nil;
    self.resImageCache = nil;
    self.resOtherCache = nil;
    if (_allStyleArray.count>0) {
        [_allStyleArray removeAllObjects];
        [_allStyleArray release],_allStyleArray= nil;        
    }
    self.defaultStyleArray = nil;
    self.customStyleArray = nil;
    [super dealloc];
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
    [self swithToStyle:name onComplete:^(BOOL finished, NSError *error) {
        return ;
    }];
}
- (void)swithToStyle:(NSString *)name onComplete:(ResStyleCompleteBlock)block
{    
    if ([_styleName isEqualToString:name] 
        || name == nil )
    {
        NSError *error = [NSError errorWithDomain:PK_ERROR_DOMAIN code:PKErrorCodeUnavailable userInfo:nil];
        block(YES,error);
        return;
    }
    else if (_isLoading) {
        block(NO,nil);
        return;
    }
    DLog(@"start change style :%@",[NSDate date]);
    _isLoading = YES;
    block(NO,nil);
    
    if (_styleName) {
        [_styleName release];
    }
    _styleName = [name copy];
    
    // read resource bundle
    self.styleBundle = [self bundleByStyleName:name];
    if (self.styleBundle == nil) {
        NSError *error = [NSError errorWithDomain:PK_ERROR_DOMAIN code:PKErrorCodeBundleName userInfo:nil];
        block(YES,error);
        _isLoading = NO;
        return;
    }

    // remove cache
    [_resImageCache removeAllObjects]; 
    [_resOtherCache removeAllObjects];    

    // get plist dict
    NSString *plistPath=[self.styleBundle pathForResource:COLOR_AND_FONT ofType:@"plist"];    
    self.resOtherCache = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
//    DLog(@"resOtherCache:%@",self.resOtherCache);

    // thread issue
    NSMutableArray *holdResObjectArray = [NSMutableArray arrayWithArray:_resObjectsArray];
    DLog(@"all res object count:%d",holdResObjectArray.count);
    
    // change style
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        [holdResObjectArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj respondsToSelector:@selector(changeStyle:)]) 
            {
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [obj changeStyle:self];                                                                
                });
                
            }
            else 
            {
                DLog(@" change style failed ! => %@",obj);
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
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_styleName];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kNowResStyle];
        
        block(YES,nil);
        DLog(@"end change style :%@",[NSDate date]);
    });

    while (!_isLoading) {        
        return;
    }
    
}
- (BOOL)containsStyle:(NSString *)name
{
    if ([self styleTypeIndexByName:name] != NSNotFound) {
        return YES;
    }
    return NO;
}
- (void)changeStyleOnProgress:(ResStyleProgressBlock)progressBlock
{
    [self.styleChangedHandlers addObject:[progressBlock copy]];
}

- (BOOL)deleteStyle:(NSString *)name
{
    NSUInteger index = [self styleTypeIndexByName:name];
    // default style ,can not delete
    if (index < self.defaultStyleArray.count 
        || index == NSNotFound) 
    {
        return NO;
    }

    NSDictionary *styleDict = [self.allStyleArray objectAtIndex:index];
    NSString *bundleName = [(NSString *)[styleDict objectForKey:kStyleURL]
                            substringFromIndex:DOCUMENTS_PREFIX.length];
    BOOL isDir=NO;
    NSError *error = nil;
    NSString *stylePath = [[self getDocumentsDirectoryWithSubDir:nil]
                           stringByAppendingFormat:@"/%@",bundleName];
    NSFileManager *fileManager = [NSFileManager defaultManager];    
    if (![fileManager fileExistsAtPath:stylePath isDirectory:&isDir] && isDir)
    {
        DLog(@" No such file or directory");
        return NO;
    }
    if (![fileManager removeItemAtPath:stylePath error:&error]) 
    {
        DLog(@" delete file error:%@",error);
        return NO;
    }

    [_allStyleArray removeObjectAtIndex:index];
    
    [self saveCustomStyleArray];
    
    DLog(@" %@",self.allStyleArray);

    // need reset
    if ([_styleName isEqualToString:name]) {
        [self resetStyle];
    }
    
    return YES;    
}

- (BOOL)saveStyle:(NSString *)styleId name:(NSString *)name version:(NSNumber *)version withBundle:(NSBundle *)bundle
{
    NSString *bundlePath = bundle.resourcePath;
    NSArray *elementArray = [bundlePath componentsSeparatedByString:@"/"];
    NSString *bundleName = [elementArray lastObject];
    if (bundleName != nil)
    {
        NSUInteger index = [self styleTypeIndexByName:name];
        NSDictionary *styleDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                       styleId,
                                                                       name,
                                                                       [NSString stringWithFormat:@"%@%@/%@",DOCUMENTS_PREFIX,SAVED_STYLE_DIR,bundleName],
                                                                       version,
                                                                       nil]
                                                              forKeys:[NSArray arrayWithObjects:
                                                                       kStyleID,
                                                                       kStyleName,
                                                                       kStyleURL,
                                                                       kStyleVersion,
                                                                       nil]];
        // if exists ,replace
        if (index != NSNotFound)
        {
            [_allStyleArray replaceObjectAtIndex:index withObject:styleDict];
        }
        else
        {
            [_allStyleArray addObject:styleDict];
        }
        [self saveCustomStyleArray];
        
        // file operation
        NSError *error = nil;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *customStylePath = [[self getDocumentsDirectoryWithSubDir:SAVED_STYLE_DIR]
                                     stringByAppendingFormat:@"/%@",bundleName];
        // if exist , overwrite
        if ([fileManager fileExistsAtPath:customStylePath])
        {
            NSError *updateError = nil;
            DLog(@" exist <%@> ,will overwrite",name);
            if (![fileManager removeItemAtPath:customStylePath error:&updateError])
            {
                DLog(@"updateError:%@",updateError);
            }
        }
        if (![fileManager copyItemAtPath:bundlePath toPath:customStylePath error:&error])
        {
            DLog(@"copy file error :%@",error);
            return NO;
        }
        DLog(@"saved: %@",self.allStyleArray);
        return YES;
    }
    return NO;
}

- (void)clearImageCache
{
    [_resImageCache removeAllObjects];
//    [_resOtherCache removeAllObjects];
}
- (void)resetStyle
{
    // swith to default style
    _isLoading = NO;
    NSDictionary *defalutStyleDict = [_defaultStyleArray objectAtIndex:0];
    NSString *styleName = [defalutStyleDict objectForKey:kStyleName];    
    [self swithToStyle:styleName];
}
- (UIImage *)imageForKey:(id)key style:(NSString *)name
{
    if (key == nil) {
        DLog(@" imageForKey:style: key = nil");
        return nil;
    }
    NSBundle *tempBundle = [self bundleByStyleName:name];
    NSAssert(tempBundle != nil,@" tempBundle = nil");
    
    UIImage *image = nil;
    NSString *imagePath = [tempBundle pathForResource:key ofType:@"png"];
    image = [UIImage imageWithContentsOfFile:imagePath];
    
    if (image == nil) 
    {
        imagePath = [[NSBundle mainBundle] pathForResource:key ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:imagePath];
    }
    return image;
}
- (UIImage *)imageForKey:(id)key cache:(BOOL)needCache
{
    if (key == nil) {
        DLog(@" imageForKey:cache: key = nil");
        return nil;
    }
    UIImage *image = [_resImageCache objectForKey:key];
    
    if (image == nil) 
    {
        NSString *imagePath = [self.styleBundle pathForResource:key ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:imagePath];
        
        if (image == nil) 
        {
            imagePath = [[NSBundle mainBundle] pathForResource:key ofType:@"png"];
            image = [UIImage imageWithContentsOfFile:imagePath];
        }

        //DLog(@"imagePath:%@",imagePath);
    }
    // if error ,get default resource
    if (image == nil) {
        DLog(@" will get default style => %@",key);
        NSBundle *defaultBundle = [self bundleByStyleName:SYSTEM_STYLE_LIGHT];
        NSString *imagePath = [defaultBundle pathForResource:key ofType:@"png"];
        image = [UIImage imageWithContentsOfFile:imagePath];
        NSAssert(image!=nil,@" get default Image error !!!");
    }
    // cache
    if (image != nil && needCache) 
    {
        [_resImageCache setObject:image forKey:key];
    }
    
    return image;
}
- (UIImage *)imageForKey:(id)key
{
    return [self imageForKey:key cache:YES];
}

- (UIFont *)fontForKey:(id)key
{
    NSArray *keyArray = [key componentsSeparatedByString:@"-"];    
    NSAssert(keyArray.count >= 2,@"module key name error!!! ==> font");
    
    NSString *moduleKey = [keyArray objectAtIndex:0];
    NSString *memberKey = [keyArray objectAtIndex:1];
    
    NSDictionary *moduleDict = [self.resOtherCache objectForKey:moduleKey];    
    NSDictionary *memberDict = [moduleDict objectForKey:memberKey];
    
    NSString *fontName = [memberDict objectForKey:@"font"];
    NSNumber *fontSize = [memberDict objectForKey:@"size"];
    UIFont *font = [UIFont fontWithName:fontName 
                                   size:fontSize.floatValue];
    
    return font;    
}

- (UIColor *)colorForKey:(id)key
{  
    NSArray *keyArray = [key componentsSeparatedByString:@"-"];    
    NSAssert(keyArray.count >= 2,@"module key name error!!! ==> color");
    
    NSString *moduleKey = [keyArray objectAtIndex:0];
    NSString *memberKey = [keyArray objectAtIndex:1];
    
    NSDictionary *moduleDict = [self.resOtherCache objectForKey:moduleKey];    
    NSDictionary *memberDict = [moduleDict objectForKey:memberKey];
    
    NSString *colorStr = [memberDict objectForKey:@"rgb"];
    
    NSNumber *redValue;
    NSNumber *greenValue;
    NSNumber *blueValue;
    NSNumber *alphaValue;
    NSArray *colorArray = [colorStr componentsSeparatedByString:@","];
    if (colorArray != nil && colorArray.count == 3) {
        redValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:0] floatValue]];
        greenValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:1] floatValue]];
        blueValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:2] floatValue]];
        alphaValue = [NSNumber numberWithFloat:1.0];
    } else if (colorArray != nil && colorArray.count == 4) {
        redValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:0] floatValue]];
        greenValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:1] floatValue]];
        blueValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:2] floatValue]];
        alphaValue = [NSNumber numberWithFloat:[[colorArray objectAtIndex:3] floatValue]];
    } else {
        return nil;
    }
    
    if ([alphaValue floatValue]<=0.0f) {
        return [UIColor clearColor];
    }
    return [UIColor colorWithRed:[redValue floatValue]/255.0f 
                           green:[greenValue floatValue]/255.0f
                            blue:[blueValue floatValue]/255.0f
                           alpha:[alphaValue floatValue]];
    
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
    // TODO: image == nil
    return image;
}
#pragma mark - Private

- (BOOL)isBundleURL:(NSString *)URL
{
    return [URL hasPrefix:BUNDLE_PREFIX];
}
- (BOOL)isDocumentsURL:(NSString *)URL
{
    return [URL hasPrefix:DOCUMENTS_PREFIX];
}
- (void)saveCustomStyleArray
{
    self.customStyleArray = [NSMutableArray arrayWithArray:self.allStyleArray];
    NSRange range;
    range.location = 0;
    range.length = self.defaultStyleArray.count;
    [self.customStyleArray removeObjectsInRange:range];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.customStyleArray];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kAllResStyle];
}
- (NSMutableArray*)getSavedStyleArray
{
    if (!_defaultStyleArray) {
        NSDictionary *lightDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                       SYSTEM_STYLE_ID,
                                                                       SYSTEM_STYLE_LIGHT,
                                                                       SYSTEM_STYLE_LIGHT_URL,
                                                                       SYSTEM_STYLE_VERSION,
                                                                       nil] 
                                                              forKeys:[NSArray arrayWithObjects:
                                                                       kStyleID,
                                                                       kStyleName,
                                                                       kStyleURL,
                                                                       kStyleVersion,
                                                                       nil]];
        NSDictionary *nightDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                                       SYSTEM_STYLE_ID,
                                                                       SYSTEM_STYLE_NIGHT,
                                                                       SYSTEM_STYLE_NIGHT_URL,
                                                                       SYSTEM_STYLE_VERSION,
                                                                       nil] 
                                                              forKeys:[NSArray arrayWithObjects:
                                                                       kStyleID,
                                                                       kStyleName,
                                                                       kStyleURL,
                                                                       kStyleVersion, nil]];
        _defaultStyleArray = [[NSMutableArray alloc] initWithObjects:lightDict,nightDict, nil];
    }
    NSMutableArray *retArray = [NSMutableArray arrayWithArray:self.defaultStyleArray];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kAllResStyle];
    NSArray *customStyleArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [retArray addObjectsFromArray:customStyleArray];
    return retArray;
}

- (NSUInteger)styleTypeIndexByName:(NSString *)name
{
    __block NSUInteger styleIndex = NSNotFound;
    [_allStyleArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) 
    {
        NSDictionary *styleDict = (NSDictionary *)obj;
        NSString *styleName = [styleDict objectForKey:kStyleName];
        if ([styleName isEqualToString:name]) 
        {
            styleIndex = idx;
            return;
        }
    }];
    
    return styleIndex;
}
// 
- (NSString *)getDocumentsDirectoryWithSubDir:(NSString *)subDir
{
    NSString *newDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) 
                              objectAtIndex:0];
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
            DLog(@"create file error：%@",error);
        }   
	}
    return newDirectory;
}
- (NSBundle *)bundleByStyleName:(NSString *)name
{
    NSInteger index = [self styleTypeIndexByName:name];
    if (index == NSNotFound) {
        return nil;
    }
    
    NSDictionary *styleDict = [self.allStyleArray objectAtIndex:index];
    NSString *bundleURL = [styleDict objectForKey:kStyleURL];
    NSString *filePath = nil;
    NSString *bundlePath = nil;
    
    DLog(@"bundleURL:%@",bundleURL);
    if ([self isBundleURL:bundleURL]) 
    {
        _styleType = ResStyleType_System;
        filePath = [[NSBundle mainBundle] bundlePath];
        bundlePath = [NSString stringWithFormat:@"%@/%@",filePath,[bundleURL substringFromIndex:BUNDLE_PREFIX.length]];
    }
    else if([self isDocumentsURL:bundleURL])
    {
        _styleType = ResStyleType_Custom;
        filePath = [self getDocumentsDirectoryWithSubDir:nil];
        bundlePath = [NSString stringWithFormat:@"%@/%@",filePath,[bundleURL substringFromIndex:DOCUMENTS_PREFIX.length]];
    }
    else 
    {
        DLog(@"na ni !!! bundleName:%@",bundleURL);
        _styleType = ResStyleType_Unknow;        
        return nil;
    }
    
    return [NSBundle bundleWithPath:bundlePath];
}


#pragma mark - Singeton
- (id)init{
    self = [super init];
    if (self) {
        _styleChangedHandlers = [[NSMutableArray alloc] init];
        _resObjectsArray = CreateNonRetainingArray(); // 不retain的数组
        _resImageCache = [[NSMutableDictionary alloc] init];
        _resOtherCache = [[NSMutableDictionary alloc] init];
        
        // get all style ( will get defalut style array)
        _allStyleArray = [[self getSavedStyleArray] retain];
        
        // read
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kNowResStyle];
        if (data!=nil) {
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
    @synchronized(self) { 
		if (_instance == nil) {
            [[self alloc] init];
		}
	}
	return _instance; 
}

+ (id) allocWithZone:(NSZone*) zone {
	@synchronized(self) { 
		if (_instance == nil) {
			_instance = [super allocWithZone:zone];  // assignment and return on first allocation
			return _instance;
		}
	}
	return nil;
}
- (id) copyWithZone:(NSZone*) zone {
	return _instance;
}

- (id) retain {
	return _instance;
}

- (unsigned) retainCount {
	return UINT_MAX;  //denotes an object that cannot be released
}

- (id) autorelease {
	return self;
}
- (oneway void)release
{
    return;
}

@end
