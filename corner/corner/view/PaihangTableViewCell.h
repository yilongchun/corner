//
//  PaihangTableViewCell.h
//  corner
//
//  Created by yons on 15-5-7.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaihangTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *leftTopView;
@property (weak, nonatomic) IBOutlet UIImageView *sortImage;
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImage;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sexImageView;
@property (weak, nonatomic) IBOutlet UILabel *zhiyeLabel;

@end
