//
//  ZiwojieshaoViewController.m
//  corner
//
//  Created by yons on 15-7-2.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "ZiwojieshaoViewController.h"
#import "IQKeyboardManager.h"

@interface ZiwojieshaoViewController ()

@end

@implementation ZiwojieshaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
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
