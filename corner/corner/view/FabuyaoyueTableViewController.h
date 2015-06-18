//
//  FabuyaoyueTableViewController.h
//  corner
//
//  Created by yons on 15-5-7.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FabuyaoyueTableViewController : UITableViewController<UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *themeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextView *mytextview;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@end
