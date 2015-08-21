//
//  GiveGiftTableViewController.m
//  corner
//
//  Created by yons on 15-7-13.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "GiveGiftViewController.h"
#import "SVPullToRefresh.h"
#import "LiwuTableViewCell.h"
#import "LiwuTableViewCell2.h"

@interface GiveGiftViewController ()

@end

@implementation GiveGiftViewController{
    int page;//分页设置
    NSMutableArray *dataSource;
    NSMutableDictionary *userinfo;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    self.title = @"赠送礼物";
    
    dataSource = [NSMutableArray array];
    
    __weak GiveGiftViewController *weakSelf = self;
    
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
        [self.mytableview.pullToRefreshView stopAnimating];
        [self showHint:@"连接失败"];
        
    }];
}

/**
 *  初始化 加载数据
 */
-(void)loadData{
    page = 1;
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithInt:page] forKey:@"page"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,GIFT_LIST_URL];
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
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,GIFT_LIST_URL];
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

-(void)viewDidLayoutSubviews
{
    if ([self.mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.mytableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.mytableview setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 70;
    }else if (indexPath.row == 1){
        return 70;
    }
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count] + 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"yuecell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"yuecell"];
            cell.backgroundColor = [UIColor clearColor];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        
        NSNumber *coins = [userinfo objectForKey:@"coins"];
        if (coins != nil && [coins isKindOfClass:[NSNumber class]]) {
            cell.textLabel.text = [NSString stringWithFormat:@"金币余额：%@金币",[coins stringValue]];
        }else{
            cell.textLabel.text = @"金币余额：0金币";
        }
        
        
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        return cell;
    }else if (indexPath.row == 1) {
        LiwuTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
        
        cell.userImage.layer.masksToBounds = YES;
        cell.userImage.layer.cornerRadius = 25;
        cell.userImage.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.userImage.layer.borderWidth = 0.5f;
        
        cell.userMsg.text = [NSString stringWithFormat:@"给 %@ 送礼",_receive_user_name];
        [cell.userImage setImageWithURL:[NSURL URLWithString:self.avatar_url]];
        
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:cell.userMsg.text];
        [str addAttribute:NSForegroundColorAttributeName value:RGBACOLOR(255, 127, 0, 1) range:NSMakeRange(2,_receive_user_name.length)];
        cell.userMsg.attributedText = str;
        
        return cell;
    }else{
        LiwuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"liwucell" forIndexPath:indexPath];
        
        NSDictionary *info = [[dataSource objectAtIndex:indexPath.row - 2] cleanNull];
        NSString *name = [info objectForKey:@"name"];
        NSNumber *price = [info objectForKey:@"price"];
        NSNumber *lovers = [info objectForKey:@"lovers"];
        NSString *pic = [info objectForKey:@"pic"];
        cell.giftName.text = name;
        cell.giftPrice.text = [NSString stringWithFormat:@"价格：%d金币",[price intValue]];
        cell.giftLovers.text = [NSString stringWithFormat:@"+%d魅力",[lovers intValue]];
        [cell.giveBtn setBackgroundImage:[[UIImage imageNamed:@"vippaybtn"] stretchableImageWithLeftCapWidth:37 topCapHeight:15] forState:UIControlStateNormal];
        cell.giveBtn.tag = indexPath.row - 2;
        [cell.giveBtn addTarget:self action:@selector(giveGift:) forControlEvents:UIControlEventTouchUpInside];
        [cell.giftImage setImageWithURL:[NSURL URLWithString:pic]];
        return cell;
    }
}

-(void)giveGift:(UIButton *)sender{
    
    NSDictionary *gift = [[dataSource objectAtIndex:sender.tag] cleanNull];
    NSNumber *giftId = [gift objectForKey:@"id"];
    
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:giftId forKey:@"gift_id"];
    [parameters setObject:_receive_user_id forKey:@"receive_user_id"];
    [parameters setObject:token forKey:@"token"];
    [self showHudInView:self.view hint:@"加载中"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,GIFT_GIVE_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self hideHud];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                
                NSDictionary *message = [[dic objectForKey:@"message"] cleanNull];
                NSString *gift_name = [message objectForKey:@"gift_name"];
                NSNumber *gift_lovers =[message objectForKey:@"gift_lovers"];
                
                NSString *msg = [NSString stringWithFormat:@"赠送 %@ 给 %@ 增加 %d 魅力值",gift_name,_receive_user_name,[gift_lovers intValue]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
                
                [self loadUser];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self hideHud];
        NSLog(@"发生错误！%@",error);
        [self showHint:@"连接失败"];
    }];
}

@end
