//
//  PayTypeViewController.h
//  corner
//
//  Created by yons on 15-7-13.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayTypeViewController : UIViewController

@property(nonatomic, strong) NSDictionary *payInfo;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *price;
- (IBAction)alipayAction:(id)sender;
- (IBAction)weixinAction:(id)sender;
@end
