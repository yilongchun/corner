//
//  VIPTableViewController.m
//  corner
//
//  Created by yons on 15-8-10.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "VIPTableViewController.h"
#import "MyAccountTableViewCell1.h"
#import "MyAccountTableViewCell2.h"
#import "SVPullToRefresh.h"
#import "PayTypeViewController.h"
#import "RESideMenu.h"

@interface VIPTableViewController ()

@end

@implementation VIPTableViewController{
    NSMutableArray *dataSource;
    NSDictionary *userinfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *image = [[UIImage imageNamed:@"leftMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"refreshMyAccount"
                                               object:nil];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    self.title = @"VIP专区";
    dataSource = [NSMutableArray array];
    
    __weak VIPTableViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    //初始化数据
    [self.tableView triggerPullToRefresh];
    
    [self.tableView setSeparatorColor:[UIColor lightGrayColor]];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
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

-(void)loadData{
    
    [dataSource removeAllObjects];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"蓝钻VIP" forKey:@"name"];
    [dic setObject:@"每天赠送10把钥匙" forKey:@"msg1"];
    [dic setObject:@"VIP时长90天" forKey:@"msg2"];
    [dic setObject:[NSNumber numberWithInt:12800] forKey:@"price"];
    [dataSource addObject:dic];
    NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
    [dic2 setObject:@"绿钻VIP" forKey:@"name"];
    [dic2 setObject:@"每天赠送12把钥匙" forKey:@"msg1"];
    [dic2 setObject:@"VIP时长180天" forKey:@"msg2"];
    [dic2 setObject:[NSNumber numberWithInt:18800] forKey:@"price"];
    [dataSource addObject:dic2];
    NSMutableDictionary *dic3 = [NSMutableDictionary dictionary];
    [dic3 setObject:@"粉钻VIP" forKey:@"name"];
    [dic3 setObject:@"每天赠送20把钥匙" forKey:@"msg1"];
    [dic3 setObject:@"VIP时长一年" forKey:@"msg2"];
    [dic3 setObject:[NSNumber numberWithInt:26800] forKey:@"price"];
    [dataSource addObject:dic3];
    NSMutableDictionary *dic4 = [NSMutableDictionary dictionary];
    [dic4 setObject:@"黄钻VIP" forKey:@"name"];
    [dic4 setObject:@"每天赠送30把钥匙" forKey:@"msg1"];
    [dic4 setObject:@"VIP时长两年" forKey:@"msg2"];
    [dic4 setObject:[NSNumber numberWithInt:38800] forKey:@"price"];
    [dataSource addObject:dic4];
    
    
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
    //    if (indexPath.section == 0) {
    //        return 90;
    //    }else if (indexPath.section == 1){
    if (indexPath.row == 0) {
        return 105;
    }else{
        return 95;
    }
    
    //    }
    //    return 0;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (section == 0) {
//        return 0.1;
//    }else{
//        return 0.1;
//    }
//
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    switch (section) {
    //        case 0:
    //            return 1;
    //            break;
    //        case 1:
    return [dataSource count] + 1;
    //            break;
    //        default:
    //            return 0;
    //            break;
    //    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    if (indexPath.section == 0) {
    if (indexPath.row == 0) {
        MyAccountTableViewCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        NSString *coins = [userinfo objectForKey:@"coins"];
        if ([coins isEqualToString:@""]) {
            coins = @"0";
        }
        cell.coinsLabel.text = coins;
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:cell.titleLabel.text];
        [str addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(226, 82, 69, 1) range:NSMakeRange(2,3)];
        cell.titleLabel.attributedText = str;
        return cell;
    }else{
        MyAccountTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        NSDictionary *info = [dataSource objectAtIndex:indexPath.row - 1];
        NSString *name = [info objectForKey:@"name"];
        NSString *msg1 = [info objectForKey:@"msg1"];
        NSString *msg2 = [info objectForKey:@"msg2"];
        NSNumber *price = [info objectForKey:@"price"];
        cell.label1.text = name;
        cell.msg1.text = msg1;
        cell.msg2.text = msg2;
        [cell.payBtn setTitle:[NSString stringWithFormat:@"%d金币",[price intValue]] forState:UIControlStateNormal];
        cell.payBtn.tag = indexPath.row - 1;
        [cell.payBtn addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
        
        switch (indexPath.row - 1) {
            case 0:
                cell.conisImage.image = [UIImage imageNamed:@"vip1-1"];
                [cell.hotsellImage setHidden:YES];
                break;
            case 1:
                cell.conisImage.image = [UIImage imageNamed:@"vip2-1"];
                [cell.hotsellImage setHidden:YES];
                break;
            case 2:
                cell.conisImage.image = [UIImage imageNamed:@"vip3"];
                break;
            case 3:
                cell.conisImage.image = [UIImage imageNamed:@"vip4"];
                break;
            default:
                break;
        }
        
        
        return cell;
    }
    
    
    //    }else if (indexPath.section == 1) {
    
    //    }
    //    return nil;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > 0) {
//        PayTypeViewController *vc = [[PayTypeViewController alloc] init];
//        vc.payInfo = [dataSource objectAtIndex:indexPath.row - 1];
//        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

-(void)pay:(UIButton *)sender{
//    PayTypeViewController *vc = [[PayTypeViewController alloc] init];
//    vc.payInfo = [dataSource objectAtIndex:sender.tag];
//    [self.navigationController pushViewController:vc animated:YES];
}

@end
