//
//  WodeyaoyueViewController.h
//  corner
//
//  Created by yons on 15-6-30.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WodeyaoyueViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

- (IBAction)changeType:(UISegmentedControl *)sender;

- (IBAction)fabuyaoyue:(id)sender;

@end
