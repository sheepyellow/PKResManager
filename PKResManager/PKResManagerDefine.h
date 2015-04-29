//
//  PKResManagerDefine.h
//  PKResManagerDemo
//
//  Created by dabing on 15/4/29.
//  Copyright (c) 2015年 pcrk. All rights reserved.
//

#ifndef PKResManagerDemo_PKResManagerDefine_h
#define PKResManagerDemo_PKResManagerDefine_h

#ifdef DEBUG
#define DLog(fmt, ...) {NSLog(fmt, ##__VA_ARGS__);}
#else
#define DLog(...)
#endif

// config separate key
#define PK_CONFIG_SEPARATE_KEY  @"-"

// save dir path
#define PK_STYLE_SAVED_DIR  @"com.pk.res.style"
#define PK_STYLE_TEMP_DIR   @"com.pk.res.style.tmp"

// config plist path
#define CONFIG_PLIST_PATH           @"/#config/style_config"
#define CONFIG_COLOR_PLIST_PATH     @"/#config/style_config_color"
#define CONFIG_FONT_PLIST_PATH      @"/#config/style_config_font"
#define PREVIEW_PATH                @"/#config/preview"

// default style value
#define PK_SYSTEM_STYLE_DEFAULT_NAME      @"PK_SYSTEM_STYLE_DEFAULT"
#define PK_SYSTEM_STYLE_DEFAULT_URL  @"bundle://PKStyleDefault.bundle"
#define PK_SYSTEM_STYLE_DEFAULT_ID         @"1"
#define PK_SYSTEM_STYLE_DEFAULT_VERSION    @"1"

// style key
#define kStyleID       @"kStyleID"
#define kStyleName     @"kStyleName"
#define kStyleVersion  @"kStyleVersion"
#define kStyleURL      @"kStyleURL"

// config key
#define kPKConfigFontName           @"font"
#define kPKConfigFontSize           @"size"

#endif
