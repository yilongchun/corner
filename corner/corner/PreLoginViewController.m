//
//  LoginViewController.m
//  corner
//
//  Created by yons on 15-5-27.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "PreLoginViewController.h"

@interface PreLoginViewController ()

@end

@implementation PreLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *img = [[UIImage imageNamed:@"star_btn_v1"] stretchableImageWithLeftCapWidth:25 topCapHeight:0];
    [self.wxBtn setBackgroundImage:img forState:UIControlStateNormal];
    [self.wbBtn setBackgroundImage:img forState:UIControlStateNormal];
    [self.qqBtn setBackgroundImage:img forState:UIControlStateNormal];
    [self.emailOrPhoneBtn setBackgroundImage:img forState:UIControlStateNormal];
    
    self.wxBtn.alpha = 0.0;
    self.wbBtn.alpha = 0.0;
    self.qqBtn.alpha = 0.0;
    self.emailOrPhoneBtn.alpha = 0.0;
    
    self.wxBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    self.wbBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    self.qqBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    self.emailOrPhoneBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    
    UIViewAnimationOptions options = UIViewAnimationCurveLinear | UIViewKeyframeAnimationOptionAllowUserInteraction;
    [UIView animateWithDuration:0.2 delay:0.2 options:options animations:^{
        self.wxBtn.alpha = 1.0;
        self.wxBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
    [UIView animateWithDuration:0.3 delay:0.2 options:options animations:^{
        self.wbBtn.alpha = 1.0;
        self.wbBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
    [UIView animateWithDuration:0.4 delay:0.2 options:options animations:^{
        self.qqBtn.alpha = 1.0;
        self.qqBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
    [UIView animateWithDuration:0.5 delay:0.2 options:options animations:^{
        self.emailOrPhoneBtn.alpha = 1.0;
        self.emailOrPhoneBtn.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:nil];
    
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
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
