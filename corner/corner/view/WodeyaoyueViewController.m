//
//  WodeyaoyueViewController.m
//  corner
//
//  Created by yons on 15-6-30.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "WodeyaoyueViewController.h"
#import "WodeyaoyueTableViewCell.h"
#import "WodeyaoyueTableViewCell2.h"
#import "SVPullToRefresh.h"
#import "YaoyueDetailViewController.h"

@interface WodeyaoyueViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *tableview1;
    UITableView *tableview2;
    
    NSMutableArray *dataSource1;
    NSMutableArray *dataSource2;
    
    int page1;//分页设置
    int page2;//分页设置
}

@end

@implementation WodeyaoyueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"refreshWodeyaoyue"
                                               object:nil];
    
    tableview1 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
    tableview1.delegate = self;
    tableview1.dataSource = self;
    tableview1.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableview1.backgroundColor = RGBACOLOR(218, 218, 218, 1);
    [self.view addSubview:tableview1];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor yellowColor],NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:14],NSFontAttributeName, nil];
    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14],NSFontAttributeName, nil];
    
    [self.segmentControl setTitleTextAttributes:dic forState:UIControlStateSelected];
    [self.segmentControl setTitleTextAttributes:dic2 forState:UIControlStateNormal];
    
    dataSource1 = [NSMutableArray array];
    dataSource2 = [NSMutableArray array];
    
    __weak WodeyaoyueViewController *weakSelf = self;
    
    [tableview1 addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
    //初始化数据
    [tableview1 triggerPullToRefresh];
}

- (void)insertRowAtTop {
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadData];
    });
}

- (void)insertRowAtTop2 {
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadData];
    });
}

/**
 *  初始化 加载数据
 */
-(void)loadData{
    
    
    
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@?token=%@",HOST,USER_DETAIL_URL,userid,token];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        
        if (self.segmentControl.selectedSegmentIndex == 0){
            [tableview1.pullToRefreshView stopAnimating];
        }else{
            [tableview2.pullToRefreshView stopAnimating];
        }
        
     
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                
                
                NSDictionary *userinfo = [[dic objectForKey:@"message"] cleanNull];
                
                //用户的邀约
                NSArray *activities = [userinfo objectForKey:@"activities"];
                
                if (self.segmentControl.selectedSegmentIndex == 0){
                    [dataSource1 removeAllObjects];
                    [dataSource1 addObjectsFromArray:activities];
                    [tableview1 reloadData];
                }else{
                    [dataSource2 removeAllObjects];
                    [dataSource2 addObjectsFromArray:activities];
                    [tableview2 reloadData];
                }
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        if (self.segmentControl.selectedSegmentIndex == 0){
            [tableview1 reloadData];
        }else{
            [tableview2 reloadData];
        }
        [self showHint:@"连接失败"];
        
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.segmentControl.selectedSegmentIndex == 0) {
        return 129;
    }else{
        return 152;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.segmentControl.selectedSegmentIndex == 0) {
        return [dataSource1 count];
    }else{
        return [dataSource2 count];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.segmentControl.selectedSegmentIndex == 0) {
        WodeyaoyueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wodeyaoyuecell1"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WodeyaoyueTableViewCell" owner:self options:nil] lastObject];
            [cell.backgroundImageView setImage:[[UIImage imageNamed:@"activity_9_v1"] stretchableImageWithLeftCapWidth:12 topCapHeight:12]];
        }
        
        NSDictionary *activity = [[dataSource1 objectAtIndex:indexPath.row] cleanNull];
        
        NSString *location_desc = [NSString stringWithFormat:@"地点：%@",[activity objectForKey:@"location_desc"]];
        NSString *description = [activity objectForKey:@"description"];
        NSString *created_at = [NSString stringWithFormat:@"时间：%@",[activity objectForKey:@"created_at"]];

        cell.title.text = description;
        cell.date.text = created_at;
        cell.address.text = location_desc;
        return cell;
    }else{
        WodeyaoyueTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"wodeyaoyuecell2"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"WodeyaoyueTableViewCell2" owner:self options:nil] lastObject];
            [cell.backgroundImageView setImage:[[UIImage imageNamed:@"activity_9_v1"] stretchableImageWithLeftCapWidth:12 topCapHeight:12]];
        }
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    YaoyueDetailViewController *vc = [[YaoyueDetailViewController alloc] init];
    vc.title = @"邀约";
    switch (self.segmentControl.selectedSegmentIndex) {
        case 0:
            vc.activityDic = [[dataSource1 objectAtIndex:indexPath.row] cleanNull];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        case 1:
            vc.activityDic = [[dataSource2 objectAtIndex:indexPath.row] cleanNull];
            break;
    }
    
}



- (IBAction)changeType:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self.view bringSubviewToFront:tableview1];
            [tableview1 reloadData];
            break;
        case 1:
        {
            if (tableview2 == nil) {
                tableview2 = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 64)];
                tableview2.delegate = self;
                tableview2.dataSource = self;
                tableview2.separatorStyle = UITableViewCellSeparatorStyleNone;
                tableview2.backgroundColor = RGBACOLOR(218, 218, 218, 1);
                [self.view addSubview:tableview2];
                __weak WodeyaoyueViewController *weakSelf = self;
                [tableview2 addPullToRefreshWithActionHandler:^{
                    [weakSelf insertRowAtTop2];
                }];
                [tableview2 triggerPullToRefresh];
            }
            [self.view bringSubviewToFront:tableview2];
        }
            break;
        default:
            break;
    }
    
}

- (IBAction)fabuyaoyue:(id)sender {
    UINavigationController *nc =  [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FabuyaoyueTableViewController"]];
    nc.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
    nc.navigationBar.tintColor = [UIColor whiteColor];
    [nc.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self presentViewController:nc animated:YES completion:nil];
}
@end
