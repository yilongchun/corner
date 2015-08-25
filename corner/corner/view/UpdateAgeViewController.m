//
//  UpdateAgeViewController.m
//  corner
//
//  Created by yons on 15-7-6.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "UpdateAgeViewController.h"
#import "UIViewController+updateUserInfo.h"
#import "NSDate+Addition.h"

@interface UpdateAgeViewController ()

@end

@implementation UpdateAgeViewController
@synthesize birthday;

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
    
    if (birthday == nil || [birthday isEqualToString:@""] || (birthday != nil && [birthday isEqualToString:@"1900-01-01"])) {
        self.ageLabel.text = @"未填";
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *date= [dateFormatter dateFromString:self.birthday];
        NSInteger age = [NSDate ageWithDateOfBirth:date];
        self.ageLabel.text = [NSString stringWithFormat:@"%ld",(long)age];
        [self.datePicker setDate:date];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseDate)];
    [self.ageView addGestureRecognizer:tap];
    
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker setMaximumDate:[NSDate date]];
    [self initView];
}

#pragma mark - init view
- (void)initView {
    
    self.maskView = [[UIView alloc] initWithFrame:kScreen_Frame];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0.3;
    [self.maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMyPicker)]];
    
    self.pickerBgView.width = kScreen_Width;
}

#pragma mark - private method
- (void)showMyPicker {
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.pickerBgView];
    self.maskView.alpha = 0;
    self.pickerBgView.top = self.view.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0.3;
        self.pickerBgView.bottom = self.view.height;
    }];
}

- (void)hideMyPicker {
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0;
        self.pickerBgView.top = self.view.height;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
        [self.pickerBgView removeFromSuperview];
    }];
}

#pragma mark - xib click

- (IBAction)cancel:(id)sender {
    [self hideMyPicker];
}

- (IBAction)ensure:(id)sender {
    
    NSDate *date = self.datePicker.date;
    
    NSInteger age = [NSDate ageWithDateOfBirth:date];
    self.ageLabel.text = [NSString stringWithFormat:@"%ld",(long)age];
    DLog(@"%ld",(long)age);
    [self hideMyPicker];
}


-(void)chooseDate{
    DLog(@"choosedate");
    [self showMyPicker];
}

-(void)done{
    DLog(@"done");
    if ([self.ageLabel.text isEqualToString:@"未填"]) {
        [self showHint:@"请选择日期"];
        return;
    }
    NSDate *date = self.datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    [self updateUserInfo:@"birthday" value:destDateString];
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
