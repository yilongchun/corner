//
//  TongchengyaoyueTableViewCell.h
//  corner
//
//  Created by yons on 15-5-6.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TongchengyaoyueTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *bgview;
@property (weak, nonatomic) IBOutlet UIImageView *topBg;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *isAllowTakeFriendLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceAndSubmitTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userGenderImage;
@property (weak, nonatomic) IBOutlet UILabel *useAgeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *isHotImage;
@end
