//
//  CallLogViewController.m
//  corner
//
//  Created by yons on 15-8-25.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "CallLogViewController.h"
#import "MJRefresh.h"
#import "CallLogTableViewCell.h"

@interface CallLogViewController (){
    NSMutableArray *dataSource;
}

@end

@implementation CallLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    [self.mytableview setSeparatorColor:[UIColor lightGrayColor]];
    if ([self.mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.mytableview setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([self.mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.mytableview setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.mytableview.tableFooterView = v;
    
    
    dataSource = [NSMutableArray array];
    
    // 添加下拉刷新控件
    self.mytableview.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData];
    }];
    
    
    [self.mytableview.header beginRefreshing];
}

-(void)loadData{
    
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    NSString *urlString = [NSString stringWithFormat:@"%@/call/list?token=%@",HOST,token];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.mytableview.header endRefreshing];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                NSArray *arr = [dic objectForKey:@"message"];
                dataSource = [NSMutableArray arrayWithArray:arr];
                [self.mytableview reloadData];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self.mytableview.header endRefreshing];
        [self showHint:@"连接失败"];
        
    }];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *info = [[dataSource objectAtIndex:indexPath.row] cleanNull];
    NSString *cltime = [info objectForKey:@"cltime"];
    NSString *prov = [info objectForKey:@"prov"];
    NSString *city = [info objectForKey:@"city"];
    
    CallLogTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"callLogCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"CallLogTableViewCell" owner:self options:nil] lastObject];
        cell.imgview.layer.masksToBounds = YES;
        cell.imgview.layer.cornerRadius = 25;
    }
    cell.dateLabel.text = cltime;
    cell.addressLabel.text = [NSString stringWithFormat:@"%@%@",prov,city];
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.mytableview setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([self.mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.mytableview setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
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
