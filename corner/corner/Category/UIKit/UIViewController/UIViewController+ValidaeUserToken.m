//
//  UIViewController+ValidaeUserToken.m
//  corner
//
//  Created by yons on 15-6-4.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "UIViewController+ValidaeUserToken.h"

@implementation UIViewController (ValidaeUserToken)


-(void)validateUserToken:(int)errorCode{
    switch (errorCode) {
        case 608:
        {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[NSNotificationCenter defaultCenter] postNotificationName:USER_LOGIN_CHANGE object:nil];
            });
        }
            break;
        default:
            break;
    }
}

@end
