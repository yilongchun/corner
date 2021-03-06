//
//  DongtaiTableViewController.m
//  corner
//
//  Created by yons on 15-6-9.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "DongtaiTableViewController.h"
#import "DongtaiTableViewCell.h"
#import "DongtaiTableViewCellAdd.h"
#import "FabudongtaiViewController.h"
#import "SVPullToRefresh.h"
#import "DongtaiTableViewCellOther.h"
#import "NSDate+Extension.h"
#import "MLPhotoBrowserViewController.h"

@interface DongtaiTableViewController (){
    int page;//分页设置
    NSMutableArray *dataSource;
}

@end

@implementation DongtaiTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"loadDongTai"
                                               object:nil];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    dataSource = [NSMutableArray array];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    __weak DongtaiTableViewController *weakSelf = self;
    
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
    
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@/%d",HOST,POST_USER_LIST_URL,self.userid,page];
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
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@/%d",HOST,POST_USER_LIST_URL,self.userid,page];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            NSString *userid = [UD objectForKey:USER_ID];
            if ([userid intValue] == [self.userid intValue]) {//自己
                return 140;
            }else{
                return 70;
            }
        }
            break;
            
        default:
        {
            NSDictionary *info = [[dataSource objectAtIndex:indexPath.row - 1] cleanNull];
            NSString *post_body = [info objectForKey:@"post_body"];
            NSString *pic_url = [info objectForKey:@"pic_url"];//头像
            
            CGFloat labelWidth = ([UIScreen mainScreen].bounds.size.width - 58 - 8);
    
            UIFont *font = [UIFont systemFontOfSize:14];
            CGSize textSize;
            if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                //[paragraphStyle setLineSpacing:5];//调整行间距
                NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
                textSize = [post_body boundingRectWithSize:CGSizeMake(labelWidth, MAXFLOAT)
                                                     options:options
                                                  attributes:attributes
                                                     context:nil].size;
                
                
            }
            CGFloat height = 25 + textSize.height + 8 + 15 + 8;
            if (![pic_url hasSuffix:@"post.jpg"]) {//有图片
                height = height + 150 + 8;
            }
            return height;
        }
            
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count] + 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        
        NSString *userid = [UD objectForKey:USER_ID];
        if ([userid intValue] == [self.userid intValue]) {//自己
            DongtaiTableViewCellAdd *cell = [tableView dequeueReusableCellWithIdentifier:@"dongtaicell2"];
            return cell;
        }else{
            DongtaiTableViewCellOther *cell = [tableView dequeueReusableCellWithIdentifier:@"dongtaicell3"];
            
            [cell.userImage setImageWithURL:[NSURL URLWithString:_avatar_url] placeholderImage:[UIImage imageNamed:@"public_load_face"]];
            
            cell.nameLabel.text = _nickname;
            
            
            switch ([_sexnum intValue]) {
                case 0:
                    [cell.sexImage setImage:[UIImage imageNamed:@"pub_boy_v1"]];
                    break;
                case 1:
                    [cell.sexImage setImage:[UIImage imageNamed:@"pub_girl_v1"]];
                    break;
                default:
                    break;
            }
            
            if ([_birthday isEqualToString:@"1900-01-01"]) {
                [cell.sexImage setHidden:YES];
            }else{
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *date= [dateFormatter dateFromString:_birthday];
                NSInteger age = [NSDate ageWithDateOfBirth:date];
                cell.ageLabel.text = [NSString stringWithFormat:@"%ld",(long)age];
            }
            return cell;
        }
        
        
    }else{
        DongtaiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dongtaicell"];
        
        NSDictionary *info = [[dataSource objectAtIndex:indexPath.row - 1] cleanNull];
        NSString *post_body = [info objectForKey:@"post_body"];
        NSString *updated_at = [info objectForKey:@"updated_at"];
        NSString *pic_url = [info objectForKey:@"pic_url"];
        cell.msgLabel.text = post_body;
        cell.dateLabel.text = updated_at;
        
        
        
        if ([pic_url hasSuffix:@"post.jpg"]) {//没有图片
            cell.imageWidth.constant = 0;
            cell.dateToTopHeight.constant = 0;
        }else{
            cell.imageWidth.constant = 150;
            [cell.userimage setImageWithURL:[NSURL URLWithString:pic_url] placeholderImage:[UIImage imageNamed:@"public_load"]];
            cell.userimage.contentMode = UIViewContentModeScaleToFill;
            cell.userimage.userInteractionEnabled = YES;
            cell.userimage.tag = indexPath.row;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPic:)];
            [cell.userimage addGestureRecognizer:tap];
        }
        
        NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
        
        [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *inputDate = [inputFormatter dateFromString:updated_at];
        
        
        
        cell.leftDateLabel.text = [NSString stringWithFormat:@"%2lu",(unsigned long)[inputDate day]];
        cell.leftDateLabel2.text = [NSString stringWithFormat:@"%2lu",(unsigned long)[inputDate month]];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        {
            UINavigationController *nc =  [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FabudongtaiViewController"]];
            nc.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
            nc.navigationBar.tintColor = [UIColor whiteColor];
            [nc.navigationBar setTitleTextAttributes:
             @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
               NSForegroundColorAttributeName:[UIColor whiteColor]}];
            [self presentViewController:nc animated:YES completion:nil];
            
            
//            FabudongtaiViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FabudongtaiViewController"];
//            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        default:
            
            break;
    }
}


/**
 *  点击图片查看大图
 */
-(void)showPic:(UITapGestureRecognizer *)recognizer{



    // 图片游览器
    MLPhotoBrowserViewController *photoBrowser = [[MLPhotoBrowserViewController alloc] init];
    // 缩放动画
    photoBrowser.status = UIViewAnimationAnimationStatusFade;
    // 可以删除
    photoBrowser.editing = NO;
    // 数据源/delegate
    //    photoBrowser.delegate = self;
    // 同样支持数据源/DataSource
    //                    photoBrowser.dataSource = self;
    
    
    NSDictionary *info = [[dataSource objectAtIndex:recognizer.view.tag - 1] cleanNull];
    NSString *pic_url = [info objectForKey:@"pic_url"];
    
    MLPhotoBrowserPhoto *photo = [[MLPhotoBrowserPhoto alloc] init];
    photo.photoURL = [NSURL URLWithString:pic_url];
    
    
    
    photoBrowser.photos = @[photo];
    
    // 当前选中的值
    photoBrowser.currentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    // 展示控制器
    [photoBrowser showPickerVc:self];
}
@end
