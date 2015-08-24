//
//  LoginViewController.m
//  corner
//
//  Created by yons on 15-5-27.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "PreLoginViewController.h"
#import "NSDictionary+JSONString.h"
#import "IQKeyboardManager.h"
#import "NSString+Valid.h"
@interface PreLoginViewController ()

@end

@implementation PreLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(weiboLoginSuccessed:)
                                                 name:WEIBO_LOGIN_SUCCESSED
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(weixinLoginSuccessed:)
                                                 name:WEIXIN_LOGIN_SUCCESSED
                                               object:nil];
//    if (![WXApi isWXAppInstalled]) {
//        [self.wxBtn setHidden:YES];
//    }
    
    [self.username setValue:RGBACOLOR(230, 230, 230, 1) forKeyPath:@"_placeholderLabel.textColor"];
    [self.password setValue:RGBACOLOR(230, 230, 230, 1) forKeyPath:@"_placeholderLabel.textColor"];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1){
        [self.username setTintColor:RGBACOLOR(230, 230, 230, 1)];
        [self.password setTintColor:RGBACOLOR(230, 230, 230, 1)];
    }
    
    UIImage *loginImg = [[UIImage imageNamed:@"loginBtn"] stretchableImageWithLeftCapWidth:30 topCapHeight:17];
    [self.loginBtn setBackgroundImage:loginImg forState:UIControlStateNormal];
    [self.regBtn setBackgroundImage:loginImg forState:UIControlStateNormal];
    
    
    [self.username setBackground:[[UIImage imageNamed:@"regBg"] stretchableImageWithLeftCapWidth:30 topCapHeight:17]];
    [self.password setBackground:[[UIImage imageNamed:@"regBg"] stretchableImageWithLeftCapWidth:30 topCapHeight:17]];
    
//    UIImage *img = [[UIImage imageNamed:@"star_btn_v1"] stretchableImageWithLeftCapWidth:25 topCapHeight:0];
//    [self.wxBtn setBackgroundImage:img forState:UIControlStateNormal];
//    [self.wbBtn setBackgroundImage:img forState:UIControlStateNormal];
//    [self.qqBtn setBackgroundImage:img forState:UIControlStateNormal];
//    [self.emailOrPhoneBtn setBackgroundImage:img forState:UIControlStateNormal];
//    
//    self.wxBtn.alpha = 0.0;
//    self.wbBtn.alpha = 0.0;
//    self.qqBtn.alpha = 0.0;
//    self.emailOrPhoneBtn.alpha = 0.0;
//    
//    self.wxBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
//    self.wbBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
//    self.qqBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
//    self.emailOrPhoneBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
//    
//    UIViewAnimationOptions options = UIViewAnimationCurveLinear | UIViewKeyframeAnimationOptionAllowUserInteraction;
//    [UIView animateWithDuration:0.2 delay:0.2 options:options animations:^{
//        self.wxBtn.alpha = 1.0;
//        self.wxBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//    } completion:nil];
//    [UIView animateWithDuration:0.3 delay:0.2 options:options animations:^{
//        self.wbBtn.alpha = 1.0;
//        self.wbBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//    } completion:nil];
//    [UIView animateWithDuration:0.4 delay:0.2 options:options animations:^{
//        self.qqBtn.alpha = 1.0;
//        self.qqBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//    } completion:nil];
//    [UIView animateWithDuration:0.5 delay:0.2 options:options animations:^{
//        self.emailOrPhoneBtn.alpha = 1.0;
//        self.emailOrPhoneBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//    } completion:nil];
    
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    //QQ登录
    _permissions = [NSMutableArray arrayWithObjects:
                     kOPEN_PERMISSION_GET_USER_INFO,
                     kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                     kOPEN_PERMISSION_ADD_ALBUM,
                     kOPEN_PERMISSION_ADD_IDOL,
                     kOPEN_PERMISSION_ADD_ONE_BLOG,
                     kOPEN_PERMISSION_ADD_PIC_T,
                     kOPEN_PERMISSION_ADD_SHARE,
                     kOPEN_PERMISSION_ADD_TOPIC,
                     kOPEN_PERMISSION_CHECK_PAGE_FANS,
                     kOPEN_PERMISSION_DEL_IDOL,
                     kOPEN_PERMISSION_DEL_T,
                     kOPEN_PERMISSION_GET_FANSLIST,
                     kOPEN_PERMISSION_GET_IDOLLIST,
                     kOPEN_PERMISSION_GET_INFO,
                     kOPEN_PERMISSION_GET_OTHER_INFO,
                     kOPEN_PERMISSION_GET_REPOST_LIST,
                     kOPEN_PERMISSION_LIST_ALBUM,
                     kOPEN_PERMISSION_UPLOAD_PIC,
                     kOPEN_PERMISSION_GET_VIP_INFO,
                     kOPEN_PERMISSION_GET_VIP_RICH_INFO,
                     kOPEN_PERMISSION_GET_INTIMATE_FRIENDS_WEIBO,
                     kOPEN_PERMISSION_MATCH_NICK_TIPS_WEIBO,
                     nil];
    
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:QQ_APP_ID
                                            andDelegate:self];
}

-(void)viewDidAppear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  第三方登录
 *
 *  @param provider 登录平台
 *  @param uid      uid
 *  @param token    token
 */
- (void)login:(NSString *)provider uid:(NSString *)uid token:(NSString *)token{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:provider forKey:@"provider"];
    [parameters setObject:uid forKey:@"uid"];
    [parameters setObject:token forKey:@"access_token"];
    
    [self showHudInView:self.view hint:@"加载中"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,USER_AUTH_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self hideHud];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                NSDictionary *message = [[dic objectForKey:@"message"] cleanNull];
                if ([message objectForKey:@"single_access_token"] != nil) {
                    //                NSString *perishable_token = [message objectForKey:@"perishable_token"];
                    NSString *single_access_token = [message objectForKey:@"single_access_token"];
                    NSNumber *userid = [message objectForKey:@"id"];
                    [UD setObject:message forKey:LOGINED_USER];
                    [UD setObject:[userid stringValue] forKey:USER_ID];
                    [UD setObject:single_access_token forKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,[userid stringValue]]];
                    [UD setObject:[NSNumber numberWithInt:1] forKey:@"isLogin"];//设置登录
                    CDIM* im=[CDIM sharedInstance];
                    [im openWithClientId:[userid stringValue] callback:^(BOOL succeeded, NSError *error) {
                        if(error){
                            DLog(@"%@",error);
                        }else{
                            DLog(@"leancloud 登录成功 ");
                        }
                    }];
                    [self performSelector:@selector(toMainView) withObject:nil afterDelay:0.5];
                }else{
                    [self showHint:[message JSONString]];
                }
                
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self hideHud];
        [self showHint:@"连接失败"];
        
    }];
}

-(void)toMainView{
    NSString *storyboardId = @"RootViewController";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:storyboardId];
    self.view.window.rootViewController = initViewController;
    
}

#pragma mark - 微信登录

- (IBAction)wxlogin:(id)sender{
    NSDictionary *userinfo = [NSDictionary dictionaryWithObjectsAndKeys:self,@"viewcontroller", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"weixin_login" object:nil userInfo:userinfo];
}

-(void)weixinLoginSuccessed:(NSNotification *)noti{
    DLog(@"weixinLoginSuccessed\n%@",noti.userInfo);
    
    NSString *openId = [noti.userInfo objectForKey:@"openid"];
    NSString *token = [noti.userInfo objectForKey:@"access_token"];
    [self login:@"weixin" uid:openId token:token];
}

#pragma mark - 微博登录

- (IBAction)wblogin:(id)sender{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = kWeiboRedirectUrl;
    request.scope = @"all";
//    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
//                         @"Other_Info_1": [NSNumber numberWithInt:123],
//                         @"Other_Info_2": @[@"obj1", @"obj2"],
//                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}

-(void)weiboLoginSuccessed:(NSNotification *)noti{
    DLog(@"weiboLoginSuccessed\n%@",noti.userInfo);
    
    NSString *openId = [noti.userInfo objectForKey:@"uid"];
    NSString *token = [noti.userInfo objectForKey:@"access_token"];
    [self login:@"weibo" uid:openId token:token];
}

#pragma mark - QQ登录

//QQ登录
- (IBAction)qqlogin:(id)sender{
    [_tencentOAuth authorize:_permissions inSafari:NO];
}

/**
 * Called when the user successfully logged in.
 */
- (void)tencentDidLogin {
    // 登录成功
//    _labelTitle.text = @"登录完成";
    
    DLog(@"QQ登录完成");
    if (_tencentOAuth.accessToken
        && 0 != [_tencentOAuth.accessToken length])
    {
        DLog(@"_tencentOAuth.accessToken:%@",_tencentOAuth.accessToken);
        
        
        NSString *openId = _tencentOAuth.openId;
        NSString *token = _tencentOAuth.accessToken;
        [self login:@"qq" uid:openId token:token];
        
        
//        if([_tencentOAuth getUserInfo]){
//            DLog(@"获取个人信息成功");
//        }else{
//            DLog(@"获取个人信息失败");
//        }
//        _labelAccessToken.text = _tencentOAuth.accessToken;
    }
    else
    {
        [self showHint:@"获取QQ授权失败"];
        DLog(@"登录不成功 没有获取accesstoken");
//        _labelAccessToken.text = @"登录不成功 没有获取accesstoken";
    }
}


/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled){
        DLog(@"用户取消登录");
//        _labelTitle.text = @"用户取消登录";
    }
    else {
        DLog(@"登录失败");
//        _labelTitle.text = @"登录失败";
    }
    
}

/**
 * Called when the notNewWork.
 */
-(void)tencentDidNotNetWork
{
    DLog(@"无网络连接，请设置网络");
//    _labelTitle.text=@"无网络连接，请设置网络";
}

//QQ登录获取用户信息
- (void)getUserInfoResponse:(APIResponse*) response{
//    DLog(@"%@",response.jsonResponse);
    
//    NSString *nickname = response.jsonResponse[@"nickname"];
//    NSString *avatar_url = response.jsonResponse[@"figureurl_qq_2"];
//    NSString *gender = response.jsonResponse[@"gender"];
//    NSString *province = response.jsonResponse[@"province"];
//    NSString *city = response.jsonResponse[@"city"];
    
}

- (IBAction)login:(id)sender {
    
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    if (self.username.text.length == 0) {
        [self showHint:@"请输入账号"];
        return;
    }
    NSRange foundObj=[self.username.text rangeOfString:@"@" options:NSCaseInsensitiveSearch];
    if(foundObj.length>0) {
        if (![self.username.text isValidateEmail]) {
            [self showHint:@"请输入正确的邮箱格式"];
            return;
        }
    }
    if (self.password.text.length == 0) {
        [self showHint:@"请输入密码"];
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if(foundObj.length>0) {
        [parameters setValue:self.username.text forKey:@"email"];
    } else {
        [parameters setValue:self.username.text forKey:@"phone"];
    }
    [parameters setValue:self.password.text forKey:@"password"];
    
    
    [self showHudInView:self.view hint:@"加载中"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,USER_LOGIN_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"JSON: %@", operation.responseString);
        [self hideHud];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                
                NSDictionary *message = [[dic objectForKey:@"message"] cleanNull];
                //                NSString *perishable_token = [message objectForKey:@"perishable_token"];
                NSString *single_access_token = [message objectForKey:@"single_access_token"];
                NSNumber *userid = [message objectForKey:@"id"];
                [UD setObject:message forKey:LOGINED_USER];
                [UD setObject:[userid stringValue] forKey:USER_ID];
                [UD setObject:single_access_token forKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,[userid stringValue]]];
                [UD setObject:[NSNumber numberWithInt:1] forKey:@"isLogin"];//设置登录
                
                CDIM* im=[CDIM sharedInstance];
                [im openWithClientId:[userid stringValue] callback:^(BOOL succeeded, NSError *error) {
                    if(error){
                        DLog(@"%@",error);
                    }else{
                        DLog(@"leancloud 登录成功");
                    }
                }];
                
                
                [self performSelector:@selector(toMainView) withObject:nil afterDelay:0.5];
                
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self hideHud];
        [self showHint:@"连接失败"];
        
    }];
}

- (void)reg:(id)sender{
    UIViewController *registerVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    [self.navigationController pushViewController:registerVc animated:YES];
}

@end
