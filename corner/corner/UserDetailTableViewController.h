//
//  UserDetailTableViewController.h
//  corner
//
//  Created by yons on 15-5-29.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDPhotoBrowser.h"

@interface UserDetailTableViewController : UITableViewController<SDPhotoBrowserDelegate>

@property(nonatomic, strong) NSDictionary *userinfo;

@end
