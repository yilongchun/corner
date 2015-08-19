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
#import "NSDate+Extension.h"


@implementation WodezhuanjiaoViewController{
    NSMutableArray *dataSource;
    
    //NSInteger currentType;//type: 0 关注,1 同城,2 推荐
    
    int page;//分页设置
    
    int tempIndex;
    UIImage *smallImage;
}
@synthesize currentType;

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    currentType = 0;
    
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
    
    UIImage *image = [[UIImage imageNamed:@"leftMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.mytableview setTableFooterView:v];
    
    
    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 43)];
//    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn1.tag = 0;
//    [btn1 setTitle:@"关注" forState:UIControlStateNormal];
//    [btn1 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    btn1.titleLabel.font = [UIFont systemFontOfSize:13];
//    [btn1 setFrame:CGRectMake(0, 0, view.frame.size.width / 3, view.frame.size.height - 3)];
//    [btn1 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn2.tag = 1;
//    [btn2 setTitle:@"同城" forState:UIControlStateNormal];
//    [btn2 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    btn2.titleLabel.font = [UIFont systemFontOfSize:13];
//    [btn2 setFrame:CGRectMake(btn1.frame.size.width, 0, view.frame.size.width / 3, view.frame.size.height - 3)];
//    [btn2 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn3.tag = 2;
//    [btn3 setTitle:@"推荐" forState:UIControlStateNormal];
//    [btn3 setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    btn3.titleLabel.font = [UIFont systemFontOfSize:13];
//    [btn3 setFrame:CGRectMake(btn1.frame.size.width + btn2.frame.size.width, 0, view.frame.size.width / 3, view.frame.size.height - 3)];
//    [btn3 addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [view addSubview:btn1];
//    [view addSubview:btn2];
//    [view addSubview:btn3];
//    
//    self.mytableview.tableHeaderView = view;
    
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
    
    if ([self.mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.mytableview setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    if ([self.mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.mytableview setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
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
    [parameters setValue:[NSNumber numberWithInt:currentType] forKey:@"type"];
    
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
                NSArray *arr = [dic objectForKey:@"message"];
                if ([arr count] > 0) {
                    [dataSource addObjectsFromArray:arr];
                    [self.mytableview reloadData];
                }else{
                    [self showHint:@"没有查询到数据"];
                }
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
    [parameters setValue:[NSNumber numberWithInt:currentType] forKey:@"type"];
    
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
        [self.mytableview.infiniteScrollingView stopAnimating];
        [self showHint:@"连接失败"];
        
    }];
}

//-(void)btnClick:(UIButton *)sender{
//    if (sender.tag != currentType) {
//        currentType = sender.tag;
//        [self loadData];
//    }
//    
//}

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
    
    NSDictionary *user = [[info objectForKey:@"user"] cleanNull];
    NSString *avatar_url = [user objectForKey:@"avatar_url"];
    NSString *nickname = [user objectForKey:@"nickname"];
    NSNumber *userid = [user objectForKey:@"id"];
    if (![avatar_url isEqualToString:@""]) {
        [cell.userImage setImageWithURL:[NSURL URLWithString:avatar_url]];
    }
    if (![nickname isEqualToString:@""]) {
        cell.username.text = nickname;
    }else{
        cell.username.text = [userid stringValue];
    }
    
    NSString *pic_url = [info objectForKey:@"pic_url"];
    NSString *post_body = [info objectForKey:@"post_body"];
//    NSNumber *status = [info objectForKey:@"status"];
//    NSNumber *user_id = [info objectForKey:@"user_id"];
    
    NSString *created_at = [info objectForKey:@"created_at"];
    
    if (![created_at isEqualToString:@""]) {
        NSString *timeInfoWithDateString = [NSDate timeInfoWithDateString:created_at];
        cell.dateLabel.text = timeInfoWithDateString;
    }else{
        [cell.dateLabel setHidden:YES];
    }
   
    if (![pic_url hasSuffix:@"post.jpg"] && ![pic_url isEqualToString:@""]) {
        cell.imgViewHeight.constant = 140;
        [cell.myimage setImageWithURL:[NSURL URLWithString:pic_url] placeholderImage:[UIImage imageNamed:@"placeholderImage"]];
    }else{
        cell.imgViewHeight.constant = 0;
    }
    
    cell.myimage.tag = indexPath.row;
    cell.myimage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
    [cell.myimage addGestureRecognizer:tap];
    
    
//    cell.username.text = [NSString stringWithFormat:@"%d",[user_id intValue]];
    if ([post_body isEqualToString:@""]) {
        post_body = @" ";
    }
    cell.msgLabel.text = post_body;
//    cell.msgLabel.numberOfLines = 0;
//    [cell.msgLabel sizeToFit];
    return cell;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 3)];
//    view.backgroundColor = RGBACOLOR(239, 239, 239, 1);
//    
//    CGFloat width = view.frame.size.width / 3;
//    CGFloat height = view.frame.size.height;
//    CGFloat margin = 20;
//    switch (currentType) {
//        case 0:
//        {
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0 + margin, 0, width - margin*2, height)];
//            label.backgroundColor = RGBACOLOR(245, 186, 0, 1);
//            [view addSubview:label];
//        }
//            break;
//        case 1:
//        {
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width + margin, 0, width - margin*2, height)];
//            label.backgroundColor = RGBACOLOR(245, 186, 0, 1);
//            [view addSubview:label];
//        }
//            break;
//        case 2:
//        {
//            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(width * 2 + margin, 0, width - margin*2, height)];
//            label.backgroundColor = RGBACOLOR(245, 186, 0, 1);
//            [view addSubview:label];
//        }
//            break;
//        default:
//            break;
//    }
//    
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 列寬
    CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width - 80 - 15;
    // 用何種字體進行顯示
    UIFont *font = [UIFont systemFontOfSize:15];
    // 該行要顯示的內容
    DLog(@"%@",[dataSource objectAtIndex:indexPath.row]);
    NSDictionary *info = [[dataSource objectAtIndex:indexPath.row] cleanNull];
    NSString *content = [info objectForKey:@"post_body"];
    // 計算出顯示完內容需要的最小尺寸
    CGSize textSize;
    if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
        textSize = [content boundingRectWithSize:CGSizeMake(contentWidth, MAXFLOAT)
                                         options:options
                                      attributes:attributes
                                         context:nil].size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        textSize = [content sizeWithFont:font
                       constrainedToSize:CGSizeMake(contentWidth, MAXFLOAT)
                           lineBreakMode:NSLineBreakByCharWrapping];
#pragma clang diagnostic pop
        
    }
    CGFloat height;
    if (textSize.height > 18) {
        height = textSize.height;
    }else{
        height = 18;
    }
    NSString *pic_url = [info objectForKey:@"pic_url"];
    if (![pic_url hasSuffix:@"post.jpg"] && ![pic_url isEqualToString:@""]) {
        return 257 - 18 + height;
    }else{
        return 257 - 18 + height - 140;
    }
    
    
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 3;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.mytableview setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    if ([self.mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.mytableview setLayoutMargins:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
}

//去掉UItableview headerview黏性(sticky)
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat sectionHeaderHeight = 3;
//    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
//}

/**
 *  发动态
 *
 *  @param sender
 */
- (IBAction)fadongtai:(id)sender {
    FabudongtaiViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"FabudongtaiViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)imageClick:(UITapGestureRecognizer *)recognizer
{
    tempIndex = recognizer.view.tag;
    UIImageView *imageview = (UIImageView *)recognizer.view;
    smallImage = imageview.image;
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.sourceImagesContainerView = recognizer.view.superview;//原图的父控件
    browser.imageCount = 1;//原图的数量
    browser.currentImageIndex = 0;//当前需要展示图片的index
    browser.delegate = self;
    [browser show]; // 展示图片浏览器
}

#pragma mark - photobrowser代理方法

// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return smallImage;
}


// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSDictionary *info = [[dataSource objectAtIndex:tempIndex] cleanNull];
    NSString *pic_url = [info objectForKey:@"pic_url"];
    return [NSURL URLWithString:pic_url];
}
@end
