//
//  PKResManager.h
//  TestResManager
//
//  Created by zhong sheng on 12-7-13.
//  Copyright (c) 2012年 . All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	PKErrorCodeSuccess						= 0, // 自定义,表示成功.
	PKErrorCodeUnknow                       = 1, // 未知错误
	PKErrorCodeUnavailable	        		= 2, // 不可用，需要下载
    PKErrorCodeBundleName                   = 3, // bundleName问题
} PKErrorCode;


typedef void (^ResStyleProgressBlock) (double progress);
typedef void (^ResStyleCompleteBlock) (BOOL finished, NSError *error);

typedef enum {
    ResStyleType_System,
    ResStyleType_Custom,
    ResStyleType_Unknow
}ResStyleType;


@protocol PKResChangeStyleDelegate <NSObject>
@optional
- (void)changeStyle:(id)sender;
@end

@interface PKResManager : NSObject

@property (nonatomic, readonly) NSBundle *styleBundle;
@property (nonatomic, readonly) NSMutableDictionary *defaultResOtherCache;
@property (nonatomic, retain) NSMutableDictionary *resImageCache;
@property (nonatomic, retain) NSMutableDictionary *resOtherCache;

/*!
 * All style Dict Array
 */
@property (nonatomic, readonly) NSMutableArray *allStyleArray;
/*!
 * Current style name
 */
@property (nonatomic, readonly) NSString *styleName;
/*!
 * Current style type
 */
@property (nonatomic, readonly) ResStyleType styleType;
/*!
 * is loading?
 */
@property (nonatomic, readonly) BOOL isLoading;

// Add style Object
- (void)addChangeStyleObject:(id)object;
// Object dealloc invoke this method!!!
- (void)removeChangeStyleObject:(id)object;
/*!
 * Switch to style by name
 * @discuss You should not swith to a new style until completed
 */
- (void)swithToStyle:(NSString *)name; // not safety
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
/*!
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

- (NSBundle *)bundleByStyleName:(NSString *)name;

- (UIImage *)previewImage;
- (UIImage *)previewImageByStyleName:(NSString *)name;

+ (PKResManager*)getInstance;

@end
