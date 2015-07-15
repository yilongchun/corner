//
//  PhoneUpdateViewController.m
//  corner
//
//  Created by yons on 15-7-15.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "PhoneUpdateViewController.h"
#import "IQKeyboardManager.h"
#import "UIViewController+updateUserInfo.h"

@interface PhoneUpdateViewController ()

@end

@implementation PhoneUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"联系方式";
    
    UIView *leftMargin = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    self.phoneTextField.leftView = leftMargin;
    self.phoneTextField.leftViewMode = UITextFieldViewModeAlways;
    self.phoneTextField.text = self.phone;
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = done;
}

-(void)done{
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    DLog(@"done");
    if (self.phoneTextField.text.length == 0) {
        [self showHint:@"请填写手机号码"];
        return;
    }else{
        [self updateUserInfo:@"phone" value:self.phoneTextField.text];
    }
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
