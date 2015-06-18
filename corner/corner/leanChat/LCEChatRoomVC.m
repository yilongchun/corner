//
//  LCEChatRoomVC.m
//  LeanChatExample
//
//  Created by lzw on 15/4/7.
//  Copyright (c) 2015年 avoscloud. All rights reserved.
//

#import "LCEChatRoomVC.h"
#import "IQKeyboardManager.h"

@interface LCEChatRoomVC ()

@end

@implementation LCEChatRoomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *_peopleImage = [UIImage imageNamed:@"chat_menu_people"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:_peopleImage style:UIBarButtonItemStyleDone target:self action:@selector(goChatGroupDetail:)];
    self.navigationItem.rightBarButtonItem = item;
    
    [IQKeyboardManager sharedManager].enable = NO;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)goChatGroupDetail:(id)sender {
    DLog(@"click");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

@end
