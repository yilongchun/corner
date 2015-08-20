//
//  MyAccountTableViewController.m
//  corner
//
//  Created by yons on 15-7-13.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "MyAccountTableViewController.h"
#import "MyTableViewCell1.h"
#import "MyTableViewCell2.h"
#import "SVPullToRefresh.h"
#import "PayTypeViewController.h"


@interface MyAccountTableViewController ()

@end

@implementation MyAccountTableViewController{
    NSMutableArray *dataSource;
    NSDictionary *userinfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"refreshMyAccount"
                                               object:nil];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    self.title = @"我的账户";
    dataSource = [NSMutableArray array];
    
    __weak MyAccountTableViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    //初始化数据
    [self.tableView triggerPullToRefresh];
    
    [self.tableView setSeparatorColor:[UIColor lightGrayColor]];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

- (void)insertRowAtTop {
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadData];
    });
}

-(void)loadData{
    
    [dataSource removeAllObjects];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"1200金币" forKey:@"name"];
    [dic setObject:[NSNumber numberWithInt:12] forKey:@"price"];
    [dataSource addObject:dic];
    NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
    [dic2 setObject:@"3000金币" forKey:@"name"];
    [dic2 setObject:[NSNumber numberWithInt:30] forKey:@"price"];
    [dataSource addObject:dic2];
    NSMutableDictionary *dic3 = [NSMutableDictionary dictionary];
    [dic3 setObject:@"6000金币" forKey:@"name"];
    [dic3 setObject:[NSNumber numberWithInt:60] forKey:@"price"];
    [dataSource addObject:dic3];
    NSMutableDictionary *dic4 = [NSMutableDictionary dictionary];
    [dic4 setObject:@"10800金币" forKey:@"name"];
    [dic4 setObject:[NSNumber numberWithInt:108] forKey:@"price"];
    [dataSource addObject:dic4];
    NSMutableDictionary *dic5 = [NSMutableDictionary dictionary];
    [dic5 setObject:@"21800金币" forKey:@"name"];
    [dic5 setObject:[NSNumber numberWithInt:218] forKey:@"price"];
    [dataSource addObject:dic5];
    NSMutableDictionary *dic6 = [NSMutableDictionary dictionary];
    [dic6 setObject:@"51800金币" forKey:@"name"];
    [dic6 setObject:[NSNumber numberWithInt:518] forKey:@"price"];
    [dataSource addObject:dic6];
    NSMutableDictionary *dic7 = [NSMutableDictionary dictionary];
    [dic7 setObject:@"108000金币" forKey:@"name"];
    [dic7 setObject:[NSNumber numberWithInt:1080] forKey:@"price"];
    [dataSource addObject:dic7];
    
    
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@?token=%@",HOST,USER_DETAIL_URL,userid,token];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.tableView.pullToRefreshView stopAnimating];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                userinfo = [NSMutableDictionary dictionaryWithDictionary:[[dic objectForKey:@"message"] cleanNull] ];
                [self.tableView reloadData];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self.tableView.pullToRefreshView stopAnimating];
        [self showHint:@"连接失败"];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 110;
    }else if (indexPath.section == 1){
        return 90;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }else{
        return 0.1;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return [dataSource count];
            break;
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
    
        MyTableViewCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        NSString *coins = [userinfo objectForKey:@"coins"];
        if ([coins isEqualToString:@""]) {
            coins = @"0";
        }
        cell.coinsLabel.text = coins;
        return cell;
    }else if (indexPath.section == 1) {
        
        MyTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        NSDictionary *info = [dataSource objectAtIndex:indexPath.row];
        NSString *name = [info objectForKey:@"name"];
        NSNumber *price = [info objectForKey:@"price"];
        cell.label1.text = name;
        //        cell.label2.text = [NSString stringWithFormat:@"￥%d元",[price intValue]];
        
        [cell.payBtn setTitle:[NSString stringWithFormat:@"￥%d元",[price intValue]] forState:UIControlStateNormal];
        cell.payBtn.tag = indexPath.row+1;
        [cell.payBtn addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        PayTypeViewController *vc = [[PayTypeViewController alloc] init];
        vc.payInfo = [dataSource objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

-(void)pay:(UIButton *)sender{
    PayTypeViewController *vc = [[PayTypeViewController alloc] init];
    vc.payInfo = [dataSource objectAtIndex:sender.tag - 1];
    [self.navigationController pushViewController:vc animated:YES];
}




@end
