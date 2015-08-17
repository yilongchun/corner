//
//  TongchengyaoyueViewController.m
//  corner
//
//  Created by yons on 15-5-4.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "TongchengyaoyueViewController.h"
#import "TongchengyaoyueTableViewCell.h"
#import "SVPullToRefresh.h"
#import "YaoyueDetailViewController.h"

@implementation TongchengyaoyueViewController{
    int page;//分页设置
    NSMutableArray *dataSource;
}

static NSString * const reuseIdentifier = @"MyCollectionViewCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    dataSource = [NSMutableArray array];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    UIImage *image = [[UIImage imageNamed:@"leftMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    __weak TongchengyaoyueViewController *weakSelf = self;
    
    [self.mytableview addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    [self.mytableview addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.mytableview.tableFooterView = v;
    //初始化数据
    [self.mytableview triggerPullToRefresh];
    
}

- (void)insertRowAtTop {
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadData];
    });
}
-(void)insertRowAtBottom{
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadMore];
        
    });
}

/**
 *  初始化 加载数据
 */
-(void)loadData{
    page = 1;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,ACTIVITY_LIST_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.mytableview.pullToRefreshView stopAnimating];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                [dataSource removeAllObjects];
                [dataSource addObjectsFromArray:[dic objectForKey:@"message"]];
                
                [self.mytableview reloadData];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self.mytableview.pullToRefreshView stopAnimating];
        [self showHint:@"连接失败"];
        
    }];
}

/**
 *  加载更多
 */
-(void)loadMore{
    
    page++;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,ACTIVITY_LIST_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.mytableview.infiniteScrollingView stopAnimating];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                NSArray *array = [dic objectForKey:@"message"];
                
                if ([array count] > 0) {
                    [dataSource addObjectsFromArray:array];
                    [self.mytableview reloadData];
                }else{
                    page--;
                }
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        page--;
        NSLog(@"发生错误！%@",error);
        [self.mytableview.infiniteScrollingView stopAnimating];
        [self showHint:@"连接失败"];
        
    }];
}

-(void)leftMenu{
    [self.sideMenuViewController presentLeftMenuViewController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 213;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellreuseIdentifier = @"TongchengyaoyueTableViewCell";
    TongchengyaoyueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellreuseIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TongchengyaoyueTableViewCell" owner:self options:nil] lastObject];
//            [cell.bgview setImage:[[UIImage imageNamed:@"activity_9_v1"] stretchableImageWithLeftCapWidth:12 topCapHeight:12]];
//            [cell.topBg setImage:[[UIImage imageNamed:@"activity_top_v1"] stretchableImageWithLeftCapWidth:6 topCapHeight:0]];
        cell.userHeadImage.layer.masksToBounds = YES;
        cell.userHeadImage.layer.cornerRadius = 25;
    }

    
//    cell.userHeadImage.layer.cornerRadius = 2.0f;
//    cell.userHeadImage.layer.masksToBounds = YES;
//    cell.userHeadImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
//    cell.userHeadImage.layer.borderWidth = 0.2f;
    
    NSDictionary *info = [[dataSource objectAtIndex:indexPath.row] cleanNull];
    DLog(@"%@",info);
    
    NSDictionary *user = [[info objectForKey:@"user"] cleanNull];
    NSString *avatar_url = [user objectForKey:@"avatar_url"];
    NSString *nickname = [user objectForKey:@"nickname"];
    NSNumber *userid = [user objectForKey:@"id"];
    NSString *birthday = [user objectForKey:@"birthday"];
    NSNumber *sex = [user objectForKey:@"sex"];
    if (![avatar_url isEqualToString:@""]) {
        [cell.userHeadImage setImageWithURL:[NSURL URLWithString:avatar_url]];
    }
    if (![nickname isEqualToString:@""]) {
        cell.usernameLabel.text = nickname;
    }else{
        cell.usernameLabel.text = [userid stringValue];
    }
    switch ([sex intValue]) {
        case 0:
            [cell.userGenderImage setImage:[UIImage imageNamed:@"man"]];
            break;
        case 1:
            [cell.userGenderImage setImage:[UIImage imageNamed:@"women"]];
            break;
        default:
            break;
    }
    if ([birthday isEqualToString:@"1900-01-01"]) {
        cell.useAgeLabel.text = @"-";
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date= [dateFormatter dateFromString:birthday];
        NSInteger age = [NSDate ageWithDateOfBirth:date];
        cell.useAgeLabel.text = [NSString stringWithFormat:@"%ld岁",(long)age];
    }
    
    
    
    NSString *created_at = [info objectForKey:@"created_at"];
    NSString *description = [info objectForKey:@"description"];
    NSString *location_desc = [info objectForKey:@"location_desc"];
    NSString *pic_url = [info objectForKey:@"pic_url"];
    [cell.bgview setImageWithURL:[NSURL URLWithString:pic_url]];
//    NSNumber *status = [info objectForKey:@"status"];
    if ([description isEqualToString:@""]) {
        description = @" ";
    }
    
//    if (![pic_url hasSuffix:@"activity.jpg"]) {//无图片
//        [cell.userImage setImageWithURL:[NSURL URLWithString:pic_url] placeholderImage:[UIImage imageNamed:@"public_load_face"]];
//    }
    cell.titleLabel.text = description;
    cell.addressLabel.text = [NSString stringWithFormat:@"地点:%@",location_desc];
    cell.dateLabel.text = [NSString stringWithFormat:@"%@", created_at];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    YaoyueDetailViewController *vc = [[YaoyueDetailViewController alloc] init];
    vc.title = @"邀约";
    vc.activityDic = [[dataSource objectAtIndex:indexPath.row] cleanNull];
    [self.navigationController pushViewController:vc animated:YES];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)add:(id)sender {
    
    UINavigationController *nc =  [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FabuyaoyueTableViewController"]];
    nc.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
    nc.navigationBar.tintColor = [UIColor whiteColor];
    [nc.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self presentViewController:nc animated:YES completion:nil];
}
@end
