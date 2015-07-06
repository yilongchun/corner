//
//  ChooseAiqingViewController.h
//  corner
//
//  Created by yons on 15-7-3.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseAiqingViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *aiqingTextView;
@property (nonatomic, strong) NSString *aiqing;

- (IBAction)click1:(UIButton *)sender;
- (IBAction)click2:(UIButton *)sender;
- (IBAction)click3:(UIButton *)sender;
- (IBAction)click4:(UIButton *)sender;

@end
