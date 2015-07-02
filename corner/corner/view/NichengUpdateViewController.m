//
//  NichengUpdateViewController.m
//  corner
//
//  Created by yons on 15-7-2.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "NichengUpdateViewController.h"
#import "IQKeyboardManager.h"

@interface NichengUpdateViewController ()

@end

@implementation NichengUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIView *leftMargin = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    self.nicknameTextField.leftView = leftMargin;
    self.nicknameTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = done;
}

-(void)done{
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    DLog(@"done");
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

@end
