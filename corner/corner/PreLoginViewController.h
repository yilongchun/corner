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
@interface PreLoginViewController : UIViewController<TencentSessionDelegate>{

//@interface PreLoginViewController : UIViewController{
    //QQ登录
    TencentOAuth* _tencentOAuth;
    NSMutableArray* _permissions;
}

@property (weak, nonatomic) IBOutlet UIButton *wxBtn;
@property (weak, nonatomic) IBOutlet UIButton *wbBtn;
@property (weak, nonatomic) IBOutlet UIButton *qqBtn;
@property (weak, nonatomic) IBOutlet UIButton *emailOrPhoneBtn;

- (IBAction)wxlogin:(id)sender;
- (IBAction)wblogin:(id)sender;
- (IBAction)qqlogin:(id)sender;
@end
