//
//  XiangxueViewController.h
//  corner
//
//  Created by yons on 15-7-3.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XiangxueViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *xueTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *myscrollview;

@property (nonatomic, strong) NSString *xue;
@property (nonatomic, strong) NSString *shanchang;
@property int type;

@end
