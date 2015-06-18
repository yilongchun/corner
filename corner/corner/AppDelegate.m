//
//  AppDelegate.m
//  corner
//
//  Created by yons on 15-4-30.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "AppDelegate.h"
#import "IQKeyboardManager.h"
#import <AVOSCloud/AVOSCloud.h>
#import "CDUserFactory.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [AVOSCloud setApplicationId: LEANCLOUD_APP_ID clientKey:LEANCLOUD_APP_KEY];
    [CDIMConfig config].userDelegate=[[CDUserFactory alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoginChange)
                                                 name:USER_LOGIN_CHANGE
                                               object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:38/255. green:38/255. blue:38/255. alpha:1]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //设置自动登录
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *isLogin = [ud objectForKey:@"isLogin"];
    BOOL isLoggedIn = [isLogin boolValue];
    
    if (isLoggedIn) {
        
        NSString *userid = [UD objectForKey:USER_ID];
        
        CDIM* im=[CDIM sharedInstance];
        [im openWithClientId:userid callback:^(BOOL succeeded, NSError *error) {
            if(error){
                DLog(@"%@",error);
            }else{
                DLog(@"leancloud 登录成功");
            }
        }];
    }
    
    NSString *storyboardId = isLoggedIn ? @"RootViewController" : @"loginnav";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:storyboardId];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = initViewController;
    [self.window makeKeyAndVisible];
    
    
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

/**
 *  退出登录
 */
-(void)userLoginChange{
    [UD removeObjectForKey:LOGINED_USER];//移除登录用户
    [UD removeObjectForKey:@"isLogin"];//移除登录状态
    [UD removeObjectForKey:USER_ID];//移除用户ID
    [UD removeObjectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,USER_ID]];//移除token
    //退出会话
    [[CDIM sharedInstance] closeWithCallback:^(BOOL succeeded, NSError *error) {
        DLog(@"%@",error);
    }];
    
    NSString *storyboardId = @"loginnav";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:storyboardId];
    self.window.rootViewController = initViewController;
    
}

@end
