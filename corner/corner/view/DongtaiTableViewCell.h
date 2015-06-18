//
//  DongtaiTableViewCell.h
//  corner
//
//  Created by yons on 15-6-9.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DongtaiTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userimage;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *leftDateLabel2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;
@end
