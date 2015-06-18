//
//  BoyixiaViewController.m
//  corner
//
//  Created by yons on 15-5-6.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "BoyixiaViewController.h"
#import "UIImageView+LBBlurredImage.h"

@interface BoyixiaViewController ()

@property (strong, nonatomic) CAGradientLayer *gradientLayer;

@end

@implementation BoyixiaViewController{
    CGRect rect;
    BOOL flag;//动画状态
    UIView *tempView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    
//    UIImage *image = [UIImage imageNamed:@"example"];
//    [self setImage:image];
    
    
    
    [self.msglabel removeFromSuperview];
}

-(void)setImage:(UIImage *)image{
    [self.userimageview setImage:image];
    [self.imageview setImageToBlur:image
                        blurRadius:kLBBlurredImageDefaultBlurRadius
                   completionBlock:^(){
                       NSLog(@"The blurred image has been set");
                       
                   }];
    
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if([[ UIScreen mainScreen ] bounds ].size.height == 480){
        self.leadConstraint.constant = 25.0f;
        self.trailingConstraint.constant = 25.0f;
        self.label1.text = @"";
        self.labelHeightConstraint.constant = 0;
        self.label2.text = @"";
        self.label2HeightConstraint.constant = 0;
    }
//    //初始化渐变层
//    self.gradientLayer = [CAGradientLayer layer];
//    self.gradientLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.imageview.frame.size.height);
//    [self.imageview.layer addSublayer:self.gradientLayer];
//    //设置渐变颜色方向
//    self.gradientLayer.startPoint = CGPointMake(0, 1);
//    self.gradientLayer.endPoint = CGPointMake(0, 0.8);
//    //设定颜色组
//    self.gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:29/255. green:29/255. blue:29/255. alpha:0.7].CGColor,
//                                  (__bridge id)[UIColor clearColor].CGColor];
//    //设定颜色分割点
//    self.gradientLayer.locations = @[@(0.0f)];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
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

- (IBAction)leftMenu:(id)sender {
    [self.sideMenuViewController presentLeftMenuViewController];
}
- (IBAction)action1:(id)sender {
    
    
    tempView = [[UIView alloc] initWithFrame:self.userimageview.frame];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tempView.frame.size.width, tempView.frame.size.height)];
    image.image = self.userimageview.image;
    [tempView addSubview:image];
    [self.view addSubview:tempView];
    
    CGPoint finishPoint = CGPointMake(self.view.center.x-600, tempView.center.y);
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: - M_PI * 1.5];
    rotationAnimation.duration = 0.4;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1;
    [tempView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    [UIView animateWithDuration:0.4f animations:^{
        tempView.center = finishPoint;
    } completion:^(BOOL finished) {
        [tempView removeFromSuperview];
    }];
}

- (IBAction)action2:(id)sender {
    
    tempView = [[UIView alloc] initWithFrame:self.userimageview.frame];
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, tempView.frame.size.width, tempView.frame.size.height)];
    image.image = self.userimageview.image;
    [tempView addSubview:image];
    [self.view addSubview:tempView];
    
    
    UIImageView *kiss_lip1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"kiss_lip1"]];
    kiss_lip1.center = tempView.center;
    [tempView addSubview:kiss_lip1];
    kiss_lip1.transform = CGAffineTransformMakeScale(4.0, 4.0);
    [UIView animateWithDuration:0.5f animations:^{
        kiss_lip1.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        
        [self performSelector:@selector(rightAnimation) withObject:nil afterDelay:0.2];
        
    }];
}

-(void)rightAnimation{
    CGPoint finishPoint = CGPointMake(self.view.center.x+600, tempView.center.y);
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 1.5 ];
    rotationAnimation.duration = 0.4;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1;
    [tempView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    [UIView animateWithDuration:0.4f animations:^{
        tempView.center = finishPoint;
    } completion:^(BOOL finished) {
        [tempView removeFromSuperview];
    }];
}
@end
