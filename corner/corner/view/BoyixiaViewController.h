//
//  BoyixiaViewController.h
//  corner
//
//  Created by yons on 15-5-6.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"

@interface BoyixiaViewController : UIViewController

- (IBAction)leftMenu:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UIImageView *userimageview;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *label2HeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *msglabel;
- (IBAction)action1:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn1;
- (IBAction)action2:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *btn2;
@end
