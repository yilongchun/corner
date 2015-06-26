//
//  RegisterViewController.m
//  corner
//
//  Created by yons on 15-5-28.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "RegisterViewController.h"
#import "IQKeyboardManager.h"
#import "NSString+Valid.h"

@interface RegisterViewController ()

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStyleDone target:self action:@selector(reg)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}

-(void)reg{
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
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,USER_REGISTER_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self hideHud];
        NSLog(@"JSON: %@", operation.responseString);
        
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
                NSString *userid = [message objectForKey:@"id"];
                [self showHint:@"注册成功"];
                [UD setObject:message forKey:LOGINED_USER];
                [UD setObject:userid forKey:USER_ID];
                [UD setObject:single_access_token forKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
