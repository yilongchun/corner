//
//  RegisterViewController.m
//  corner
//
//  Created by yons on 15-5-27.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "LoginViewController.h"
#import "IQKeyboardManager.h"
#import "NSString+Valid.h"


@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"转角";
    
//    self.usrename.text = @"5115413@qq.com";
//    self.password.text = @"111111";
    
//    UIView *leftview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 40)];
//    UIImageView *usernameImg = [[UIImageView alloc] initWithFrame:CGRectMake(5, 15, 20, 20)];
//    [usernameImg setImage:[UIImage imageNamed:@"login_username_icon.png"]];
//    [leftview addSubview:usernameImg];
//    self.usrename.leftViewMode = UITextFieldViewModeAlways;
//    self.usrename.leftView = leftview;
    
    UITapGestureRecognizer *tapGestureTel = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTapEvent)];
    self.registerLabel.userInteractionEnabled = YES;
    [self.registerLabel addGestureRecognizer:tapGestureTel];
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:self.registerLabel.text];
    NSRange contentRange = {0, [content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    self.registerLabel.attributedText = content;
    
    
    self.usrename.layer.borderColor = RGBACOLOR(216, 216, 216, 1).CGColor;
    self.usrename.layer.borderWidth = 1.0;
    self.usrename.layer.cornerRadius = 5.0;
    self.usrename.layer.masksToBounds = YES;
    self.password.layer.borderColor = RGBACOLOR(216, 216, 216, 1).CGColor;
    self.password.layer.borderWidth = 1.0;
    self.password.layer.cornerRadius = 5.0;
    self.password.layer.masksToBounds = YES;
}

-(void)labelTapEvent{
    UIViewController *registerVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RegisterViewController"];
    [self.navigationController pushViewController:registerVc animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillAppear:animated];
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

- (IBAction)login:(id)sender {
    
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    if (self.usrename.text.length == 0) {
        [self showHint:@"请输入账号"];
        return;
    }
    NSRange foundObj=[self.usrename.text rangeOfString:@"@" options:NSCaseInsensitiveSearch];
    if(foundObj.length>0) {
        if (![self.usrename.text isValidateEmail]) {
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
        [parameters setValue:self.usrename.text forKey:@"email"];
    } else {
        [parameters setValue:self.usrename.text forKey:@"phone"];
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

-(void)toMainView{
    NSString *storyboardId = @"RootViewController";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *initViewController = [storyboard instantiateViewControllerWithIdentifier:storyboardId];
    self.view.window.rootViewController = initViewController;
    
}

@end
