//
//  XuanshiViewController.m
//  corner
//
//  Created by yons on 15-7-2.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "XuanshiViewController.h"
#import "UIViewController+updateUserInfo.h"

@interface XuanshiViewController ()

@end

@implementation XuanshiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)action1:(id)sender {
    [self updateUserInfo:@"xuanshi" value:@"结交知己玩伴"];
}

- (IBAction)action2:(id)sender {
    [self updateUserInfo:@"xuanshi" value:@"找寻恋爱对象"];
}

- (IBAction)action3:(id)sender {
    [self updateUserInfo:@"xuanshi" value:@"仅以结婚目的"];
}

- (IBAction)action4:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
