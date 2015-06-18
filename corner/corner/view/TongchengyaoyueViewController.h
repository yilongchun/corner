//
//  TongchengyaoyueViewController.h
//  corner
//
//  Created by yons on 15-5-4.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"

@interface TongchengyaoyueViewController : UIViewController

//+ (TongchengyaoyueViewController *) sharedInstance;
@property (weak, nonatomic) IBOutlet UITableView *mytableview;

- (IBAction)add:(id)sender;
@end
