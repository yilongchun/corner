//
//  RedupaihangViewController.m
//  corner
//
//  Created by yons on 15-5-4.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "RedupaihangViewController.h"
#import "PaihangTableViewCell.h"
#import "PaihangTableViewCell2.h"
#import <QuartzCore/QuartzCore.h>
#import "UserDetailTableViewController.h"
#define cellIdentifier @"paihangcell"
#define cellIdentifier2 @"paihangcell2"
#import "SVPullToRefresh.h"


#define TOP_COLOR [UIColor colorWithRed:248/255. green:153/255. blue:27/255. alpha:1]
#define NORMAL_COLOR [UIColor colorWithRed:153/255. green:153/255. blue:153/255. alpha:1]

@interface RedupaihangViewController ()

@end

@implementation RedupaihangViewController{
    UISegmentedControl *segmentedControl;
    NSMutableArray *dataSource;
    int page;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (kCurrentSystemVersion > 6.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    UIImage *image = [[UIImage imageNamed:@"kiss_top1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.mytableview setTableFooterView:v];
    if ([self.mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.mytableview setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    if ([self.mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.mytableview setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    [self.mytableview setSeparatorColor:[UIColor lightGrayColor]];
    
    dataSource = [NSMutableArray array];
    
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mytableview.frame.size.width, 50)];
//    NSArray *segmentedArray = [[NSArray alloc]initWithObjects:@"今日排行",@"本周排行",@"同城排行",nil];
//    //初始化UISegmentedControl
//    segmentedControl = [[UISegmentedControl alloc]initWithItems:segmentedArray];
//    segmentedControl.frame = CGRectMake(10.0, 7.0, [UIScreen mainScreen].bounds.size.width - 20 , 35.0);
//    segmentedControl.selectedSegmentIndex = 0;//设置默认选择项索引
//    segmentedControl.tintColor = [UIColor whiteColor];
//    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
//    [view addSubview:segmentedControl];
//    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, view.frame.size.height-0.5, [UIScreen mainScreen].bounds.size.width, 0.5)];
//    imageview.backgroundColor = [UIColor colorWithRed:200/255. green:199/255. blue:204/255. alpha:1];
//    [view addSubview:imageview];
//    self.mytableview.tableHeaderView = view;
    
    __weak RedupaihangViewController *weakSelf = self;
    
    [self.mytableview addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
    [self.mytableview addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
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

-(void)loadData{
    page = 1;
    
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [parameters setValue:[NSNumber numberWithInt:_redutype] forKey:@"type"];
    [parameters setValue:token forKey:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,USER_LOVELY_URL];
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

-(void)loadMore{
    
    page++;
    
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [parameters setValue:[NSNumber numberWithInt:_redutype] forKey:@"type"];
    [parameters setValue:token forKey:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,USER_LOVELY_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

////事件
//-(void)segmentAction:(UISegmentedControl *)Seg{
////    NSInteger Index = Seg.selectedSegmentIndex;
//    [self loadData];
////    NSLog(@"Seg.selectedSegmentIndex:%ld",(long)Index);
//}

- (NSInteger)numberOfSections{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < 3) {
        
        PaihangTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PaihangTableViewCell" owner:self options:nil] lastObject];
        }
            cell.userHeadImage.layer.cornerRadius = 25.0f;
            cell.userHeadImage.layer.masksToBounds = YES;
            cell.userHeadImage.layer.borderColor = [UIColor whiteColor].CGColor;
            cell.userHeadImage.layer.borderWidth = 1.0f;
        
        NSDictionary *info = [[dataSource objectAtIndex:indexPath.row] cleanNull];
        NSNumber *userid = [info objectForKey:@"id"];
        NSString *nickname = [info objectForKey:@"nickname"];
        
        //    NSString *age = [info objectForKey:@"age"];
//        NSString *zhiye = [info objectForKey:@"zhiye"];
        NSString *avatar_url = [info objectForKey:@"avatar_url"];
        
        switch (indexPath.row) {
            case 0:
                cell.sortImage.image = [UIImage imageNamed:@"paihang1"];
                break;
            case 1:
                cell.sortImage.image = [UIImage imageNamed:@"paihang2"];
                break;
            case 2:
                cell.sortImage.image = [UIImage imageNamed:@"paihang3"];
                break;
            default:
                break;
        }
        if ([nickname isEqualToString:@""]) {
            nickname = [userid stringValue];
        }
        cell.nameLabel.text = nickname;
        
        NSString *birthday = [info objectForKey:@"birthday"];
        if ([birthday isEqualToString:@"1900-01-01"]) {
            cell.ageLabel.text = @"-";
        }else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date= [dateFormatter dateFromString:birthday];
            NSInteger age = [NSDate ageWithDateOfBirth:date];
            cell.ageLabel.text = [NSString stringWithFormat:@"%ld岁",(long)age];
        }
//        cell.zhiyeLabel.text = zhiye;
        if (![avatar_url isEqualToString:@""]) {
            [cell.userHeadImage setImageWithURL:[NSURL URLWithString:avatar_url] placeholderImage:[UIImage imageNamed:@"public_load_face"]];
        }else{
            [cell.userHeadImage setImage:[UIImage imageNamed:@"public_load_face"]];
        }
        NSNumber *sexnum = [info objectForKey:@"sex"];
        switch ([sexnum intValue]) {
            case 0:
                [cell.sexImageView setImage:[UIImage imageNamed:@"man"]];
                break;
            case 1:
                [cell.sexImageView setImage:[UIImage imageNamed:@"women"]];
                break;
            default:
                break;
        }
        return cell;
    }else{
        PaihangTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier2];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"PaihangTableViewCell2" owner:self options:nil] lastObject];
            
            
            
        }
        cell.sortBgView.layer.cornerRadius = 18.0f;
        cell.sortBgView.layer.masksToBounds = YES;
            cell.userHeadImage.layer.cornerRadius = 25.0f;
            cell.userHeadImage.layer.masksToBounds = YES;
            cell.userHeadImage.layer.borderColor = [UIColor whiteColor].CGColor;
            cell.userHeadImage.layer.borderWidth = 1.0f;
        
        NSDictionary *info = [[dataSource objectAtIndex:indexPath.row] cleanNull];
        NSNumber *userid = [info objectForKey:@"id"];
        NSString *nickname = [info objectForKey:@"nickname"];
        NSNumber *sexnum = [info objectForKey:@"sex"];
        //    NSString *age = [info objectForKey:@"age"];
//        NSString *zhiye = [info objectForKey:@"zhiye"];
        NSString *avatar_url = [info objectForKey:@"avatar_url"];
        
        cell.sortLabel.text = [NSString stringWithFormat:@"%d",indexPath.row + 1];
        if ([nickname isEqualToString:@""]) {
            nickname = [userid stringValue];
        }
        cell.nameLabel.text = nickname;
        
        NSString *birthday = [info objectForKey:@"birthday"];
        if ([birthday isEqualToString:@"1900-01-01"]) {
            cell.ageLabel.text = @"-";
        }else{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *date= [dateFormatter dateFromString:birthday];
            NSInteger age = [NSDate ageWithDateOfBirth:date];
            cell.ageLabel.text = [NSString stringWithFormat:@"%ld岁",(long)age];
        }
//        cell.zhiyeLabel.text = zhiye;
        if (![avatar_url isEqualToString:@""]) {
            [cell.userHeadImage setImageWithURL:[NSURL URLWithString:avatar_url] placeholderImage:[UIImage imageNamed:@"public_load_face"]];
        }else{
            [cell.userHeadImage setImage:[UIImage imageNamed:@"public_load_face"]];
        }
        switch ([sexnum intValue]) {
            case 0:
                [cell.sexImageView setImage:[UIImage imageNamed:@"man"]];
                break;
            case 1:
                [cell.sexImageView setImage:[UIImage imageNamed:@"women"]];
                break;
            default:
                break;
        }
        return cell;
    }
    
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *userinfo = [[dataSource objectAtIndex:indexPath.row] cleanNull];
    NSString *nickname = [userinfo objectForKey:@"nickname"];
    UserDetailTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserDetailTableViewController"];
    vc.title = nickname;
    vc.userinfo = userinfo;
    [self.navigationController pushViewController:vc animated:YES];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    return @"aaaa";
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mytableview.frame.size.width, 40)];
//    
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 40;
//}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
}

-(void)leftMenu{
    [self.sideMenuViewController presentLeftMenuViewController];
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
