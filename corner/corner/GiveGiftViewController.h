//
//  GiveGiftTableViewController.h
//  corner
//
//  Created by yons on 15-7-13.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GiveGiftViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *mytableview;

@property(nonatomic, strong) NSNumber *receive_user_id;
@property(nonatomic, strong) NSString *receive_user_name;
@property(nonatomic, strong) NSString *avatar_url;

@end
