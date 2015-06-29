//
//  WodezhuanjiaoViewController.m
//  corner
//
//  Created by yons on 15-6-12.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "WodezhuanjiaoViewController.h"
#import "SVPullToRefresh.h"
#import "WodezhuanjiaoTableViewCell.h"
#import "FabudongtaiViewController.h"

@implementation WodezhuanjiaoViewController{
    NSMutableArray *dataSource;
    
    NSInteger currentType;//type: 0 关注,1 同城,2 推荐
    
    int page;//分页设置
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentType = 0;
    
    if (kCurrentSystemVersion > 6.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    dataSource = [NSMutableArray array];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    UIImage *image = [[UIImage imageNamed:@"kiss_top1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.mytableview setTableFooterView:v];
    
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 43)];
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn1.tag = 0;
    [btn1 setTitle:@"关注" forState:UIControlStateNormal];
    [btn1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn1 setFrame:CGRectMake(0, 0, view.frame.size.width / 3, view.frame.size.height - 3)];
    [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.tag = 1;
    [btn2 setTitle:@"同城" forState:UIControlStateNormal];
    [btn2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn2 setFrame:CGRectMake(btn1.frame.size.width, 0, view.frame.size.width / 3, view.frame.size.height - 3)];
    [btn2 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn3.tag = 2;
    [btn3 setTitle:@"推荐" forState:UIControlStateNormal];
    [btn3 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btn3.titleLabel.font = [UIFont systemFontOfSize:13];
    [btn3 setFrame:CGRectMake(btn1.frame.size.width + btn2.frame.size.width, 0, view.frame.size.width / 3, view.frame.size.height - 3)];
    [btn3 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:btn1];
    [view addSubview:btn2];
    [view addSubview:btn3];
    
    self.mytableview.tableHeaderView = view;
    
    //下拉刷新 上拉加载
    __weak WodezhuanjiaoViewController *weakSelf = self;
    [self.mytableview addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    [self.mytableview addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    //初始化数据
    [self.mytableview triggerPullToRefresh];
}

-(void)leftMenu{
    [self.sideMenuViewController presentLeftMenuViewController];
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
    
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:[NSNumber numberWithLong:currentType] forKey:@"type"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%d",HOST,POST_LIST_URL,page];
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
    
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:[NSNumber numberWithLong:currentType] forKey:@"type"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%d",HOST,POST_LIST_URL,page];
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
        [self.mytableview.pullToRefreshView stopAnimating];
        [self showHint:@"连接失败"];
        
    }];
}

-(void)btnClick:(UIButton *)sender{
    if (sender.tag != currentType) {
        currentType = sender.tag;
        [self loadData];
    }
    
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WodezhuanjiaoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wdzjcell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"WodezhuanjiaoTableViewCell" owner:self options:nil] lastObject];
    }
    
    NSDictionary *info = [[dataSource objectAtIndex:indexPath.row] cleanNull];
    DLog(@"%@",info);
    
    NSString *pic_url = [info objectForKey:@"pic_url"];
    NSString *post_body = [info objectForKey:@"post_body"];
//    NSNumber *status = [info objectForKey:@"status"];
    NSNumber *user_id = [info objectForKey:@"user_id"];
    
    NSString *avatar_url = [NSString stringWithFormat:@"%@-small",pic_url];//头像
    
    if (![pic_url hasSuffix:@"post.jpg"]) {//无图片
        [cell.userImage setImageWithURL:[NSURL URLWithString:avatar_url] placeholderImage:[UIImage imageNamed:@"public_load_face"]];
    }
    
    
    cell.username.text = [NSString stringWithFormat:@"%d",[user_id intValue]];
    cell.msgLabel.text = post_body;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 3)];
    view.backgroundColor = RGBACOLOR(239, 239, 239, 1);
    
    CGFloat width = view.frame.size.width / 3;
    CGFloat height = view.frame.size.height;
    CGFloat margin = 20;
    switch (currentType) {
        case 0:
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0 + margin, 0, width - margin*2, height)];
            label.backgroundColor = RGBACOLOR(245, 186, 0, 1);
            [view addSubview:label];
        }
            break;
        case 1:
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width + margin, 0, width - margin*2, height)];
            label.backgroundColor = RGBACOLOR(245, 186, 0, 1);
            [view addSubview:label];
        }
            break;
        case 2:
        {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width * 2 + margin, 0, width - margin*2, height)];
            label.backgroundColor = RGBACOLOR(245, 186, 0, 1);
            [view addSubview:label];
        }
            break;
        default:
            break;
    }
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 257;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//去掉UItableview headerview黏性(sticky)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 3;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

/**
 *  发动态
 *
 *  @param sender
 */
- (IBAction)fadongtai:(id)sender {
    FabudongtaiViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FabudongtaiViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
