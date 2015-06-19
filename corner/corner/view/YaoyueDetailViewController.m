//
//  YaoyueDetailViewController.m
//  corner
//
//  Created by yons on 15-6-19.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "YaoyueDetailViewController.h"

@interface YaoyueDetailViewController ()

@end

@implementation YaoyueDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    DLog(@"%@",_activityDic);
    
    NSString *pic_url = [_activityDic objectForKey:@"pic_url"];
    NSString *location_desc = [_activityDic objectForKey:@"location_desc"];//地点
    NSString *description = [_activityDic objectForKey:@"description"];
    NSNumber *type = [_activityDic objectForKey:@"type"];
    if ([pic_url isEqualToString:@"activity.jpg"]) {//没有图片
        
    }
    
    _nameLabel.text = @"";
    _lengthLabel.text = @"";
    _descLabel.text = description;
    _addressLabel.text = [NSString stringWithFormat:@"地点:%@",location_desc];
    
    switch ([type intValue]) {
        case 0:
            _typeLabel.text = @"一般约会";
            break;
        case 1:
            _typeLabel.text = @"饭饭之交";
            break;
        case 2:
            _typeLabel.text = @"约定一生";
            break;
        default:
            _typeLabel.text = @"";
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
