//
//  FabudongtaiViewController.h
//  corner
//
//  Created by yons on 15-6-9.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FabudongtaiViewController : UIViewController<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *tishiLabel;
- (IBAction)toChooseImage:(id)sender;
- (IBAction)toChooseLocation:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *chooseImageBtn;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UITextView *mytextview;
- (IBAction)submit:(id)sender;
- (IBAction)cancel:(id)sender;
@end
