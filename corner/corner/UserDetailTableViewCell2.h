//
//  UserDetailTableViewCell2.h
//  corner
//
//  Created by yons on 15-5-29.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserDetailTableViewCell2 : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageviewWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSpace;
@end
