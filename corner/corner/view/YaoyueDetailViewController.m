//
//  YaoyueDetailViewController.m
//  corner
//
//  Created by yons on 15-6-19.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "YaoyueDetailViewController.h"

@interface YaoyueDetailViewController (){
    CGFloat height;
    UIBarButtonItem *rightItem;
    NSMutableArray *dataSource;
}

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
    
    UIImage *image = [[UIImage imageNamed:@"pub_title_8_v1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    rightItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(close)];
    
    

    dataSource = [NSMutableArray array];
    
    [self.enjoyBtn setHidden:YES];
    [self.tipsLabel setHidden:YES];
    [self.caredNumsView setHidden:YES];
    
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
                
                NSString *created_user_id = [message objectForKey:@"created_user_id"];
                NSString *userid = [UD objectForKey:USER_ID];
                if ([userid intValue] == [created_user_id intValue]) {
                    [self.tipsLabel setHidden:NO];
                    [self.caredNumsView setHidden:NO];
                    self.enjoyBtnHeight.constant = 0;
                    self.navigationItem.rightBarButtonItem = rightItem;
                    NSArray *cared_users = [message objectForKey:@"cared_users"];//感兴趣的人
                    self.caredNumsLabel.text = [NSString stringWithFormat:@"(共计%lu人)",(unsigned long)[cared_users count]];
                    if ([cared_users count] != 0) {
                        dataSource = [NSMutableArray arrayWithArray:cared_users];
                        [self addBtn:cared_users];
                    }
                }else{
                    [self.enjoyBtn setHidden:NO];
                }
                
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

//添加按钮
-(void)addBtn:(NSArray *)cared_users{
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat y = CGRectGetMaxY(self.caredNumsView.frame) - 30;
    CGFloat x = 0;
    
    for (int i = 0 ; i < [cared_users count]; i++) {
        NSDictionary *obj = [[cared_users objectAtIndex:i] cleanNull];
        NSString *avatar_url = [obj objectForKey:@"avatar_url"];
        NSNumber *userid = [obj objectForKey:@"id"];
        NSString *nickname = [obj objectForKey:@"nickname"];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, y, screenWidth, 44)];
        view.backgroundColor = [UIColor whiteColor];
        UIImageView *userImage = [[UIImageView alloc]initWithFrame:CGRectMake(15, 7, 30, 30)];
        [userImage setImageWithURL:[NSURL URLWithString:avatar_url] placeholer:[UIImage imageNamed:@"public_load_face"]];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 12, 20, 20)];
        nameLabel.text = [nickname isEqualToString:@""] ? [userid stringValue]  : nickname;
        nameLabel.font = [UIFont systemFontOfSize:14];
        [view addSubview:userImage];
        [view addSubview:nameLabel];
        [nameLabel sizeToFit];
        
        UIButton *okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [okBtn setFrame:CGRectMake(screenWidth - 100, 4, 40, 36)];
        [okBtn setTitle:@"同意" forState:UIControlStateNormal];
        [okBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [okBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        okBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        okBtn.tag = i;
        [okBtn addTarget:self action:@selector(ok:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:okBtn];
        
        UIButton *noBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [noBtn setFrame:CGRectMake(screenWidth - 50, 4, 40, 36)];
        [noBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        [noBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [noBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        noBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        noBtn.tag = i;
        [noBtn addTarget:self action:@selector(no:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:noBtn];
        
        [self.myscrollview addSubview:view];
        
        y += 46;
        height = CGRectGetMaxY(view.frame) + 20;
    }
}
//同意
-(void)ok:(UIButton *)btn{
    [self saveAgreeOrRegict:ACTIVITY_AGREE_URL index:(int)btn.tag];
}
//拒绝
-(void)no:(UIButton *)btn{
    [self saveAgreeOrRegict:ACTIVITY_REGECT_URL index:(int)btn.tag];
}
//保存数据
-(void)saveAgreeOrRegict:(NSString *)method index:(int)index{
    [self showHudInView:self.view hint:@"加载中"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    NSDictionary *cared_user = [[dataSource objectAtIndex:index] cleanNull];
    NSNumber *careduserid = [cared_user objectForKey:@"id"];
    //参数
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:[_activityDic objectForKey:@"id"] forKey:@"activity_id"];
    [parameters setValue:careduserid forKey:@"user_id"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,method];
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
//                NSDictionary *message = [[dic objectForKey:@"message"] cleanNull];
                if ([method isEqualToString:ACTIVITY_AGREE_URL]) {
                    [self showHint:@"已同意邀约"];
                    [self backAndFresh];
                }else if ([method isEqualToString:ACTIVITY_REGECT_URL]){
                    [self showHint:@"已拒绝邀约"];
                }
                
//                DLog(@"%@",message);
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

-(void)close{
    if (kCurrentSystemVersion < 8.0) {
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"关闭" otherButtonTitles:nil, nil];
        [actionsheet showInView:self.view];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self closeActivity];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:okAction];
        [alert addAction:cancelAction];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {//关闭
        [self closeActivity];
    }
}

-(void)closeActivity{
    [self showHudInView:self.view hint:@"加载中"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    //参数
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:[_activityDic objectForKey:@"id"] forKey:@"activity_id"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,ACTIVITY_CLOSE_URL];
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
//                NSDictionary *message = [[dic objectForKey:@"message"] cleanNull];
                [self showHint:@"关闭邀约"];
                
                [self backAndFresh];
                
//                DLog(@"%@",message);
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

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_myscrollview setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, height)];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
//                NSDictionary *message = [[dic objectForKey:@"message"] cleanNull];
                [self showHint:@"发送邀约成功"];
//                DLog(@"%@",message);
                
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

-(void)backAndFresh{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshWodeyaoyue" object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
    });
}
@end
