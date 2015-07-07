//
//  UIViewController+updateUserInfo.m
//  corner
//
//  Created by yons on 15-7-3.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "UIViewController+updateUserInfo.h"

@implementation UIViewController (updateUserInfo)

/**
 *  修改用户信息
 *
 *  @param attr  属性
 *  @param value 值
 */
-(void)updateUserInfo:(NSString *)attr value:(NSString *)value{
    [self showHudInView:self.view hint:@"加载中"];
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
                [[NSNotificationCenter defaultCenter] postNotificationName:USER_DETAIL_CHANGE object:nil userInfo:message];
                [self.navigationController popViewControllerAnimated:YES];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideHud];
        NSLog(@"发生错误！%@",error);
        [self showHint:@"连接失败"];
    }];
}


@end
