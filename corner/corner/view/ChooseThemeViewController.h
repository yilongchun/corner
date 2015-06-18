//
//  ChooseThemeViewController.h
//  corner
//
//  Created by yons on 15-5-8.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseThemeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *themeTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *myscrollview;
- (IBAction)ok:(id)sender;

@property (nonatomic, strong) NSString *theme;
@end
