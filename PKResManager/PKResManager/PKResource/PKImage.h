//
//  PKImage.h
//  PKResManager
//
//  Created by zhongsheng on 13-2-26.
//
//

#import <UIKit/UIKit.h>

@interface PKImage : UIImage
@property (readonly) id pkKey;
@property (readonly) NSString *pkPath;
@property (readonly) NSString *pkStyleName;
@property (readonly) BOOL pkNeedCache;

+ (PKImage *)imageWithContentsOfFile:(NSString *)path;

/*!
 *   @method
 *   @abstract get image by key
 *   @param needCache , will cached
 *   @param name, will not cached
 */
+ (UIImage *)imageForKey:(id)key style:(NSString *)name;
+ (UIImage *)imageForKey:(id)key cache:(BOOL)needCache;
+ (UIImage *)imageForKey:(id)key; // default cached

@end
