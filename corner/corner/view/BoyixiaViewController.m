//
//  BoyixiaViewController.m
//  corner
//
//  Created by yons on 15-5-6.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "BoyixiaViewController.h"
#import "UIImageView+LBBlurredImage.h"
#import "UserDetailTableViewController.h"

@interface BoyixiaViewController ()

@property (strong, nonatomic) CAGradientLayer *gradientLayer;

@end

@implementation BoyixiaViewController{
    CGRect rect;
    BOOL flag;//动画状态
    UIImageView *tempView;
    NSString *oldImageUrl;
    NSMutableDictionary *firstDic;
    NSMutableDictionary *secondDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    tempView = [[UIImageView alloc] initWithFrame:self.userimageview.frame];
    tempView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(toDetail)];
    [tempView addGestureRecognizer:tap];
    [self.view addSubview:tempView];
    
    [self.msglabel removeFromSuperview];
    self.btn1.enabled = NO;
    self.btn2.enabled = NO;
    [self loadData:YES];
}

-(void)toDetail{
    NSString *nickname = [firstDic objectForKey:@"nickname"];
    UserDetailTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserDetailTableViewController"];
    vc.title = nickname;
    vc.userinfo = firstDic;
    [self.navigationController pushViewController:vc animated:YES];
}

//加载照片
-(void)loadData:(BOOL)first{
    
    
    if (first) {
        NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,USER_RANDOM_URL];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
        [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
            NSError *error;
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            if (dic == nil) {
                NSLog(@"json parse failed \r\n");
            }else{
                NSNumber *status = [dic objectForKey:@"status"];
                if ([status intValue] == 200) {
                    NSDictionary *message = [[dic objectForKey:@"message"] cleanNull];
                    NSString *avatar_url = [message objectForKey:@"avatar_url"];
                    [tempView setImageWithURL:[NSURL URLWithString:avatar_url]];
                    firstDic = [NSMutableDictionary dictionaryWithDictionary:message];
                }else if([status intValue] >= 600){
                    NSString *message = [dic objectForKey:@"message"];
                    [self showHint:message];
                    [self validateUserToken:[status intValue]];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"发生错误！%@",error);
//            [self showHint:@"连接失败"];
        }];
    }else{
        tempView = [[UIImageView alloc] initWithFrame:self.userimageview.frame];
        tempView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(toDetail)];
        [tempView addGestureRecognizer:tap];
        [tempView setImageWithURL:[NSURL URLWithString:oldImageUrl]];
        [self.view addSubview:tempView];
        firstDic = [NSMutableDictionary dictionaryWithDictionary:secondDic];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,USER_RANDOM_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        self.btn1.enabled = YES;
        self.btn2.enabled = YES;
        
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                NSDictionary *message = [[dic objectForKey:@"message"] cleanNull];
                NSString *avatar_url = [message objectForKey:@"avatar_url"];
                [self.userimageview setImageWithURL:[NSURL URLWithString:avatar_url]];
                if (first) {
                    secondDic = [NSMutableDictionary dictionaryWithDictionary:message];
                }else{
                    secondDic = [NSMutableDictionary dictionaryWithDictionary:message];
                }
                
                oldImageUrl = avatar_url;
//                [self.imageview setImageToBlur:self.userimageview.image
//                                    blurRadius:kLBBlurredImageDefaultBlurRadius
//                               completionBlock:^(){
//                                   NSLog(@"The blurred image has been set");
//                                   
//                               }];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self showHint:@"连接失败"];
        self.btn1.enabled = YES;
        self.btn2.enabled = YES;
    }];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if([[ UIScreen mainScreen ] bounds ].size.height == 480){
        self.leadConstraint.constant = 25.0f;
        self.trailingConstraint.constant = 25.0f;
        self.label1.text = @"";
        self.labelHeightConstraint.constant = 0;
        self.label2.text = @"";
        self.label2HeightConstraint.constant = 0;
    }
//    //初始化渐变层
//    self.gradientLayer = [CAGradientLayer layer];
//    self.gradientLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.imageview.frame.size.height);
//    [self.imageview.layer addSublayer:self.gradientLayer];
//    //设置渐变颜色方向
//    self.gradientLayer.startPoint = CGPointMake(0, 1);
//    self.gradientLayer.endPoint = CGPointMake(0, 0.8);
//    //设定颜色组
//    self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:29/255. green:29/255. blue:29/255. alpha:0.7].CGColor,
//                                  (__bridge id)[UIColor clearColor].CGColor];
//    //设定颜色分割点
//    self.gradientLayer.locations = @[@(0.0f)];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.btn1.enabled = YES;
    self.btn2.enabled = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)leftMenu:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}
- (IBAction)action1:(id)sender {
    self.btn1.enabled = NO;
    self.btn2.enabled = NO;
    
    CGPoint finishPoint = CGPointMake(self.view.center.x-600, tempView.center.y);
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: - M_PI * 1.5];
    rotationAnimation.duration = 0.4;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1;
    [tempView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    [UIView animateWithDuration:0.4f animations:^{
        tempView.center = finishPoint;
    } completion:^(BOOL finished) {
        [tempView removeFromSuperview];
        [self loadData:NO];
    }];
}

- (IBAction)action2:(id)sender {
    [self like];
    self.btn1.enabled = NO;
    self.btn2.enabled = NO;
    
    UIImageView *kiss_lip1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kiss_lip1"]];
    kiss_lip1.center = tempView.center;
    [tempView addSubview:kiss_lip1];
    kiss_lip1.transform = CGAffineTransformMakeScale(4.0, 4.0);
    [UIView animateWithDuration:0.3f animations:^{
        kiss_lip1.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [self performSelector:@selector(rightAnimation) withObject:nil afterDelay:0.2];
    }];
}

-(void)rightAnimation{
    CGPoint finishPoint = CGPointMake(self.view.center.x+600, tempView.center.y);
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 1.5 ];
    rotationAnimation.duration = 0.4;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1;
    [tempView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    [UIView animateWithDuration:0.4f animations:^{
        tempView.center = finishPoint;
    } completion:^(BOOL finished) {
        [tempView removeFromSuperview];
        [self loadData:NO];
    }];
}

//喜欢
-(void)like{
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:[firstDic objectForKey:@"id"] forKey:@"user_b_id"];
    
    NSString *urlString = urlString = [NSString stringWithFormat:@"%@%@",HOST,CONSTACTS_CREATE_URL];
    
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
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshIlike" object:nil];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
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
