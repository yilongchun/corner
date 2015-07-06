//
//  AppDelegate.h
//  corner
//
//  Created by yons on 15-4-30.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>
//QQ登录
#import "TencentOpenAPI/TencentOAuth.h"
//微博登录
#import "WeiboSDK.h"
//微信登录
#import "WXApi.h"

#import "PreLoginViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,WeiboSDKDelegate,WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) NSString *wbtoken;
@property (strong, nonatomic) NSString *wbCurrentUserID;

@property (strong, nonatomic) UIViewController *viewController;

@end

