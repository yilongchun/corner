//
//  TongchengyaoyueViewController.m
//  corner
//
//  Created by yons on 15-5-4.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "TongchengyaoyueViewController.h"
#import "TongchengyaoyueTableViewCell.h"
#import "DOPDropDownMenu.h"

@interface TongchengyaoyueViewController ()<DOPDropDownMenuDataSource, DOPDropDownMenuDelegate, UITableViewDataSource>
@property (nonatomic, copy) NSArray *citys;
@property (nonatomic, copy) NSArray *ages;
@property (nonatomic, copy) NSArray *genders;
@property (nonatomic, copy) NSArray *originalArray;
@property (nonatomic, copy) NSArray *results;

//@property (nonatomic, strong) UITableView *tableView;

@end

@implementation TongchengyaoyueViewController

static NSString * const reuseIdentifier = @"MyCollectionViewCell";
//static TongchengyaoyueViewController *sharedObj = nil; //第一步：静态实例，并初始化。
//
//+ (TongchengyaoyueViewController *) sharedInstance  //第二步：实例构造检查静态实例是否为nil
//{
//    @synchronized (self)
//    {
//        if (sharedObj == nil)
//        {
//            sharedObj = [[self alloc] init];
//        }
//    }
//    return sharedObj;
//}
//
//+ (id) allocWithZone:(NSZone *)zone //第三步：重写allocWithZone方法
//{
//    @synchronized (self) {
//        if (sharedObj == nil) {
//            sharedObj = [super allocWithZone:zone];
//            return sharedObj;
//        }
//    }
//    return nil;
//}
//- (id) copyWithZone:(NSZone *)zone //第四步
//{
//    return self;
//}
//- (id)init
//{
//    @synchronized(self) {
//        self = [super init];//往往放一些要初始化的变量.
//        return self;
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (kCurrentSystemVersion > 6.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        
    }
    
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
//        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:38/255. green:38/255. blue:38/255. alpha:1]];
//        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
//    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    UIImage *image = [[UIImage imageNamed:@"kiss_top1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    
    
//    self.navigationItem.title = NSLocalizedString(@"navbar_title", @"the navigation bar title");
    self.citys = @[NSLocalizedString(@"city1", @"city1"),
                   NSLocalizedString(@"city2", @"city2"),
                   NSLocalizedString(@"city3", @"city3")];
    self.ages = @[NSLocalizedString(@"age", @"age"), @"20", @"30"];
    self.genders = @[NSLocalizedString(@"gender1", @"gender1"),
                     NSLocalizedString(@"gender2", @"gender2"),
                     NSLocalizedString(@"gender3", @"gender3")];
    self.originalArray = @[[NSString stringWithFormat:@"%@_%@_%@",self.citys[1],self.ages[1],self.genders[1]],
                           [NSString stringWithFormat:@"%@_%@_%@",self.citys[1],self.ages[1],self.genders[2]],
                           [NSString stringWithFormat:@"%@_%@_%@",self.citys[1],self.ages[2],self.genders[1]],
                           [NSString stringWithFormat:@"%@_%@_%@",self.citys[1],self.ages[2],self.genders[2]],
                           [NSString stringWithFormat:@"%@_%@_%@",self.citys[2],self.ages[1],self.genders[1]],
                           [NSString stringWithFormat:@"%@_%@_%@",self.citys[2],self.ages[1],self.genders[2]],
                           [NSString stringWithFormat:@"%@_%@_%@",self.citys[2],self.ages[2],self.genders[1]],
                           [NSString stringWithFormat:@"%@_%@_%@",self.citys[2],self.ages[2],self.genders[2]]];
    self.results = self.originalArray;
    
    DOPDropDownMenu *menu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0, 64) andHeight:40];
    menu.dataSource = self;
    menu.delegate = self;
    [self.view addSubview:menu];
    
//    self.tableView = ({
//        CGSize screenSize = [UIScreen mainScreen].bounds.size;
//        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 104, screenSize.width, screenSize.height - 104)];
//        tableView.dataSource = self;
//        [self.view addSubview:tableView];
//        tableView;
//    });
}

-(void)leftMenu{
    [self.sideMenuViewController presentLeftMenuViewController];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu {
    return 3;
}

- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column {
    return 3;
}

- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath {
    switch (indexPath.column) {
        case 0: return self.citys[indexPath.row];
            break;
        case 1: return self.genders[indexPath.row];
            break;
        case 2: return self.ages[indexPath.row];
            break;
        default:
            return nil;
            break;
    }
}

- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath {
    NSLog(@"column:%li row:%li", (long)indexPath.column, (long)indexPath.row);
    NSLog(@"%@",[menu titleForRowAtIndexPath:indexPath]);
    NSString *title = [menu titleForRowAtIndexPath:indexPath];
    
    static NSString *prediStr1 = @"SELF LIKE '*'",
    *prediStr2 = @"SELF LIKE '*'",
    *prediStr3 = @"SELF LIKE '*'";
    switch (indexPath.column) {
        case 0:{
            if (indexPath.row == 0) {
                prediStr1 = @"SELF LIKE '*'";
            } else {
                prediStr1 = [NSString stringWithFormat:@"SELF CONTAINS '%@'", title];
            }
        }
            break;
        case 1:{
            if (indexPath.row == 0) {
                prediStr2 = @"SELF LIKE '*'";
            } else {
                prediStr2 = [NSString stringWithFormat:@"SELF CONTAINS '%@'", title];
            }
        }
            break;
        case 2:{
            if (indexPath.row == 0) {
                prediStr3 = @"SELF LIKE '*'";
            } else {
                prediStr3 = [NSString stringWithFormat:@"SELF CONTAINS '%@'", title];
            }
        }
            
        default:
            break;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ AND %@ AND %@",prediStr1,prediStr2,prediStr3]];
    
    self.results = [self.originalArray filteredArrayUsingPredicate:predicate];
    [self.mytableview reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellreuseIdentifier = @"TongchengyaoyueTableViewCell";
    TongchengyaoyueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellreuseIdentifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TongchengyaoyueTableViewCell" owner:self options:nil] lastObject];
        
    }
    [cell.topBg setImage:[[UIImage imageNamed:@"activity_top_v1"] stretchableImageWithLeftCapWidth:6 topCapHeight:0]];
    
    cell.userHeadImage.layer.cornerRadius = 2.0f;
    cell.userHeadImage.layer.masksToBounds = YES;
    cell.userHeadImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.userHeadImage.layer.borderWidth = 0.2f;
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)add:(id)sender {
    
    UINavigationController *nc =  [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FabuyaoyueTableViewController"]];
    nc.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
    nc.navigationBar.tintColor = [UIColor whiteColor];
    [nc.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self presentViewController:nc animated:YES completion:nil];
}
@end
