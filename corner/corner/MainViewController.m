//
//  MainViewController.m
//  corner
//
//  Created by yons on 15-7-29.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "MainViewController.h"
#import "MJRefresh.h"
#import "LCEChatListVC.h"
#import "UIBarButtonItem+Badge.h"
#import "DongtaiTableViewController.h"
#import "ShaixuanViewController.h"
#import "UserDetailTableViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController{
    LCEChatListVC *chatListVC;
    UIViewController *iLikeVc;
    UIViewController *grzxVc;
    DongtaiTableViewController *dongtaiVc;
    
    int page;
    UIImageView *imageview1;
    UIImageView *imageview2;
    UIImageView *imageview3;
    UIImageView *imageview4;
    UIImageView *imageview5;
    UIImageView *imageview6;
    UIImageView *imageview7;
    UIImageView *imageview8;
    UIImageView *imageview9;
    UIImageView *imageview10;
    NSMutableArray *imageviewArr;
    UILabel *label1;
    UILabel *label2;
    UILabel *label3;
    UILabel *label4;
    UILabel *label5;
    UILabel *label6;
    UILabel *label7;
    UILabel *label8;
    UILabel *label9;
    UILabel *label10;
    NSMutableArray *labelArr;
    NSMutableArray *dataSource;
    
    NSMutableDictionary *params;//查询参数
}
@synthesize hFlowView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
//    self.navigationController.navigationBar.clipsToBounds = YES;
    self.mytoolbar.clipsToBounds = YES;
//    [self.navigationController.navigationBar.layer setMasksToBounds:YES];
    
//    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    params = [NSMutableDictionary dictionary];
    //注册查询通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mainSearch:) name:@"mainSearch" object:nil];
    
    dataSource = [NSMutableArray array];
    
    if ([self.navigationController.navigationBar respondsToSelector:@selector( setBackgroundImage:forBarMetrics:)]){
        NSArray *list=self.navigationController.navigationBar.subviews;
        for (id obj in list) {
            if ([obj isKindOfClass:[UIImageView class]]) {
                UIImageView *imageView=(UIImageView *)obj;
                NSArray *list2=imageView.subviews;
                for (id obj2 in list2) {
                    if ([obj2 isKindOfClass:[UIImageView class]]) {
                        UIImageView *imageView2=(UIImageView *)obj2;
                        imageView2.hidden=YES;
                    }
                }
            }
        }
    }
    
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    UIImage *image = [[UIImage imageNamed:@"leftMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    
    // 添加下拉刷新控件
    self.myscrollview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData];
        [self loadDataCenter];
    }];
    // 添加下拉刷新控件
    
//    // 添加默认的上拉刷新
//    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
//    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadDataMore)];
//    
//    // 设置文字
//    [footer setTitle:@"Click or drag up to refresh" forState:MJRefreshStateIdle];
//    [footer setTitle:@"Loading more ..." forState:MJRefreshStateRefreshing];
//    [footer setTitle:@"No more data" forState:MJRefreshStateNoMoreData];
//    
//    // 设置字体
//    footer.stateLabel.font = [UIFont systemFontOfSize:17];
//    
//    // 设置颜色
//    footer.stateLabel.textColor = [UIColor blueColor];
//    self.myscrollview.footer = footer;
    
    self.myscrollview.footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [self loadDataMore];
    }];
    DLog(@"%@",self.myscrollview);
    DLog(@"%@",self.myscrollview.footer);
    
    hFlowView.delegate = self;
    hFlowView.dataSource = self;
    hFlowView.minimumPageAlpha = 0.3;
    hFlowView.minimumPageScale = 0.6;
    
    [self addImageBtn];
    
    chatListVC = [[LCEChatListVC alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setUnRadCount)
                                                 name:@"setUnRadCount"
                                               object:nil];
    page = 1;
    [self setUnRadCount];
//    [self loadData];
//    [self loadDataCenter];
    
    [self.myscrollview.header beginRefreshing];
    
}
/**
 *  重置图片
 */
-(void)resetImg{
    [imageview1 setHidden:YES];
    [label1 setHidden:YES];
    [imageview2 setHidden:YES];
    [label2 setHidden:YES];
    [imageview3 setHidden:YES];
    [label3 setHidden:YES];
    [imageview4 setHidden:YES];
    [label4 setHidden:YES];
    [imageview5 setHidden:YES];
    [label5 setHidden:YES];
    [imageview6 setHidden:YES];
    [label6 setHidden:YES];
    [imageview7 setHidden:YES];
    [label7 setHidden:YES];
    [imageview8 setHidden:YES];
    [label8 setHidden:YES];
    [imageview9 setHidden:YES];
    [label9 setHidden:YES];
    [imageview10 setHidden:YES];
    [label10 setHidden:YES];
}



/**
 *  初始化 加载数据 周围一圈10个
 */
-(void)loadData{
    
    page = 1;

    
    
//    [parameters setValue:[NSNumber numberWithInt:near_close] forKey:@"near_close"];
//    [parameters setValue:[NSNumber numberWithInt:sex] forKey:@"sex"];
//    [parameters setValue:address forKey:@"address"];
    
    
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%d",HOST,USER_LIST_URL,page];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.myscrollview.header endRefreshing];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                [dataSource removeAllObjects];
                NSArray *arr = [dic objectForKey:@"message"];
                [dataSource addObjectsFromArray:arr];
                [self resetImg];
                for (int i = 0 ; i < dataSource.count; i++) {
                    
                    NSDictionary *info = [[dataSource objectAtIndex:i] cleanNull];
                    NSString *avatar_url = [NSString stringWithFormat:@"%@-small",[info objectForKey:@"avatar_url"]];//头像
                    NSString *nickname = [info objectForKey:@"nickname"];
                    
                    switch (i) {
                        case 0:
                        {
                            [imageview1 setHidden:NO];
                            [label1 setHidden:NO];
                            [imageview1 setImageWithURL:[NSURL URLWithString:avatar_url] placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label1.text = nickname;
                        }
                            break;
                        case 1:
                        {
                            [imageview2 setHidden:NO];
                            [label2 setHidden:NO];
                            [imageview2 setImageWithURL:[NSURL URLWithString:avatar_url] placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label2.text = nickname;
                        }
                            break;
                        case 2:
                        {
                            [imageview3 setHidden:NO];
                            [label3 setHidden:NO];
                            [imageview3 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label3.text = nickname;
                        }
                            break;
                        case 3:
                        {
                            [imageview4 setHidden:NO];
                            [label4 setHidden:NO];
                            [imageview4 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label4.text = nickname;
                        }
                            break;
                        case 4:
                        {
                            [imageview5 setHidden:NO];
                            [label5 setHidden:NO];
                            [imageview5 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label5.text = nickname;
                        }
                            break;
                        case 5:
                        {
                            [imageview6 setHidden:NO];
                            [label6 setHidden:NO];
                            [imageview6 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label6.text = nickname;
                        }
                            break;
                        case 6:
                        {
                            [imageview7 setHidden:NO];
                            [label7 setHidden:NO];
                            [imageview7 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label7.text = nickname;
                        }
                            break;
                        case 7:
                        {
                            [imageview8 setHidden:NO];
                            [label8 setHidden:NO];
                            [imageview8 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label8.text = nickname;
                        }
                            break;
                        case 8:
                        {
                            [imageview9 setHidden:NO];
                            [label9 setHidden:NO];
                            [imageview9 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label9.text = nickname;
                        }
                            break;
                        case 9:
                        {
                            [imageview10 setHidden:NO];
                            [label10 setHidden:NO];
                            [imageview10 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label10.text = nickname;
                        }
                            break;
                        default:
                            break;
                    }
                }
                
                
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self.myscrollview.header endRefreshing];
        [self showHint:@"连接失败"];
        
    }];
}

/**
 *  分页 加载数据 周围一圈10个
 */
-(void)loadDataMore{
    
    page ++;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%d",HOST,USER_LIST_URL,page];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.myscrollview.footer endRefreshing];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                [dataSource removeAllObjects];
                NSArray *arr = [dic objectForKey:@"message"];
                [dataSource addObjectsFromArray:arr];
                [self resetImg];
                
                for (int i = 0 ; i < dataSource.count; i++) {
                    
                    NSDictionary *info = [[dataSource objectAtIndex:i] cleanNull];
                    NSString *avatar_url = [NSString stringWithFormat:@"%@-small",[info objectForKey:@"avatar_url"]];//头像
                    NSString *nickname = [info objectForKey:@"nickname"];
                    
                    switch (i) {
                        case 0:
                        {
                            [imageview1 setHidden:NO];
                            [label1 setHidden:NO];
                            [imageview1 setImageWithURL:[NSURL URLWithString:avatar_url] placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label1.text = nickname;
                        }
                            break;
                        case 1:
                        {
                            [imageview2 setHidden:NO];
                            [label2 setHidden:NO];
                            [imageview2 setImageWithURL:[NSURL URLWithString:avatar_url] placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label2.text = nickname;
                        }
                            break;
                        case 2:
                        {
                            [imageview3 setHidden:NO];
                            [label3 setHidden:NO];
                            [imageview3 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label3.text = nickname;
                        }
                            break;
                        case 3:
                        {
                            [imageview4 setHidden:NO];
                            [label4 setHidden:NO];
                            [imageview4 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label4.text = nickname;
                        }
                            break;
                        case 4:
                        {
                            [imageview5 setHidden:NO];
                            [label5 setHidden:NO];
                            [imageview5 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label5.text = nickname;
                        }
                            break;
                        case 5:
                        {
                            [imageview6 setHidden:NO];
                            [label6 setHidden:NO];
                            [imageview6 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label6.text = nickname;
                        }
                            break;
                        case 6:
                        {
                            [imageview7 setHidden:NO];
                            [label7 setHidden:NO];
                            [imageview7 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label7.text = nickname;
                        }
                            break;
                        case 7:
                        {
                            [imageview8 setHidden:NO];
                            [label8 setHidden:NO];
                            [imageview8 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label8.text = nickname;
                        }
                            break;
                        case 8:
                        {
                            [imageview9 setHidden:NO];
                            [label9 setHidden:NO];
                            [imageview9 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label9.text = nickname;
                        }
                            break;
                        case 9:
                        {
                            [imageview10 setHidden:NO];
                            [label10 setHidden:NO];
                            [imageview10 setImageWithURL:[NSURL URLWithString:avatar_url]placeholderImage:[UIImage imageNamed:@"public_load_face"]];
                            label10.text = nickname;
                        }
                            break;
                        default:
                            break;
                    }
                }
                
                
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self.myscrollview.footer endRefreshing];
        [self showHint:@"连接失败"];
        
    }];
}

/**
 *  加载推荐之星
 */
-(void)loadDataCenter{
    
    
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithInt:1] forKey:@"page"];
    [parameters setValue:[NSNumber numberWithInt:1] forKey:@"type"];
    [parameters setValue:token forKey:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,USER_LOVELY_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                imageArray = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"message"]];
                [self.hFlowView reloadData];
                
                
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

/**
 *  添加周围一圈图片
 */
-(void)addImageBtn{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64 - 44 - 10;
    
    CGFloat imageSize = width/6;
    
    imageview1 = [[UIImageView alloc] init];
    imageview1.userInteractionEnabled = YES;
    imageview1.tag = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
    [imageview1 addGestureRecognizer:tap];
    imageview1.layer.cornerRadius = imageSize / 2;
    imageview1.layer.masksToBounds = YES;
    [imageview1 setFrame:CGRectMake(10, height / 2 - 50 - imageSize, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview1];
    label1 = [[UILabel alloc] initWithFrame:CGRectMake(imageview1.frame.origin.x, CGRectGetMaxY(imageview1.frame) + 5, CGRectGetWidth(imageview1.frame), 10)];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.font = [UIFont systemFontOfSize:10];
    label1.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label1];
    
    imageview3 = [[UIImageView alloc] init];
    imageview3.userInteractionEnabled = YES;
    imageview3.tag = 2;
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
    [imageview3 addGestureRecognizer:tap3];
    imageview3.layer.cornerRadius = imageSize / 2;
    imageview3.layer.masksToBounds = YES;
    [imageview3 setFrame:CGRectMake(width / 2 - imageSize / 2, height / 4 - imageSize - 10, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview3];
    label3 = [[UILabel alloc] initWithFrame:CGRectMake(imageview3.frame.origin.x, CGRectGetMaxY(imageview3.frame) + 5, CGRectGetWidth(imageview3.frame), 10)];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.font = [UIFont systemFontOfSize:10];
    label3.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label3];
    
    imageview5 = [[UIImageView alloc] init];
    imageview5.userInteractionEnabled = YES;
    imageview5.tag = 4;
    UITapGestureRecognizer *tap5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
    [imageview5 addGestureRecognizer:tap5];
    imageview5.layer.cornerRadius = imageSize / 2;
    imageview5.layer.masksToBounds = YES;
    [imageview5 setFrame:CGRectMake(width - 10 - imageSize, imageview1.frame.origin.y, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview5];
    label5 = [[UILabel alloc] initWithFrame:CGRectMake(imageview5.frame.origin.x, CGRectGetMaxY(imageview5.frame) + 5, CGRectGetWidth(imageview5.frame), 10)];
    label5.textAlignment = NSTextAlignmentCenter;
    label5.font = [UIFont systemFontOfSize:10];
    label5.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label5];
    
    imageview2 = [[UIImageView alloc] init];
    imageview2.userInteractionEnabled = YES;
    imageview2.tag = 1;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
    [imageview2 addGestureRecognizer:tap2];
    imageview2.layer.cornerRadius = imageSize / 2;
    imageview2.layer.masksToBounds = YES;
    [imageview2 setFrame:CGRectMake((imageview3.frame.origin.x - imageview1.frame.origin.x) / 2 + imageview1.frame.origin.x - 10, height / 2 - 50 - imageSize - imageview1.frame.size.height - 5, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview2];
    label2 = [[UILabel alloc] initWithFrame:CGRectMake(imageview2.frame.origin.x, CGRectGetMaxY(imageview2.frame) + 5, CGRectGetWidth(imageview2.frame), 10)];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font = [UIFont systemFontOfSize:10];
    label2.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label2];
    
    imageview4 = [[UIImageView alloc] init];
    imageview4.userInteractionEnabled = YES;
    imageview4.tag = 3;
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
    [imageview4 addGestureRecognizer:tap4];
    imageview4.layer.cornerRadius = imageSize / 2;
    imageview4.layer.masksToBounds = YES;
    [imageview4 setFrame:CGRectMake((imageview5.frame.origin.x - imageview3.frame.origin.x) / 2 + imageview3.frame.origin.x + 10, imageview2.frame.origin.y, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview4];
    label4 = [[UILabel alloc] initWithFrame:CGRectMake(imageview4.frame.origin.x, CGRectGetMaxY(imageview4.frame) + 5, CGRectGetWidth(imageview4.frame), 10)];
    label4.textAlignment = NSTextAlignmentCenter;
    label4.font = [UIFont systemFontOfSize:10];
    label4.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label4];
    
    
    imageview6 = [[UIImageView alloc] init];
    imageview6.userInteractionEnabled = YES;
    imageview6.tag = 5;
    UITapGestureRecognizer *tap6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
    [imageview6 addGestureRecognizer:tap6];
    imageview6.layer.cornerRadius = imageSize / 2;
    imageview6.layer.masksToBounds = YES;
    [imageview6 setFrame:CGRectMake(10, height / 2 + 50, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview6];
    label6 = [[UILabel alloc] initWithFrame:CGRectMake(imageview6.frame.origin.x, CGRectGetMaxY(imageview6.frame) + 5, CGRectGetWidth(imageview6.frame), 10)];
    label6.textAlignment = NSTextAlignmentCenter;
    label6.font = [UIFont systemFontOfSize:10];
    label6.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label6];
    
    imageview8 = [[UIImageView alloc] init];
    imageview8.userInteractionEnabled = YES;
    imageview8.tag = 7;
    UITapGestureRecognizer *tap8 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
    [imageview8 addGestureRecognizer:tap8];
    imageview8.layer.cornerRadius = imageSize / 2;
    imageview8.layer.masksToBounds = YES;
    [imageview8 setFrame:CGRectMake(width / 2 - imageSize / 2, height / 4 * 3 + 5, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview8];
    label8 = [[UILabel alloc] initWithFrame:CGRectMake(imageview8.frame.origin.x, CGRectGetMaxY(imageview8.frame) + 5, CGRectGetWidth(imageview8.frame), 10)];
    label8.textAlignment = NSTextAlignmentCenter;
    label8.font = [UIFont systemFontOfSize:10];
    label8.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label8];
    
    imageview10 = [[UIImageView alloc] init];
    imageview10.userInteractionEnabled = YES;
    imageview10.tag = 9;
    UITapGestureRecognizer *tap10 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
    [imageview10 addGestureRecognizer:tap10];
    imageview10.layer.cornerRadius = imageSize / 2;
    imageview10.layer.masksToBounds = YES;
    [imageview10 setFrame:CGRectMake(width - 10 - imageSize, imageview6.frame.origin.y, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview10];
    label10 = [[UILabel alloc] initWithFrame:CGRectMake(imageview10.frame.origin.x, CGRectGetMaxY(imageview10.frame) + 5, CGRectGetWidth(imageview10.frame), 10)];
    label10.textAlignment = NSTextAlignmentCenter;
    label10.font = [UIFont systemFontOfSize:10];
    label10.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label10];
    
    imageview7 = [[UIImageView alloc] init];
    imageview7.userInteractionEnabled = YES;
    imageview7.tag = 6;
    UITapGestureRecognizer *tap7 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
    [imageview7 addGestureRecognizer:tap7];
    imageview7.layer.cornerRadius = imageSize / 2;
    imageview7.layer.masksToBounds = YES;
    [imageview7 setFrame:CGRectMake(imageview2.frame.origin.x, height / 2 + 50 + imageview6.frame.size.height + 10, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview7];
    label7 = [[UILabel alloc] initWithFrame:CGRectMake(imageview7.frame.origin.x, CGRectGetMaxY(imageview7.frame) + 5, CGRectGetWidth(imageview7.frame), 10)];
    label7.textAlignment = NSTextAlignmentCenter;
    label7.font = [UIFont systemFontOfSize:10];
    label7.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label7];
    
    imageview9 = [[UIImageView alloc] init];
    imageview9.userInteractionEnabled = YES;
    imageview9.tag = 8;
    UITapGestureRecognizer *tap9 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgClick:)];
    [imageview9 addGestureRecognizer:tap9];
    imageview9.layer.cornerRadius = imageSize / 2;
    imageview9.layer.masksToBounds = YES;
    [imageview9 setFrame:CGRectMake(imageview4.frame.origin.x, imageview7.frame.origin.y, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview9];
    label9 = [[UILabel alloc] initWithFrame:CGRectMake(imageview9.frame.origin.x, CGRectGetMaxY(imageview9.frame) + 5, CGRectGetWidth(imageview9.frame), 10)];
    label9.textAlignment = NSTextAlignmentCenter;
    label9.font = [UIFont systemFontOfSize:10];
    label9.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label9];
}

-(void)leftMenu{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PagedFlowView Delegate
- (CGSize)sizeForPageInFlowView:(PagedFlowView *)flowView;{
    return CGSizeMake(100, 100);
}

- (void)flowView:(PagedFlowView *)flowView didScrollToPageAtIndex:(NSInteger)index {
    NSLog(@"Scrolled to page # %ld", (long)index);
}

- (void)flowView:(PagedFlowView *)flowView didTapPageAtIndex:(NSInteger)index{
    NSLog(@"Tapped on page # %ld", (long)index);
    NSDictionary *info = [[imageArray objectAtIndex:index] cleanNull];
    NSString *nickname = [info objectForKey:@"nickname"];
    UserDetailTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserDetailTableViewController"];
    vc.title = nickname;
    vc.userinfo = info;
    [self.navigationController pushViewController:vc animated:YES];
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark PagedFlowView Datasource
//返回显示View的个数
- (NSInteger)numberOfPagesInFlowView:(PagedFlowView *)flowView{
    return [imageArray count];
}

//返回给某列使用的View
- (UIView *)flowView:(PagedFlowView *)flowView cellForPageAtIndex:(NSInteger)index{
    UIImageView *imageView = (UIImageView *)[flowView dequeueReusableCell];
    if (!imageView) {
        imageView = [[UIImageView alloc] init];
        imageView.layer.cornerRadius = 50;
        imageView.layer.masksToBounds = YES;
    }
    
    NSDictionary *info = [[imageArray objectAtIndex:index] cleanNull];
    NSString *avatar_url = [NSString stringWithFormat:@"%@-small",[info objectForKey:@"avatar_url"]];
    
    [imageView setImageWithURL:[NSURL URLWithString:avatar_url] placeholderImage:[UIImage imageNamed:@"public_load_face"]];
    return imageView;
}

/**
 *  设置未读聊天数量
 */
-(void)setUnRadCount{
    NSInteger totalUnreadCount = [[CDStorage storage] countUnread];
    self.charItem.badgeValue = [NSString stringWithFormat:@"%d",totalUnreadCount];
}

- (IBAction)action1:(id)sender {
    [self.navigationController pushViewController:chatListVC animated:YES];
}

- (IBAction)action2:(id)sender {
    if (iLikeVc == nil) {
        iLikeVc = [self.storyboard instantiateViewControllerWithIdentifier:@"ILikeCollectionViewController"];
    }
    [self.navigationController pushViewController:iLikeVc animated:YES];
}

- (IBAction)action3:(id)sender {
    if (dongtaiVc == nil) {
        dongtaiVc = [self.storyboard instantiateViewControllerWithIdentifier:@"DongtaiTableViewController"];
        NSString *userid = [UD objectForKey:USER_ID];
        dongtaiVc.userid = userid;
    }
    [self.navigationController pushViewController:dongtaiVc animated:YES];
}

- (IBAction)action4:(id)sender {
    if (grzxVc == nil) {
        grzxVc = [self.storyboard instantiateViewControllerWithIdentifier:@"GrzxTableViewController"];
    }
    [self.navigationController pushViewController:grzxVc animated:YES];
}

- (IBAction)search:(id)sender {
    ShaixuanViewController *vc = [[ShaixuanViewController alloc] init];
    [self.navigationController presentViewController:vc animated:YES completion:nil];
}

/**
 *  点击周围图片
 *
 *  @param gesture
 */
-(void)imgClick:(UITapGestureRecognizer *)gesture{
    DLog(@"%d",gesture.view.tag);
    NSDictionary *info = [[dataSource objectAtIndex:(int)gesture.view.tag] cleanNull];
    
    NSString *nickname = [info objectForKey:@"nickname"];
    UserDetailTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserDetailTableViewController"];
    vc.title = nickname;
    vc.userinfo = info;
    [self.navigationController pushViewController:vc animated:YES];
}
/**
 *  筛选
 *
 *  @param notification
 */
-(void)mainSearch:(NSNotification*) notification{
    
    NSDictionary *obj = [notification object];
    NSString *age = [obj objectForKey:@"age"];
    NSNumber *sex = [obj objectForKey:@"sex"];
    NSString *address = [obj objectForKey:@"address"];
    DLog(@"mainSearch %@ %@ %@",age,sex,address);
    [params removeAllObjects];
    if (![age isEqualToString:@""]) {
        [params setObject:age forKey:@"age"];
    }
    if (![sex intValue] == 2) {
        [params setObject:sex forKey:@"sex"];
    }
    if (![address isEqualToString:@""] && ![address isEqualToString:@"请选择地区"]) {
        [params setObject:address forKey:@"address"];
    }
    [self.myscrollview.header beginRefreshing];
    //    [parameters setValue:[NSNumber numberWithInt:near_close] forKey:@"near_close"];
    //    [parameters setValue:[NSNumber numberWithInt:sex] forKey:@"sex"];
    //    [parameters setValue:address forKey:@"address"];
    
    
    
}

@end
