//
//  CallTableViewCell.h
//  corner
//
//  Created by yons on 15-7-14.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;

@end
