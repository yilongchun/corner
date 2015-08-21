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
    [parameters setValue:[NSNumber numberWithInt:1] forKey:@"groups"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,GIFT_LIST_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", operation.responseString);
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
    [parameters setValue:[NSNumber numberWithInt:1] forKey:@"groups"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,GIFT_LIST_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", operation.responseString);
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
    if (indexPath.row == 0) {
        return 105;
    }else{
        return 74;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //    if (indexPath.section == 0) {
    if (indexPath.row == 0) {
        MyAccountTableViewCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        NSNumber *coins = [userinfo objectForKey:@"coins"];
        if (coins != nil && [coins isKindOfClass:[NSNumber class]]) {
            cell.coinsLabel.text = [coins stringValue];
        }else{
            cell.coinsLabel.text = @"0";
        }
        
        
        NSNumber *type = [userinfo objectForKey:@"type"];
        if ([type intValue] >=10) {
            cell.vipMsgLabel.text = @"您是VIP用户";
            cell.vipMsgLabel.textColor = [UIColor whiteColor];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:cell.vipMsgLabel.text];
            [str addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(226, 82, 69, 1) range:NSMakeRange(2,3)];
            cell.vipMsgLabel.attributedText = str;
        }else{
            cell.vipMsgLabel.text = @"您当前不是VIP，升级VIP获取更多特权!";
            cell.vipMsgLabel.textColor = [UIColor lightGrayColor];

        }
        
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
        return cell;
    }
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
//        [self buyVip:indexPath.row - 1];
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
    
    NSNumber *type = [userinfo objectForKey:@"type"];
    if ([type intValue] >=10) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您已经是VIP，无需重复购买" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        NSDictionary *vipinfo = [dataSource objectAtIndex:index];
        NSNumber *vipid = [vipinfo objectForKey:@"id"];
        NSString *name = [vipinfo objectForKey:@"name"];//名称
        NSString *memo = [vipinfo objectForKey:@"memo"];//时长
        
        NSString *userid = [UD objectForKey:USER_ID];
        NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
        
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setValue:vipid forKey:@"gift_id"];
        [parameters setValue:token forKey:@"token"];
        NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,BUY_VIP_URL];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
        [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", operation.responseString);
            
            NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
            NSError *error;
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            if (dic == nil) {
                NSLog(@"json parse failed \r\n");
            }else{
                NSNumber *status = [dic objectForKey:@"status"];
                if ([status intValue] == 200) {
                    [self.tableView.header beginRefreshing];
                    NSString *msg = [NSString stringWithFormat:@"%@ 购买成功,VIP剩余时长 %@!",name,memo];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
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
}

@end
