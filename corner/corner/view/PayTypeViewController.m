//
//  PayTypeViewController.m
//  corner
//
//  Created by yons on 15-7-13.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "PayTypeViewController.h"
#import "Pingpp.h"

@interface PayTypeViewController ()

@end

@implementation PayTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(backAndrefresh:)
                                                 name:@"paySuccess"
                                               object:nil];
    
    self.title = @"支付方式";
    
    NSString *name = [_payInfo objectForKey:@"name"];
    NSNumber *price = [_payInfo objectForKey:@"price"];
    
    
    self.name.text = name;
    self.price.text = [NSString stringWithFormat:@"%d元",[price intValue]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)alipayAction:(id)sender {
    [self getChargeInfo:@"alipay" appURLScheme:@"wxd96d1f7d05fe7b81"];
}

- (IBAction)weixinAction:(id)sender {
    [self getChargeInfo:@"wx" appURLScheme:@"wxd96d1f7d05fe7b81"];
}

-(void)getChargeInfo:(NSString *)channel appURLScheme:(NSString *)appURLScheme{
    
    [self showHudInView:self.view hint:@"加载中"];
    
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    int amount = [[_payInfo objectForKey:@"price"] intValue] * 100;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:token forKey:@"token"];
    [parameters setObject:[NSNumber numberWithInt:amount] forKey:@"amount"];
    [parameters setObject:[NSNumber numberWithInt:0] forKey:@"type"];
    [parameters setObject:channel forKey:@"channel"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,RECHARGE_CREATE_URL];
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
            [Pingpp createPayment:result appURLScheme:appURLScheme withCompletion:^(NSString *result, PingppError *error) {
                NSLog(@">>>>>>> %@", result);
            }];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self hideHud];
        [self showHint:@"连接失败"];
        
    }];
}

-(void)backAndrefresh:(NSNotification *)noti{
    NSString *result = [noti.userInfo objectForKey:@"result"];
    if ([result isEqualToString:@"success"]) {
        [self showHint:@"支付成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMyAccount" object:nil];
    }else if ([result isEqualToString:@"cancel"]){
        [self showHint:@"取消支付"];
    }else if ([result isEqualToString:@"fail"]){
        [self showHint:@"支付失败"];
    }
    
    int64_t delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.navigationController popViewControllerAnimated:YES];
        
    });
}
@end
