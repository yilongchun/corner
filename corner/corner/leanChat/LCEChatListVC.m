//
//  CDConvsVC.m
//  LeanChat
//
//  Created by lzw on 15/4/10.
//  Copyright (c) 2015年 AVOS. All rights reserved.
//

#import "LCEChatListVC.h"
#import "LCEChatRoomVC.h"
#import "RESideMenu.h"

@interface LCEChatListVC () <CDChatListVCDelegate>

@end

@implementation LCEChatListVC

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"消息";
        self.tabBarItem.image = [UIImage imageNamed:@"tabbar_chat_active"];
        self.chatListDelegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(rightBarButtonClicked:)];
//    UIBarButtonItem *logoutItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
//    self.navigationItem.rightBarButtonItems = @[logoutItem, addItem];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    
    UIImage *image = [[UIImage imageNamed:@"kiss_top1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)leftMenu{
    [self.sideMenuViewController presentLeftMenuViewController];
}

- (void)logout:(id)sender {
    [[CDIM sharedInstance] closeWithCallback: ^(BOOL succeeded, NSError *error) {
        UIApplication *app = [UIApplication sharedApplication];
        [app performSelector:@selector(suspend)];
        [self performSelector:@selector(exitApp:) withObject:nil afterDelay:0.5];
    }];
}

- (void)exitApp:(id)sender {
    exit(0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
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

- (void)viewController:(UIViewController *)viewController didSelectConv:(AVIMConversation *)conv {
    LCEChatRoomVC *chatRoomVC = [[LCEChatRoomVC alloc] initWithConv:conv];
    chatRoomVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatRoomVC animated:YES];
}

- (void)setBadgeWithTotalUnreadCount:(NSInteger)totalUnreadCount {
    if (totalUnreadCount > 0) {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld", (long)totalUnreadCount];
    }
    else {
        self.tabBarItem.badgeValue = nil;
    }
}

- (void)rightBarButtonClicked:(id)sender {
//    WEAKSELF
//    [[CDIM sharedInstance] fetchConvWithOtherId:@"21" callback : ^(AVIMConversation *conversation, NSError *error) {
//        if (error) {
//            DLog(@"%@", error);
//        }
//        else {
//            LCEChatRoomVC *chatRoomVC = [[LCEChatRoomVC alloc] initWithConv:conversation];
//            [weakSelf.navigationController pushViewController:chatRoomVC animated:YES];
//        }
//    }];
    
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    MainViewController *mainVC = [storyBoard instantiateViewControllerWithIdentifier:@"main"];
//    mainVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:mainVC animated:YES];
}

@end
