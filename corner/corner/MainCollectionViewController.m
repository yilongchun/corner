//
//  MainCollectionViewController.m
//  corner
//
//  Created by yons on 15-4-30.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "MainCollectionViewController.h"
#import "MyCollectionViewCell.h"
#import "MyCollectionReusableView.h"
#import "UserDetailTableViewController.h"

#import "SVPullToRefresh.h"

@interface MainCollectionViewController (){
    int page;//分页设置
    int near_close;//是否按照离我最近排序(1 是,0 否)
    int sex;// 性别(0 男,1 女)
    NSString *address;// 地区
}

@end

@implementation MainCollectionViewController
@synthesize dataSource;

static NSString * const reuseIdentifier = @"MyCollectionViewCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    UIImage *image = [[UIImage imageNamed:@"kiss_top1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    // Register cell classes
//    [self.collectionView registerClass:[MyCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    
    // Do any additional setup after loading the view.
    page = 1;
    near_close = 1;
    sex = 0;
    address = @"";
    dataSource = [NSMutableArray array];
    
    __weak MainCollectionViewController *weakSelf = self;
    
    [self.collectionView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    //初始化数据
    [self.collectionView triggerPullToRefresh];
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
    
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:[NSNumber numberWithInt:near_close] forKey:@"near_close"];
    [parameters setValue:[NSNumber numberWithInt:sex] forKey:@"sex"];
    [parameters setValue:address forKey:@"address"];
    
//    [self showHudInView:self.view hint:@"加载中"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%d",HOST,USER_LIST_URL,page];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.collectionView.pullToRefreshView stopAnimating];
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
               
                [self.collectionView reloadData];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self.collectionView.pullToRefreshView stopAnimating];
        [self showHint:@"连接失败"];
        
    }];
}

/**
 *  加载更多
 */
-(void)loadMore{
    
    page++;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    [parameters setValue:[NSNumber numberWithInt:near_close] forKey:@"near_close"];
    [parameters setValue:[NSNumber numberWithInt:sex] forKey:@"sex"];
    [parameters setValue:address forKey:@"address"];
    
    //    [self showHudInView:self.view hint:@"加载中"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%d",HOST,USER_LIST_URL,page];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.collectionView.infiniteScrollingView stopAnimating];
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
                    [self.collectionView reloadData];
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
        [self.collectionView.infiniteScrollingView stopAnimating];
        [self showHint:@"连接失败"];
    }];
}

-(void)leftMenu{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    
//    MyCollectionReusableView *headView;
//    if([kind isEqual:UICollectionElementKindSectionHeader])
//    {
//        headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
//        NSArray *arr = @[@"湖北",@"女"];
//        NSString *str = [arr componentsJoinedByString:@"・"];
//        headView.sctionLabel.text = str;
//        headView.sctionLabel.textColor = [UIColor colorWithWhite:0 alpha:0.7];
//    }
//    return headView;
//}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    CGSize size = {self.collectionView.frame.size.width, 25};
//    return size;
//}


#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MyCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
//    cell.backgroundColor = [UIColor redColor];
    // Configure the cell
    
    NSDictionary *info = [[dataSource objectAtIndex:indexPath.row] cleanNull];
    NSString *avatar_url = [info objectForKey:@"avatar_url"];//头像
    NSString *nickname = [info objectForKey:@"nickname"];
    NSNumber *sexnum = [info objectForKey:@"sex"];
    [cell.myimageview setImageWithURL:[NSURL URLWithString:avatar_url] placeholderImage:[UIImage imageNamed:@"public_load_face"]];
    cell.nickname.text = nickname;
    
    
    switch ([sexnum intValue]) {
        case 0:
            [cell.seximageview setImage:[UIImage imageNamed:@"ico_man"]];
            break;
        case 1:
            [cell.seximageview setImage:[UIImage imageNamed:@"ico_woman"]];
            break;
        default:
            break;
    }
    
//    cell.backgroundColor = [UIColor colorWithRed:239/255. green:239/255. blue:239/255. alpha:1];
//    [cell.myimageview setBackgroundColor:[UIColor grayColor]];
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 4) / 3;
    return CGSizeMake(width, width);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *userinfo = [[dataSource objectAtIndex:indexPath.row] cleanNull];
    NSString *nickname = [userinfo objectForKey:@"nickname"];
//    NSString *name = [userinfo objectForKey:@"name"];
    UserDetailTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserDetailTableViewController"];
    vc.title = nickname;
    vc.userinfo = userinfo;
    [self.navigationController pushViewController:vc animated:YES];
}





@end
