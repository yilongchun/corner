//
//  LoginViewController.m
//  corner
//
//  Created by yons on 15-5-27.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "PreLoginViewController.h"

@interface PreLoginViewController ()

@end

@implementation PreLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *img = [[UIImage imageNamed:@"star_btn_v1"] stretchableImageWithLeftCapWidth:25 topCapHeight:0];
    [self.wxBtn setBackgroundImage:img forState:UIControlStateNormal];
    [self.wbBtn setBackgroundImage:img forState:UIControlStateNormal];
    [self.qqBtn setBackgroundImage:img forState:UIControlStateNormal];
    [self.emailOrPhoneBtn setBackgroundImage:img forState:UIControlStateNormal];
    
    self.wxBtn.alpha = 0.0;
    self.wbBtn.alpha = 0.0;
    self.qqBtn.alpha = 0.0;
    self.emailOrPhoneBtn.alpha = 0.0;
    
    self.wxBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    self.wbBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    self.qqBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    self.emailOrPhoneBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    
    UIViewAnimationOptions options = UIViewAnimationCurveLinear | UIViewKeyframeAnimationOptionAllowUserInteraction;
    [UIView animateWithDuration:0.2 delay:0.2 options:options animations:^{
        self.wxBtn.alpha = 1.0;
        self.wxBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
    [UIView animateWithDuration:0.3 delay:0.2 options:options animations:^{
        self.wbBtn.alpha = 1.0;
        self.wbBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
    [UIView animateWithDuration:0.4 delay:0.2 options:options animations:^{
        self.qqBtn.alpha = 1.0;
        self.qqBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
    [UIView animateWithDuration:0.5 delay:0.2 options:options animations:^{
        self.emailOrPhoneBtn.alpha = 1.0;
        self.emailOrPhoneBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
    
    
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
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)login:(NSString *)provider uid:(NSString *)uid token:(NSString *)token{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:provider forKey:@"provider"];
    [parameters setObject:uid forKey:@"uid"];
    [parameters setObject:token forKey:@"token"];
    
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

- (IBAction)wxlogin:(id)sender{
    
}
- (IBAction)wblogin:(id)sender{
    
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

@end
