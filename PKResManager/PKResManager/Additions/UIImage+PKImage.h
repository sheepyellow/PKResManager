//
//  UIImage+PKImage.h
//  PKResManager
//
//  Created by zhongsheng on 12-11-27.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (PKImage)

/*!
 *   @method
 *   @abstract get image by aKey
 *   @param needCache , will cached
 *   @param name, will not cached
 */
+ (UIImage *)pk_imageForKey:(id)aKey style:(NSString *)name;
+ (UIImage *)pk_imageForKey:(id)aKey cache:(BOOL)needCache;
+ (UIImage *)pk_imageForKey:(id)aKey; // default cached

@end
