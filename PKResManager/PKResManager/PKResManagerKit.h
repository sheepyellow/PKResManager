//
//  PKResManager.h
//  TestResManager
//
//  Created by zhong sheng on 12-7-16.
//  Copyright (c) 2012年 . All rights reserved.
//

#ifndef PKResManagerKit_PKResManagerKit_h
#define PKResManagerKit_PKResManagerKit_h

#ifndef __IPHONE_4_0
#error "PKResManager uses features only available in iOS SDK 4.0 and later."
#endif

#ifdef DEBUG
    //#define DLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
    #define DLog(fmt, ...) {NSLog(fmt, ##__VA_ARGS__);}
#else
    #define DLog(...)
#endif

#import "PKResManager.h"
#import "UIImage+PKImage.h"
#import "UIColor+PKColor.h"
#import "UIFont+PKFont.h"

#define PK_DEFAULT_BUNDLE_PREFIX    @"bundle://"
#define PK_CUSTOM_BUNDLE_PREFIX @"custom_bundle://"

#define kAllResStyle     @"kAllResStyle"
#define kNowResStyle     @"kNowResStyle"

#define PK_STYLE_SAVED_DIR  @"com.pk.res.style"
#define PK_STYLE_TEMP_DIR   @"com.pk.res.style.tmp"

#define kStyleID       @"kStyleID"
#define kStyleName     @"kStyleName"
#define kStyleVersion  @"kStyleVersion"
#define kStyleURL      @"kStyleURL"

#define PK_SYSTEM_STYLE_DEFAULT      @"PK_SYSTEM_STYLE_DEFAULT"
#define PK_SYSTEM_STYLE_DEFAULT_URL  @"bundle://PKStyleDefault.bundle"

#define PK_SYSTEM_STYLE_ID         @"1"
#define PK_SYSTEM_STYLE_VERSION    @"1"

#define CONFIG_PLIST_PATH           @"/#config/style_config"
#define CONFIG_COLOR_PLIST_PATH     @"/#config/style_config_color"
#define CONFIG_FONT_PLIST_PATH      @"/#config/style_config_font"
#define PREVIEW_PATH                @"/#config/preview"

// error
#define PK_STYLE_ERROR_DOMAIN   @"PK_STYLE_ERROR_DOMAIN"

// config separate key
#define PK_CONFIG_SEPARATE_KEY  @"-"

// config key
#define kPKConfigFontName           @"font"
#define kPKConfigFontSize           @"size"

#endif