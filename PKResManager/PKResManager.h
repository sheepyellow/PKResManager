//
//  PKResManager.h
//  TestResManager
//
//  Created by passerbycrk on 12-7-13.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <UIKit/UIKit.h>

// progress update notification
extern NSString* const PKResManagerChangeStyleProgressUpdateNotification;
extern NSString* const PKResManagerChangeStyleProgressUpdateNotificationProgressKey;


typedef NS_ENUM(NSUInteger, PKStyleErrorCode) {
    PKStyleErrorCode_Success                 = 0,
    PKStyleErrorCode_Unknow                  = 1,
    PKStyleErrorCode_Unavailable	         = 2,
    PKStyleErrorCode_BundleName              = 3,
};

typedef NS_ENUM(NSUInteger, PKResStyleType) {
    PKResStyleType_System,
    PKResStyleType_Custom,
    PKResStyleType_Unknow
};

typedef NS_ENUM(NSUInteger, PKResConfigType) {
    PKResConfigType_Default,
    PKResConfigType_Color,
    PKResConfigType_Font
};


typedef void (^ResStyleProgressBlock) (double progress);
typedef void (^ResStyleCompleteBlock) (BOOL finished, NSError *error);

@class PKResManager;

@protocol PKResChangeStyleDelegate <NSObject>
@optional
- (void)didChangeStyleWithManager:(PKResManager *)manager;
@end

@interface PKResManager : NSObject

/*!
 * current style bundle
 */
@property (nonatomic, readonly) NSBundle *currentStyleBundle;
/*!
 * current style name
 */
@property (nonatomic, readonly) NSString *currentStyleName;
/*!
 * default style name
 */
@property (nonatomic, readonly) NSString *defaultStyleName;
/*!
 * Current style type
 */
@property (nonatomic, readonly) PKResStyleType currentStyleType;
/*!
 * is loading?
 */
@property (nonatomic, readonly) BOOL isLoading;
/*!
 * all style Dict Array
 */
@property (nonatomic, readonly) NSMutableArray *allStyleArray;

// Add style Object
- (void)addChangeStyleObserver:(id<PKResChangeStyleDelegate>)object;
// Object dealloc invoke this method!!!
- (void)removeChangeStyleObserver:(id<PKResChangeStyleDelegate>)object;
/*!
 * Switch to style by name
 * @discuss You should not swith to a new style until completed
 */
- (void)swithToStyle:(NSString *)name;
- (void)swithToStyle:(NSString *)name onComplete:(ResStyleCompleteBlock)block; 
/*!
 * containsStyle
 */
- (BOOL)containsStyle:(NSString *)name;
/*!
 * get change progress
 */
- (void)changeStyleOnProgress:(ResStyleProgressBlock)progressBlock;

/*!
 * save in custom file path
 */
- (BOOL)saveStyle:(NSString *)styleId name:(NSString *)name version:(NSNumber *)version withBundle:(NSBundle *)bundle;
/*!ne
 * delete style
 */
- (BOOL)deleteStyle:(NSString *)name;

/*!
 * clear image cache
 */
- (void)clearImageCache;
/*!
 * reset
 */
- (void)resetStyle;
/*!
 * get bundle by name
 */
- (NSBundle *)bundleByStyleName:(NSString *)name;
/*!
 * preview
 */
- (UIImage *)previewImage;
- (UIImage *)previewImageByStyleName:(NSString *)name;
/*!
 * Singlton
 */
+ (PKResManager*)getInstance;

@end
