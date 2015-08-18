//
//  ShaixuanViewController.m
//  corner
//
//  Created by yons on 15-8-18.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "ShaixuanViewController.h"

@interface ShaixuanViewController ()

@end

@implementation ShaixuanViewController

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

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)search:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
