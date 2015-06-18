//
//  MainCollectionViewController.h
//  corner
//
//  Created by yons on 15-4-30.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"


@interface MainCollectionViewController : UICollectionViewController

//+ (MainCollectionViewController *) sharedInstance;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end
