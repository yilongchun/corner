//
//  YaoyueDetailViewController.h
//  corner
//
//  Created by yons on 15-6-19.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YaoyueDetailViewController : UIViewController<UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *myscrollview;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (nonatomic, strong) NSDictionary *activityDic;
- (IBAction)enjoy:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *enjoyBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *enjoyBtnHeight;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIView *caredNumsView;
@property (weak, nonatomic) IBOutlet UILabel *caredNumsLabel;

@end
