//
//  LoginViewController.h
//  corner
//
//  Created by yons on 15-5-27.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>
//QQ登录
#import <TencentOpenAPI/TencentOAuth.h>
//微博登录
#import "WeiboSDK.h"
//微信登录
#import "WXApi.h"

@interface PreLoginViewController : UIViewController<TencentSessionDelegate,WXApiDelegate>{

//@interface PreLoginViewController : UIViewController{
    //QQ登录
    TencentOAuth* _tencentOAuth;
    NSMutableArray* _permissions;
}

@property (weak, nonatomic) IBOutlet UIButton *wxBtn;
@property (weak, nonatomic) IBOutlet UIButton *wbBtn;
@property (weak, nonatomic) IBOutlet UIButton *qqBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *regBtn;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;

- (IBAction)wxlogin:(id)sender;
- (IBAction)wblogin:(id)sender;
- (IBAction)qqlogin:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)reg:(id)sender;
@end
