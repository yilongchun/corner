//
//  MainViewController.h
//  corner
//
//  Created by yons on 15-7-29.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RESideMenu.h"
#import "PagedFlowView.h"

@interface MainViewController : UIViewController<PagedFlowViewDelegate,PagedFlowViewDataSource>{
    NSArray *imageArray;
}

@property (weak, nonatomic) IBOutlet UIScrollView *myscrollview;
@property (nonatomic, strong) IBOutlet PagedFlowView *hFlowView;
@property (weak, nonatomic) IBOutlet UIToolbar *mytoolbar;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *charItem;
- (IBAction)action1:(id)sender;
- (IBAction)action2:(id)sender;
- (IBAction)action3:(id)sender;
- (IBAction)action4:(id)sender;

@end
