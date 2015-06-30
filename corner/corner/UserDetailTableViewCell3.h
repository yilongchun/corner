//
//  UserDetailTableViewCell3.h
//  corner
//
//  Created by yons on 15-5-29.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserDetailTableViewCell3 : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageviewWidth;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;

@end
