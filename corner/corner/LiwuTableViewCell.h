//
//  LiwuTableViewCell.h
//  corner
//
//  Created by yons on 15-7-13.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiwuTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *giftImage;
@property (weak, nonatomic) IBOutlet UILabel *giftName;
@property (weak, nonatomic) IBOutlet UILabel *giftLovers;
@property (weak, nonatomic) IBOutlet UILabel *giftPrice;
@property (weak, nonatomic) IBOutlet UIButton *giveBtn;
@end
