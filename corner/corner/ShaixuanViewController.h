//
//  ShaixuanViewController.h
//  corner
//
//  Created by yons on 15-8-18.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIView+RGSize.h"
#define kScreen_Height      ([UIScreen mainScreen].bounds.size.height)
#define kScreen_Width       ([UIScreen mainScreen].bounds.size.width)
#define kScreen_Frame       (CGRectMake(0, 0 ,kScreen_Width,kScreen_Height))

@interface ShaixuanViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIToolbar *mytoolbar;
- (IBAction)back:(id)sender;
- (IBAction)search:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *ageText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segSeg;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UIView *pickerBgView;
@property (strong, nonatomic) UIView *maskView;
@end
