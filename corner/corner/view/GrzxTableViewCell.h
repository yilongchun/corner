//
//  GrzxTableViewCell.h
//  corner
//
//  Created by yons on 15-6-2.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GrzxTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UIButton *gongkaiBtn;
@property (weak, nonatomic) IBOutlet UIButton *yinsiBtn;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UILabel *jieshaoLabel;
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view1HeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *view2HeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingConstraint2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint2;
@property (weak, nonatomic) IBOutlet UILabel *btn1;
@property (weak, nonatomic) IBOutlet UILabel *btn2;
@property (weak, nonatomic) IBOutlet UILabel *btn3;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *talkBtn;

@end
