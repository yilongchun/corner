//
//  ILikeCollectionViewCell.h
//  corner
//
//  Created by yons on 15-6-1.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ILikeCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *myimageview;
@property (weak, nonatomic) IBOutlet UIImageView *seximageview;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@end
