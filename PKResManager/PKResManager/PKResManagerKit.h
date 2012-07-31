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
#   define DLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#   define ELog(err) {if(err) DLog(@"%@", err)}
#else
#   define DLog(...)
#   define ELog(err)
#endif


#import "PKResManager.h"

#define BUNDLE_PREFIX    @"bundle://"
#define DOCUMENTS_PREFIX @"documents://"

#define kAllResStyle     @"kAllResStyle"
#define kNowResStyle     @"kNowResStyle"

#define SAVED_STYLE_DIR  @"SavedStyleDir"
#define TEMP_STYLE_DIR   @"TempStyleDir"

#define kStyleID       @"kStyleID"
#define kStyleName     @"kStyleName"
#define kStyleVersion  @"kStyleVersion"
#define kStyleURL      @"kStyleURL"

#define SYSTEM_STYLE_LIGHT      @"light"
#define SYSTEM_STYLE_NIGHT      @"night"
#define SYSTEM_STYLE_LIGHT_URL  @"bundle://skintype_light.bundle"
#define SYSTEM_STYLE_NIGHT_URL  @"bundle://skintype_night.bundle"

#define SYSTEM_STYLE_ID         @""
#define SYSTEM_STYLE_VERSION    @"999.0"

#define COLOR_AND_FONT    @"/#config/color_font"
#define PREVIEW_PATH      @"/#config/preview"

// error
#define PK_ERROR_DOMAIN   @"PK_ERROR_DOMAIN"
#define PK_ERROR_UNKNOW   
#define PK_ERROR_

#endif