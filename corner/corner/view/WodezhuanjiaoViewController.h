//
//  WodezhuanjiaoViewController.h
//  corner
//
//  Created by yons on 15-6-12.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"

@interface WodezhuanjiaoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *mytableview;
@property int currentType;
- (IBAction)fadongtai:(id)sender;
@end
