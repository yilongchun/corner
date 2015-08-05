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

@interface MainViewController ()

@end

@implementation MainViewController{
    LCEChatListVC *chatListVC;
    UIViewController *iLikeVc;
    UIViewController *grzxVc;
    DongtaiTableViewController *dongtaiVc;
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
    
    
    
    
//    UIImage *image = [[UIImage imageNamed:@"kiss_top1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    NSDictionary *userinfo = [UD objectForKey:LOGINED_USER];
    NSString *avatar_url = [userinfo objectForKey:@"avatar_url"];
    UIImage* image= [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatar_url]]];
    CGRect frame= CGRectMake(8, 0, 30, 30);
    UIButton* someButton= [[UIButton alloc] initWithFrame:frame];
    someButton.layer.cornerRadius = 15;
    someButton.layer.masksToBounds = YES;
    someButton.layer.borderColor = RGBACOLOR(220, 220, 220, 1).CGColor;
    someButton.layer.borderWidth = 1.0f;
    [someButton addTarget:self action:@selector(leftMenu) forControlEvents:UIControlEventTouchUpInside];
    [someButton setImage:image forState:UIControlStateNormal];
    
//    UIView *myview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 38, 30)];
//    UIImageView *sandian = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 30)];
//    [sandian setImage:[UIImage imageNamed:@"a1"]];
//    [sandian setContentMode:UIViewContentModeLeft];
//    [myview addSubview:sandian];
//    [myview addSubview:someButton];
    UIBarButtonItem* someBarButtonItem= [[UIBarButtonItem alloc] initWithCustomView:someButton];
    [self.navigationItem setLeftBarButtonItem:someBarButtonItem];
    
//    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatar_url]]];
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
//    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    
    // 添加下拉刷新控件
    self.myscrollview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        DLog(@"加载完毕");
        [self.myscrollview.header endRefreshing];
    }];
    
    imageArray = [[NSArray alloc] initWithObjects:@"0.tiff",@"1.tiff",@"2.tiff",@"3.tiff",@"4.tiff",@"5.tiff",@"6.tiff",@"7.tiff",nil];
    
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
    
    [self setUnRadCount];
    
    
}

/**
 *  添加周围一圈图片
 */
-(void)addImageBtn{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height - 64 - 44 - 10;
    
    CGFloat imageSize = 44;
    
    UIImageView *imageview1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0.tiff"]];
    imageview1.layer.cornerRadius = imageSize / 2;
    imageview1.layer.masksToBounds = YES;
    [imageview1 setFrame:CGRectMake(10, height / 2 - 50 - imageSize, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview1];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(imageview1.frame.origin.x, CGRectGetMaxY(imageview1.frame) + 5, CGRectGetWidth(imageview1.frame), 10)];
    label1.text = @"1分钟前";
    label1.textAlignment = NSTextAlignmentCenter;
    label1.font = [UIFont systemFontOfSize:10];
    label1.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label1];
    
    
    UIImageView *imageview3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1.tiff"]];
    imageview3.layer.cornerRadius = imageSize / 2;
    imageview3.layer.masksToBounds = YES;
    [imageview3 setFrame:CGRectMake(width / 2 - imageSize / 2, height / 4 - imageSize - 10, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview3];
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(imageview3.frame.origin.x, CGRectGetMaxY(imageview3.frame) + 5, CGRectGetWidth(imageview3.frame), 10)];
    label3.text = @"1分钟前";
    label3.textAlignment = NSTextAlignmentCenter;
    label3.font = [UIFont systemFontOfSize:10];
    label3.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label3];
    
    UIImageView *imageview5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2.tiff"]];
    imageview5.layer.cornerRadius = imageSize / 2;
    imageview5.layer.masksToBounds = YES;
    [imageview5 setFrame:CGRectMake(width - 10 - imageSize, imageview1.frame.origin.y, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview5];
    UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(imageview5.frame.origin.x, CGRectGetMaxY(imageview5.frame) + 5, CGRectGetWidth(imageview5.frame), 10)];
    label5.text = @"1分钟前";
    label5.textAlignment = NSTextAlignmentCenter;
    label5.font = [UIFont systemFontOfSize:10];
    label5.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label5];
    
    UIImageView *imageview2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"3.tiff"]];
    imageview2.layer.cornerRadius = imageSize / 2;
    imageview2.layer.masksToBounds = YES;
    [imageview2 setFrame:CGRectMake((imageview3.frame.origin.x - imageview1.frame.origin.x) / 2 + imageview1.frame.origin.x - 10, height / 2 - 50 - imageSize - imageview1.frame.size.height - 5, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview2];
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(imageview2.frame.origin.x, CGRectGetMaxY(imageview2.frame) + 5, CGRectGetWidth(imageview2.frame), 10)];
    label2.text = @"1分钟前";
    label2.textAlignment = NSTextAlignmentCenter;
    label2.font = [UIFont systemFontOfSize:10];
    label2.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label2];
    
    UIImageView *imageview4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"4.tiff"]];
    imageview4.layer.cornerRadius = imageSize / 2;
    imageview4.layer.masksToBounds = YES;
    [imageview4 setFrame:CGRectMake((imageview5.frame.origin.x - imageview3.frame.origin.x) / 2 + imageview3.frame.origin.x + 10, imageview2.frame.origin.y, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview4];
    UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(imageview4.frame.origin.x, CGRectGetMaxY(imageview4.frame) + 5, CGRectGetWidth(imageview4.frame), 10)];
    label4.text = @"1分钟前";
    label4.textAlignment = NSTextAlignmentCenter;
    label4.font = [UIFont systemFontOfSize:10];
    label4.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label4];
    
    
    UIImageView *imageview6 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"5.tiff"]];
    imageview6.layer.cornerRadius = imageSize / 2;
    imageview6.layer.masksToBounds = YES;
    [imageview6 setFrame:CGRectMake(10, height / 2 + 50, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview6];
    UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(imageview6.frame.origin.x, CGRectGetMaxY(imageview6.frame) + 5, CGRectGetWidth(imageview6.frame), 10)];
    label6.text = @"1分钟前";
    label6.textAlignment = NSTextAlignmentCenter;
    label6.font = [UIFont systemFontOfSize:10];
    label6.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label6];
    
    UIImageView *imageview8 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"6.tiff"]];
    imageview8.layer.cornerRadius = imageSize / 2;
    imageview8.layer.masksToBounds = YES;
    [imageview8 setFrame:CGRectMake(width / 2 - imageSize / 2, height / 4 * 3 + 5, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview8];
    UILabel *label8 = [[UILabel alloc] initWithFrame:CGRectMake(imageview8.frame.origin.x, CGRectGetMaxY(imageview8.frame) + 5, CGRectGetWidth(imageview8.frame), 10)];
    label8.text = @"1分钟前";
    label8.textAlignment = NSTextAlignmentCenter;
    label8.font = [UIFont systemFontOfSize:10];
    label8.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label8];
    
    UIImageView *imageview10 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"7.tiff"]];
    imageview10.layer.cornerRadius = imageSize / 2;
    imageview10.layer.masksToBounds = YES;
    [imageview10 setFrame:CGRectMake(width - 10 - imageSize, imageview6.frame.origin.y, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview10];
    UILabel *label10 = [[UILabel alloc] initWithFrame:CGRectMake(imageview10.frame.origin.x, CGRectGetMaxY(imageview10.frame) + 5, CGRectGetWidth(imageview10.frame), 10)];
    label10.text = @"1分钟前";
    label10.textAlignment = NSTextAlignmentCenter;
    label10.font = [UIFont systemFontOfSize:10];
    label10.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label10];
    
    UIImageView *imageview7 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0.tiff"]];
    imageview7.layer.cornerRadius = imageSize / 2;
    imageview7.layer.masksToBounds = YES;
    [imageview7 setFrame:CGRectMake(imageview2.frame.origin.x, height / 2 + 50 + imageview6.frame.size.height + 10, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview7];
    UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(imageview7.frame.origin.x, CGRectGetMaxY(imageview7.frame) + 5, CGRectGetWidth(imageview7.frame), 10)];
    label7.text = @"1分钟前";
    label7.textAlignment = NSTextAlignmentCenter;
    label7.font = [UIFont systemFontOfSize:10];
    label7.textColor = [UIColor whiteColor];
    [self.myscrollview addSubview:label7];
    
    UIImageView *imageview9 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"1.tiff"]];
    imageview9.layer.cornerRadius = imageSize / 2;
    imageview9.layer.masksToBounds = YES;
    [imageview9 setFrame:CGRectMake(imageview4.frame.origin.x, imageview7.frame.origin.y, imageSize, imageSize)];
    [self.myscrollview addSubview:imageview9];
    UILabel *label9 = [[UILabel alloc] initWithFrame:CGRectMake(imageview9.frame.origin.x, CGRectGetMaxY(imageview9.frame) + 5, CGRectGetWidth(imageview9.frame), 10)];
    label9.text = @"1分钟前";
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
    imageView.image = [UIImage imageNamed:[imageArray objectAtIndex:index]];
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
@end
