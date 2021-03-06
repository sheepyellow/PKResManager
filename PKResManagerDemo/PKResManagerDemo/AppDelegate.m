//
//  AppDelegate.m
//  PKResManagerDemo
//
//  Created by passerbycrk on 15/4/29.
//  Copyright (c) 2015年 pcrk. All rights reserved.
//

#import "AppDelegate.h"
#import "PKResManagerKit.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Save Night Style
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"testNight" ofType:@"bundle"]];
    [[PKResManager getInstance] saveStyle:@"pk_style_night_custom"
                                     name:SAVED_NIGHT_STYLE
                                  version:@1.0f
                               withBundle:bundle];
    
    [[PKResManager getInstance] swithToStyle:[PKResManager getInstance].currentStyleName
                                  onComplete:^(BOOL finished, NSError *error) {
                                      if ([[PKResManager getInstance].currentStyleName isEqualToString:PK_SYSTEM_STYLE_DEFAULT_NAME]) {
                                          [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
                                      } else {
                                          [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
                                      }
                                  }];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
