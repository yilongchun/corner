//
//  YaoyueDetailViewController.m
//  corner
//
//  Created by yons on 15-6-19.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "YaoyueDetailViewController.h"

@interface YaoyueDetailViewController ()

@end

@implementation YaoyueDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    [self loadData];
    
    //DLog(@"%@",_activityDic);
    

}

-(void)loadData{
    [self showHudInView:self.view hint:@"加载中"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    //参数
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@",HOST,ACTIVITY_DETAIL_URL,[_activityDic objectForKey:@"id"]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
                DLog(@"%@",message);
                
                NSString *pic_url = [message objectForKey:@"pic_url"];
                NSString *location_desc = [message objectForKey:@"location_desc"];//地点
                NSString *description = [message objectForKey:@"description"];
                NSNumber *type = [message objectForKey:@"type"];
                if ([pic_url hasSuffix:@"activity.jpg"]) {//没有图片
            
                }
            
                _nameLabel.text = @"";
                _lengthLabel.text = @"";
                _descLabel.text = description;
                _addressLabel.text = [NSString stringWithFormat:@"地点:%@",location_desc];
            
                switch ([type intValue]) {
                    case 0:
                        _typeLabel.text = @"一般约会";
                        break;
                    case 1:
                        _typeLabel.text = @"饭饭之交";
                        break;
                    case 2:
                        _typeLabel.text = @"约定一生";
                        break;
                    default:
                        _typeLabel.text = @"";
                        break;
                }
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self hideHud];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self hideHud];
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
//感兴趣
- (IBAction)enjoy:(id)sender {
    
    [self showHudInView:self.view hint:@"加载中"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    //参数
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:[_activityDic objectForKey:@"id"] forKey:@"activity_id"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,POST_CREATE_URL];
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
                [self showHint:@"发送邀约成功"];
                DLog(@"%@",message);
                
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self hideHud];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self hideHud];
        [self showHint:@"连接失败"];
    }];
}
@end
