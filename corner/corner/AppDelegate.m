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
#import "Pingpp.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //向微信注册
    
    [WXApi registerApp:kWeixinAppId];
    
    //微博登录
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:kWeiboAppKay];
    //聊天
    [AVOSCloud setApplicationId: LEANCLOUD_APP_ID clientKey:LEANCLOUD_APP_KEY];
    [AVOSCloud setAllLogsEnabled:YES];
    
    [CDIMConfig config].userDelegate=[[CDUserFactory alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userLoginChange)
                                                 name:USER_LOGIN_CHANGE
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendAuthRequest:)
                                                 name:@"weixin_login"
                                               object:nil];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:38/255. green:38/255. blue:38/255. alpha:1]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    }
    
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
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
    self.viewController = [storyboard instantiateViewControllerWithIdentifier:storyboardId];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.viewController;
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
    //退出聊天
    [[CDIM sharedInstance] closeWithCallback:^(BOOL succeeded, NSError *error) {
        DLog(@"%@",error);
    }];
    
    NSString *storyboardId = @"loginnav";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:storyboardId];
    self.window.rootViewController = initViewController;
    
}

#pragma mark - 微信登录

//授权后回调 WXApiDelegate


-(void) onReq:(BaseReq*)req{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
        GetMessageFromWXReq *temp = (GetMessageFromWXReq *)req;
        
        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
        NSString *strMsg = [NSString stringWithFormat:@"openID: %@", temp.openID];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        alert.tag = 1000;
        [alert show];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
        WXMediaMessage *msg = temp.message;
        
        //显示微信传过来的内容
        WXAppExtendObject *obj = msg.mediaObject;
        
        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
        NSString *strMsg = [NSString stringWithFormat:@"openID: %@, 标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%lu bytes\n附加消息:%@\n", temp.openID, msg.title, msg.description, obj.extInfo, (unsigned long)msg.thumbData.length, msg.messageExt];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
        LaunchFromWXReq *temp = (LaunchFromWXReq *)req;
        WXMediaMessage *msg = temp.message;
        
        //从微信启动App
        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
        NSString *strMsg = [NSString stringWithFormat:@"openID: %@, messageExt:%@", temp.openID, msg.messageExt];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void) onResp:(BaseResp*)resp{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
        NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if([resp isKindOfClass:[SendAuthResp class]])
    {
        SendAuthResp *temp = (SendAuthResp*)resp;
        
        switch (temp.errCode) {
            case 0:
            {
                NSString *code = temp.code;
                [self getAccess_token:code];
                
                
            }
                break;
            case -4:
                
                break;
            case 2:
                
                break;
            default:
                break;
        }
        
        
        
//        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
//        NSString *strMsg = [NSString stringWithFormat:@"code:%@,state:%@,errcode:%d", temp.code, temp.state, temp.errCode];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
    }
    else if ([resp isKindOfClass:[AddCardToWXCardPackageResp class]])
    {
        AddCardToWXCardPackageResp* temp = (AddCardToWXCardPackageResp*)resp;
        NSMutableString* cardStr = [[NSMutableString alloc] init];
        for (WXCardItem* cardItem in temp.cardAry) {
            [cardStr appendString:[NSString stringWithFormat:@"cardid:%@ cardext:%@ cardstate:%u\n",cardItem.cardId,cardItem.extMsg,(unsigned int)cardItem.cardState]];
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"add card resp" message:cardStr delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)getAccess_token:(NSString *)wxCode
{
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWeixinAppId,kWeixinAppSecret,wxCode];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                
                [self checkAccessToken:dic];
//                NSString *access_token = [dic objectForKey:@"access_token"];
//                NSString *openid = [dic objectForKey:@"openid"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:WEIXIN_LOGIN_SUCCESSED object:nil userInfo:dic];
            }
        });
    });
}
//校验token是否有效
-(void)checkAccessToken:(NSDictionary *)tokeninfo{
    NSString *access_token = [tokeninfo objectForKey:@"access_token"];
    NSString *openid = [tokeninfo objectForKey:@"openid"];
    NSString *refresh_token = [tokeninfo objectForKey:@"refresh_token"];
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/auth?access_token=%@&openid=%@",access_token,openid];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                DLog(@"%@",dic);
                if ([[dic objectForKey:@"errcode"] intValue] == 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:WEIXIN_LOGIN_SUCCESSED object:nil userInfo:tokeninfo];
                }else{
                    [self refreshToken:refresh_token];
                }
                
                //                NSString *access_token = [dic objectForKey:@"access_token"];
                //                NSString *openid = [dic objectForKey:@"openid"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:WEIXIN_LOGIN_SUCCESSED object:nil userInfo:dic];
            }
        });
    });
}
//刷新token
-(void)refreshToken:(NSString *)refreshToken{
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%@&grant_type=refresh_token&refresh_token=%@",kWeixinAppId,refreshToken];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                DLog(@"%@",dic);
                if ([[dic objectForKey:@"errcode"] intValue] == 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:WEIXIN_LOGIN_SUCCESSED object:nil userInfo:dic];
                }
                
                //                NSString *access_token = [dic objectForKey:@"access_token"];
                //                NSString *openid = [dic objectForKey:@"openid"];
                //                [[NSNotificationCenter defaultCenter] postNotificationName:WEIXIN_LOGIN_SUCCESSED object:nil userInfo:dic];
            }
        });
    });
}



- (void)sendAuthRequest:(NSNotification *)noti
{
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact"; // @"post_timeline,sns"
//    req.state = @"xxx";
//    req.openID = @"0c806938e2413ce73eef92cc3";
    
    UIViewController *vc = [noti.userInfo objectForKey:@"viewcontroller"];
    
    [WXApi sendAuthReq:req viewController:vc delegate:self];
}

#pragma mark - QQ登录 微博登录 微信登录
//QQ登录
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    [Pingpp handleOpenURL:url withCompletion:^(NSString *result, PingppError *error) {
        NSLog(@"result = %@, error : %@", result, error == nil ? @"nil" : [error getMsg]);
        
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:result,@"result", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"paySuccess" object:nil userInfo:dic];
        });
        
    }];
    
    return [TencentOAuth HandleOpenURL:url] || [WeiboSDK handleOpenURL:url delegate:self] || [WXApi handleOpenURL:url delegate:self];
    
    
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [TencentOAuth HandleOpenURL:url] || [WeiboSDK handleOpenURL:url delegate:self] || [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - 微博登录 代理

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *title = NSLocalizedString(@"发送结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode, NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil),response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        WBSendMessageToWeiboResponse* sendMessageToWeiboResponse = (WBSendMessageToWeiboResponse*)response;
        NSString* accessToken = [sendMessageToWeiboResponse.authResponse accessToken];
        if (accessToken)
        {
            self.wbtoken = accessToken;
        }
        NSString* userID = [sendMessageToWeiboResponse.authResponse userID];
        if (userID) {
            self.wbCurrentUserID = userID;
        }
        DLog(@"%@\t%@",accessToken,userID);
        [alert show];
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
//        NSString *title = NSLocalizedString(@"认证结果", nil);
//        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.userId: %@\nresponse.accessToken: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken],  NSLocalizedString(@"响应UserInfo数据", nil), response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
//                                              otherButtonTitles:nil];
//        
//        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
//        self.wbCurrentUserID = [(WBAuthorizeResponse *)response userID];
//        [alert show];
        if ((int)response.statusCode == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:WEIBO_LOGIN_SUCCESSED object:nil userInfo:response.userInfo];
        }else{
            
        }
        
    }
    else if ([response isKindOfClass:WBPaymentResponse.class])
    {
        NSString *title = NSLocalizedString(@"支付结果", nil);
        NSString *message = [NSString stringWithFormat:@"%@: %d\nresponse.payStatusCode: %@\nresponse.payStatusMessage: %@\n%@: %@\n%@: %@", NSLocalizedString(@"响应状态", nil), (int)response.statusCode,[(WBPaymentResponse *)response payStatusCode], [(WBPaymentResponse *)response payStatusMessage], NSLocalizedString(@"响应UserInfo数据", nil),response.userInfo, NSLocalizedString(@"原请求UserInfo数据", nil), response.requestUserInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
