//
//  ILikeCollectionViewController.h
//  corner
//
//  Created by yons on 15-6-1.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "RESideMenu.h"

@interface ILikeCollectionViewController : UICollectionViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *myseg;
- (IBAction)changeType:(UISegmentedControl *)sender;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property int segtype;

@end
