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
#import "MJRefresh.h"
#import "PayTypeViewController.h"
#import "RESideMenu.h"

@interface VIPTableViewController ()

@end

@implementation VIPTableViewController{
    NSMutableArray *dataSource;
    NSDictionary *userinfo;
    int page;
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
    
    self.title = @"VIP专区";
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    [self.tableView setSeparatorColor:[UIColor lightGrayColor]];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    
    
    dataSource = [NSMutableArray array];
    
    // 添加下拉刷新控件
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData];
    }];
    // 添加下拉刷新控件
    self.tableView.footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
    
    [self.tableView.header beginRefreshing];
    
    
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
    
    
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    [dic setObject:@"蓝钻VIP" forKey:@"name"];
//    [dic setObject:@"每天赠送10把钥匙" forKey:@"msg1"];
//    [dic setObject:@"VIP时长90天" forKey:@"msg2"];
//    [dic setObject:[NSNumber numberWithInt:12800] forKey:@"price"];
//    [dataSource addObject:dic];
//    NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
//    [dic2 setObject:@"绿钻VIP" forKey:@"name"];
//    [dic2 setObject:@"每天赠送12把钥匙" forKey:@"msg1"];
//    [dic2 setObject:@"VIP时长180天" forKey:@"msg2"];
//    [dic2 setObject:[NSNumber numberWithInt:18800] forKey:@"price"];
//    [dataSource addObject:dic2];
//    NSMutableDictionary *dic3 = [NSMutableDictionary dictionary];
//    [dic3 setObject:@"粉钻VIP" forKey:@"name"];
//    [dic3 setObject:@"每天赠送20把钥匙" forKey:@"msg1"];
//    [dic3 setObject:@"VIP时长一年" forKey:@"msg2"];
//    [dic3 setObject:[NSNumber numberWithInt:26800] forKey:@"price"];
//    [dataSource addObject:dic3];
//    NSMutableDictionary *dic4 = [NSMutableDictionary dictionary];
//    [dic4 setObject:@"黄钻VIP" forKey:@"name"];
//    [dic4 setObject:@"每天赠送30把钥匙" forKey:@"msg1"];
//    [dic4 setObject:@"VIP时长两年" forKey:@"msg2"];
//    [dic4 setObject:[NSNumber numberWithInt:38800] forKey:@"price"];
//    [dataSource addObject:dic4];
    
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@?token=%@",HOST,USER_DETAIL_URL,userid,token];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                userinfo = [NSMutableDictionary dictionaryWithDictionary:[[dic objectForKey:@"message"] cleanNull] ];
                [self loadVipData];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self.tableView.header endRefreshing];
        [self showHint:@"连接失败"];
        
    }];
}
/**
 *  加载VIP信息
 */
-(void)loadVipData{
    page = 1;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [parameters setValue:@"1" forKey:@"group"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,GIFT_LIST_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.tableView.header endRefreshing];
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
                
                [self.tableView reloadData];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self.tableView.header endRefreshing];
        [self showHint:@"连接失败"];
    }];
}

-(void)loadMoreData{
    page++;
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    [parameters setValue:@"1" forKey:@"group"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,GIFT_LIST_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.tableView.footer endRefreshing];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                [dataSource addObjectsFromArray:[dic objectForKey:@"message"]];
                
                [self.tableView reloadData];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self.tableView.footer endRefreshing];
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
        return 74;
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
        
        NSDictionary *info = [[dataSource objectAtIndex:indexPath.row - 1] cleanNull];
        NSString *name = [info objectForKey:@"name"];//名称
        NSNumber *price = [info objectForKey:@"price"];//价格
        NSString *memo = [info objectForKey:@"memo"];//时长
        NSString *pic = [info objectForKey:@"pic"];
        
        MyAccountTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        
        cell.label1.text = name;
        cell.msg1.text = [NSString stringWithFormat:@"VIP时长%@",memo];
        [cell.payBtn setTitle:[NSString stringWithFormat:@"%d金币",[price intValue]] forState:UIControlStateNormal];
        [cell.payBtn setBackgroundImage:[[UIImage imageNamed:@"vippaybtn"] stretchableImageWithLeftCapWidth:37 topCapHeight:15] forState:UIControlStateNormal];
        cell.payBtn.tag = indexPath.row - 1;
        [cell.payBtn addTarget:self action:@selector(pay:) forControlEvents:UIControlEventTouchUpInside];
        [cell.conisImage setImageWithURL:[NSURL URLWithString:pic]];
//        switch (indexPath.row - 1) {
//            case 0:
//                cell.conisImage.image = [UIImage imageNamed:@"vip1-1"];
//                [cell.hotsellImage setHidden:YES];
//                break;
//            case 1:
//                cell.conisImage.image = [UIImage imageNamed:@"vip2-1"];
//                [cell.hotsellImage setHidden:YES];
//                break;
//            case 2:
//                cell.conisImage.image = [UIImage imageNamed:@"vip3"];
//                break;
//            case 3:
//                cell.conisImage.image = [UIImage imageNamed:@"vip4"];
//                break;
//            default:
//                break;
//        }
        
        
        return cell;
    }
    
    
    //    }else if (indexPath.section == 1) {
    
    //    }
    //    return nil;
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
    if (indexPath.row > 0) {
        [self buyVip:indexPath.row - 1];
    }
}
/**
 *  点击按钮
 *
 *  @param sender
 */
-(void)pay:(UIButton *)sender{
    [self buyVip:sender.tag];
}
/**
 *  购买VIP
 *
 *  @param index 索引
 */
-(void)buyVip:(int)index{
    NSDictionary *vipinfo = [dataSource objectAtIndex:index];
    DLog(@"%@",vipinfo);
}

@end
