//
//  ILikeCollectionViewController.m
//  corner
//
//  Created by yons on 15-6-1.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "ILikeCollectionViewController.h"
#import "ILikeCollectionViewCell.h"
#import "UserDetailTableViewController.h"
#import "SVPullToRefresh.h"

@interface ILikeCollectionViewController (){
    int type;
}

@end

@implementation ILikeCollectionViewController
@synthesize dataSource;

static NSString * const reuseIdentifier = @"ILikeCollectionViewCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    type = 0;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor yellowColor],NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:14],NSFontAttributeName, nil];
    NSDictionary *dic2 = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:14],NSFontAttributeName, nil];
    
    [self.myseg setTitleTextAttributes:dic forState:UIControlStateSelected];
    [self.myseg setTitleTextAttributes:dic2 forState:UIControlStateNormal];
    
    UIImage *image = [[UIImage imageNamed:@"kiss_top1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    __weak ILikeCollectionViewController *weakSelf = self;
    
    [self.collectionView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
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


//加载数据
-(void)loadData{
    
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[NSNumber numberWithInt:type] forKey:@"type"];
    [parameters setValue:token forKey:@"token"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,USER_CARE_URL];
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
                dataSource = [dic objectForKey:@"message"];
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

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ILikeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSDictionary *info = [[dataSource objectAtIndex:indexPath.row] cleanNull];
    NSString *avatar_url = [info objectForKey:@"avatar_url"];//头像
    [cell.myimageview setImageWithURL:[NSURL URLWithString:avatar_url] placeholderImage:[UIImage imageNamed:@"public_load_face"]];
    
    NSNumber *sex = [info objectForKey:@"sex"];
    NSString *address = [info objectForKey:@"address"];
    NSString *zhiye = [info objectForKey:@"zhiye"];
    NSString *shengao = [info objectForKey:@"shengao"];
    NSString *tizhong = [info objectForKey:@"tizhong"];
    NSString *age = [info objectForKey:@"age"];
    
    switch ([sex intValue]) {
        case 0:
            [cell.seximageview setImage:[UIImage imageNamed:@"pub_1_v1"]];
            break;
        case 1:
            [cell.seximageview setImage:[UIImage imageNamed:@"pub_2_v1"]];
            break;
        default:
            break;
    }
    cell.ageLabel.text = age;
    cell.addressLabel.text = address;
    
    NSMutableString *desc = [NSMutableString string];
    if (![zhiye isEqualToString:@""]) {
        [desc appendFormat:@"%@,",zhiye];
    }
    if (![shengao isEqualToString:@""]) {
        [desc appendFormat:@"%@cm,",shengao];
    }
    if (![tizhong isEqualToString:@""]) {
        [desc appendFormat:@"%@kg,",tizhong];
    }
    cell.descLabel.text = desc;
    
    return cell;
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 2) / 2;
    return CGSizeMake(width, width);
}


#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *userinfo = [[dataSource objectAtIndex:indexPath.row] cleanNull];
    NSString *nickname = [userinfo objectForKey:@"nickname"];
    //    NSString *name = [userinfo objectForKey:@"name"];
    UserDetailTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserDetailTableViewController"];
    vc.title = nickname;
    vc.userinfo = userinfo;
    [self.navigationController pushViewController:vc animated:YES];
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

-(void)leftMenu{
    [self.sideMenuViewController presentLeftMenuViewController];
    
}

- (IBAction)changeType:(UISegmentedControl *)sender {
    type = (int)sender.selectedSegmentIndex;
    [self loadData];
}
@end
