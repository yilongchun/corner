//
//  CallTableViewController.m
//  corner
//
//  Created by yons on 15-7-14.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "CallTableViewController.h"
#import "SVPullToRefresh.h"
#import "CallTableViewCell.h"
#import "RESideMenu.h"
#import "CallLogViewController.h"

@interface CallTableViewController ()

@end

@implementation CallTableViewController{
    NSMutableArray *dataSource;
    int page;
    NSMutableDictionary *userinfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainbackground"]];
    self.tableView.backgroundView = view;
    
    UIImage *image = [[UIImage imageNamed:@"leftMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIImage *image2 = [[UIImage imageNamed:@"callItem"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:image2 style:UIBarButtonItemStyleDone target:self action:@selector(rightMenu)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.title = @"call她";
    dataSource = [NSMutableArray array];
    
    [self.tableView setSeparatorColor:[UIColor lightGrayColor]];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    __weak CallTableViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    
    //初始化数据
    [self.tableView triggerPullToRefresh];
}

- (void)insertRowAtTop {
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadUser];
    });
}

-(void)insertRowAtBottom{
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadMore];
    });
}

-(void)loadUser{
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
                [self loadData];
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

-(void)loadData{
    page = 1;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%d",HOST,USER_PHONE_URL,page];
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
        [self.tableView.pullToRefreshView stopAnimating];
        [self showHint:@"连接失败"];
        
    }];
}

/**
 *  加载更多
 */
-(void)loadMore{
    page++;
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%d",HOST,USER_PHONE_URL,page];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.tableView.infiniteScrollingView stopAnimating];
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
                    [self.tableView reloadData];
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
        [self.tableView.infiniteScrollingView stopAnimating];
        [self showHint:@"连接失败"];
        
    }];
}

-(void)leftMenu{
    [self.sideMenuViewController presentLeftMenuViewController];    
}

-(void)rightMenu{
    CallLogViewController *vc = [[CallLogViewController alloc] init];
    vc.title = @"通话记录";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 85;
    }
    return 70;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell1" forIndexPath:indexPath];
        return cell;
    }else{
        CallTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell2" forIndexPath:indexPath];
        NSDictionary *info = [[dataSource objectAtIndex:indexPath.row - 1] cleanNull];
        NSString *nickname = [info objectForKey:@"nickname"];
        NSNumber *userid = [info objectForKey:@"id"];
        NSString *avatar_url = [info objectForKey:@"avatar_url"];
        
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
        
        [cell.userImage setImageWithURL:[NSURL URLWithString:avatar_url] placeholderImage:[UIImage imageNamed:@"public_load_face"]];
        cell.userImage.layer.cornerRadius = 25.0f;
        cell.userImage.layer.masksToBounds = YES;
        cell.userImage.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.userImage.layer.borderWidth = 1.0f;
        NSString *name;
        if ([nickname isEqualToString:@""]) {
            name = [userid stringValue];
        }else{
            name = nickname;
        }
        
        cell.nameLabel.text = name;
        //[cell.callBtn setBackgroundImage:[[UIImage imageNamed:@"restaurant_btn_bg2"] stretchableImageWithLeftCapWidth:17 topCapHeight:15] forState:UIControlStateNormal];
        cell.callBtn.tag = indexPath.row - 1;
        [cell.callBtn addTarget:self action:@selector(call:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
}

-(void)call:(UIButton *)sender{
    
    NSNumber *type = [userinfo objectForKey:@"type"];
    if ([type intValue] >=10) {
        NSDictionary *info = [[dataSource objectAtIndex:sender.tag] cleanNull];
        NSString *dst = [info objectForKey:@"phone"];
        
        NSString *src = [userinfo objectForKey:@"phone"];
        if (src == nil || (src != nil && [src isEqualToString:@""])) {
            [self showHint:@"请先填写手机号码再拨打电话"];
            return;
        }
        if (dst == nil || (dst != nil && [dst isEqualToString:@""])) {
            [self showHint:@"对方未填写手机号码，拨打失败"];
            return;
        }
        [self showHudInView:self.view hint:@"拨打中，请稍后"];
        
        NSString *url = [NSString stringWithFormat:@"http://42.121.87.117:8084/2013/interface/data/call.php?action=asyn_callout&verifymethod=pwd&loginid=867600310&loginpwd=8f4536db3b4c130545b08f841154c4de&src=%@&dst=%@&ringback=1",src,dst];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", operation.responseString);
            [self hideHud];
            
            NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
            NSError *error;
            NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
            if (dic == nil) {
                NSLog(@"json parse failed \r\n");
            }else{
                NSString *errorcode = [dic objectForKey:@"errorcode"];
                if ([errorcode isEqualToString:@"0"]) {
                    [self showHint:@"拨打成功，请稍后接听电话"];
                }else{
                    [self showHint:@"拨打失败"];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self hideHud];
            NSLog(@"发生错误！%@",error);
            [self showHint:@"连接失败"];
        }];
    }else{
        NSString *msg = [NSString stringWithFormat:@"您不是VIP，无法拨打电话"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}

@end
