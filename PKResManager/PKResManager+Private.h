//
//  PKResManager+Private.h
//  PKResManager
//
//  Created by passerbycrk on 15/4/28.
//
//

#import "PKResManager.h"

@interface PKResManager (Private)

#pragma mark - Private

@property (nonatomic, strong) NSMutableArray *defaultStyleArray;

@property (nonatomic, strong) NSMutableDictionary *resImageCache;

#pragma mark - Plist Default Style

/*!
 * default style_config.plist
 */
@property (nonatomic, strong) NSMutableDictionary *defaultConfigCache;
/*!
 * default style_config_color.plist
 */
@property (nonatomic, strong) NSMutableDictionary *defaultConfigColorCache;
/*!
 * default style_config_font.plist
 */
@property (nonatomic, strong) NSMutableDictionary *defaultConfigFontCache;

#pragma mark - Plist Current Style
/*!
 * style_config.plist
 */
@property (nonatomic, strong) NSMutableDictionary *configCache;
/*!
 * style_config_color.plist
 */
@property (nonatomic, strong) NSMutableDictionary *configColorCache;
/*!
 * style_config_font.plist
 */
@property (nonatomic, strong) NSMutableDictionary *configFontCache;

#pragma mark - Medthod

- (id)getConfigDictByKey:(id)aKey withType:(PKResConfigType)type;

@end
