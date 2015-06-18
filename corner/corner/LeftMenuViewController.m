//
//  LeftMenuViewController.m
//  sxxw
//
//  Created by yons on 15-4-16.
//  Copyright (c) 2015年 weiyida. All rights reserved.
//

#import "LeftMenuViewController.h"
#import "LCEChatListVC.h"

#define cellIdentifier @"leftMenuCell"

@interface LeftMenuViewController ()

@end

@implementation LeftMenuViewController{
    NSArray *titles;
    NSIndexPath *oldIndexPath;
    UIButton *oldButton;
    UINavigationController *nc1;
    UINavigationController *nc2;
    UINavigationController *nc3;
    UINavigationController *nc5;
    UINavigationController *nc6;
    UINavigationController *nc8;
    
    UINavigationController *grzxnc;
    UINavigationController *ilikenc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userInfoChange)
                                                 name:USER_INFO_CHANGE
                                               object:nil];
    
    titles = @[@"转角", @"care一下", @"同城邀约", @"快速约饭", @"call她", @"热度排行", @"我的转角", @"vip专区", @"设置"];
    
    
    self.userimage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImage)];
    [self.userimage addGestureRecognizer:tap];
    self.userimage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.userimage.layer.borderWidth = 1.0f;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mytableview.frame.size.width, 20)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, v.frame.size.width, 0.5)];
    label.backgroundColor = [UIColor colorWithRed:250/255. green:250/255. blue:250/255. alpha:0.2];
    [v addSubview:label];
    
    
    self.mytableview.tableFooterView = v;
//    if ([self.mytableview respondsToSelector:@selector(setSeparatorInset:)]) {
//        [self.mytableview setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([self.mytableview respondsToSelector:@selector(setLayoutMargins:)]) {
//        [self.mytableview setLayoutMargins:UIEdgeInsetsZero];
//    }
    
//    [self.mytableview registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.mytableview setSeparatorColor:[UIColor colorWithWhite:1.0 alpha:0.2]];
    
    oldIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.mytableview selectRowAtIndexPath:oldIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    [self userInfoChange];
}

/**
 *  用户信息更改
 */
-(void)userInfoChange{
    NSDictionary *userinfo = [UD objectForKey:LOGINED_USER];
    NSString *avatar_url = [userinfo objectForKey:@"avatar_url"];
    [self.userimage setImageWithURL:[NSURL URLWithString:avatar_url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [titles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        cell.backgroundColor = [UIColor clearColor];
    }
    
//    NSArray *images = @[@"dengluicon", @"zhuceicon", @"tougaoicon", @"guanyuicon"];
    cell.textLabel.text = titles[indexPath.row];
//    cell.imageView.image = [UIImage imageNamed:@"icon_setting"];
    
    
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIView *aView = [[UIView alloc] initWithFrame:cell.contentView.frame];
    aView.backgroundColor = [UIColor colorWithRed:120/255. green:120/255. blue:120/255. alpha:0.4];
    cell.selectedBackgroundView = aView;
    
    return cell;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mytableview.frame.size.width, 20)];
//    view.backgroundColor = [UIColor clearColor];
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 20;
//}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    oldIndexPath = indexPath;
    
    [self oldBtnReset];
    
    if (indexPath.row == 0) {
        if (nc1 == nil) {
            nc1 = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"MainCollectionViewController"]];
            nc1.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
            nc1.navigationBar.tintColor = [UIColor whiteColor];
            [nc1.navigationBar setTitleTextAttributes:
             @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
               NSForegroundColorAttributeName:[UIColor whiteColor]}];
        }
        [self.sideMenuViewController setContentViewController:nc1 animated:YES];
    }else if(indexPath.row == 1){
        if (nc2 == nil) {
            nc2 = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"BoyixiaViewController"]];
        }
        [self.sideMenuViewController setContentViewController:nc2 animated:YES];
    }else if(indexPath.row == 2){
        if (nc3 == nil) {
            nc3 = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"TongchengyaoyueViewController"]];
            nc3.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
            nc3.navigationBar.tintColor = [UIColor whiteColor];
            [nc3.navigationBar setTitleTextAttributes:
             @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
               NSForegroundColorAttributeName:[UIColor whiteColor]}];
        }
        
        
        [self.sideMenuViewController setContentViewController:nc3 animated:YES];
    }else if(indexPath.row == 5){
        if (nc5 == nil) {
            nc5 = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"RedupaihangViewController"]];
            nc5.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
            nc5.navigationBar.tintColor = [UIColor whiteColor];
            [nc5.navigationBar setTitleTextAttributes:
             @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
               NSForegroundColorAttributeName:[UIColor whiteColor]}];
        }
        [self.sideMenuViewController setContentViewController:nc5 animated:YES];
    }else if(indexPath.row == 6){
        if (nc6 == nil) {
            nc6 = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"WodezhuanjiaoViewController"]];
            nc6.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
            nc6.navigationBar.tintColor = [UIColor whiteColor];
            [nc6.navigationBar setTitleTextAttributes:
             @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
               NSForegroundColorAttributeName:[UIColor whiteColor]}];
        }
        [self.sideMenuViewController setContentViewController:nc6 animated:YES];
    }else if(indexPath.row == 8){
        if (nc8 == nil) {
            nc8 = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"SettingTableViewController"]];
            nc8.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
            nc8.navigationBar.tintColor = [UIColor whiteColor];
            [nc8.navigationBar setTitleTextAttributes:
             @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
               NSForegroundColorAttributeName:[UIColor whiteColor]}];
        }
        [self.sideMenuViewController setContentViewController:nc8 animated:YES];
    }
    else{
        
    }
    [self.sideMenuViewController hideMenuViewController];
}

-(UIStatusBarStyle)preferredStatusBarStyle

{
    
    return UIStatusBarStyleDefault;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/**
 *  之前的按钮还原
 */
-(void)oldBtnReset{
    switch (oldButton.tag) {
        case 1:
            [oldButton setImage:[UIImage imageNamed:@"menu7_v1_2x"] forState:UIControlStateNormal];
            break;
        case 2:
            [oldButton setImage:[UIImage imageNamed:@"menu8_v1_2x"] forState:UIControlStateNormal];
            break;
        case 3:
            [oldButton setImage:[UIImage imageNamed:@"menu9_v1_2x"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

//点击头像
-(void)clickImage{
    [self oldBtnReset];
    [self.mytableview deselectRowAtIndexPath:oldIndexPath animated:YES];
    if (grzxnc == nil) {
        grzxnc = [self.storyboard instantiateViewControllerWithIdentifier:@"grzxnc"];
        grzxnc.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
        grzxnc.navigationBar.tintColor = [UIColor whiteColor];
        [grzxnc.navigationBar setTitleTextAttributes:
         @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
           NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
    [self.sideMenuViewController setContentViewController:grzxnc animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}


- (IBAction)action1:(UIButton *)sender {
    [self oldBtnReset];
    oldButton = sender;
    [sender setImage:[UIImage imageNamed:@"menu7c_v1_2x"] forState:UIControlStateNormal];
    [self.mytableview deselectRowAtIndexPath:oldIndexPath animated:YES];
    
    
    LCEChatListVC *chatListVC = [[LCEChatListVC alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:chatListVC];
    nav.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    [nav.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self.sideMenuViewController setContentViewController:nav animated:YES];
    
    [self.sideMenuViewController hideMenuViewController];
}

- (IBAction)action2:(UIButton *)sender{
    [self oldBtnReset];
    oldButton = sender;
    [sender setImage:[UIImage imageNamed:@"menu8c_v1_2x"] forState:UIControlStateNormal];
    [self.mytableview deselectRowAtIndexPath:oldIndexPath animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

- (IBAction)action3:(UIButton *)sender{
    [self oldBtnReset];
    oldButton = sender;
    [sender setImage:[UIImage imageNamed:@"menu9c_v1_2x"] forState:UIControlStateNormal];
    [self.mytableview deselectRowAtIndexPath:oldIndexPath animated:YES];
    
    
    if (ilikenc == nil) {
        ilikenc = [self.storyboard instantiateViewControllerWithIdentifier:@"ilikenc"];
        ilikenc.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
        ilikenc.navigationBar.tintColor = [UIColor whiteColor];
        [ilikenc.navigationBar setTitleTextAttributes:
         @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
           NSForegroundColorAttributeName:[UIColor whiteColor]}];
    }
    [self.sideMenuViewController setContentViewController:ilikenc animated:YES];
    
    [self.sideMenuViewController hideMenuViewController];
}
@end
