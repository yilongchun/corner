//
//  NichengUpdateViewController.m
//  corner
//
//  Created by yons on 15-7-2.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "NichengUpdateViewController.h"
#import "IQKeyboardManager.h"

@interface NichengUpdateViewController ()

@end

@implementation NichengUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    UIView *leftMargin = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    self.nicknameTextField.leftView = leftMargin;
    self.nicknameTextField.leftViewMode = UITextFieldViewModeAlways;
    self.nicknameTextField.text = self.nickname;
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = done;
}

-(void)done{
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    if (self.nicknameTextField.text.length == 0) {
        [self showHint:@"请填写昵称"];
        return;
    }else{
        [self updateUserInfo:@"nickname" value:self.nicknameTextField.text];
    }
}

/**
 *  修改用户信息
 *
 *  @param attr  属性
 *  @param value 值
 */
-(void)updateUserInfo:(NSString *)attr value:(NSString *)value{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:attr forKey:@"attr"];
    [parameters setValue:value forKey:@"value"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,USER_SET_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                NSString *nickname = [message objectForKey:@"nickname"];
                NSDictionary *userinfo = [UD objectForKey:LOGINED_USER];
                NSMutableDictionary *userinfo2 = [NSMutableDictionary dictionaryWithDictionary:userinfo];
                [userinfo2 setObject:nickname forKey:@"nickname"];
                [UD setObject:userinfo2 forKey:LOGINED_USER];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:USER_INFO_CHANGE object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:USER_DETAIL_CHANGE object:nil userInfo:message];
                [self.navigationController popViewControllerAnimated:YES];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self showHint:@"连接失败"];
    }];
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
