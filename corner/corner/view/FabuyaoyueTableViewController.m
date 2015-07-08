//
//  FabuyaoyueTableViewController.m
//  corner
//
//  Created by yons on 15-5-7.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "FabuyaoyueTableViewController.h"
//#import "ChooseThemeViewController.h"
#import "ChooseLocationViewController.h"
#import "IQKeyboardManager.h"

@interface FabuyaoyueTableViewController (){
    UIPickerView *currencyPicker;
    UIDatePicker *datePicker;
    UIToolbar *toolbar;
    UIToolbar *toolbar2;
    NSArray *dataSource;
    NSArray *typeDataSource;//活动类型
    
    UIActionSheet *actionSheet;
    UIActionSheet *actionSheet2;
    UIAlertController *alert;
    UIAlertController *alert2;
    
    
    UIActionSheet *typeActionSheet;
    UIAlertController *typeAlert;
    UIPickerView *typeCurrencyPicker;
    
    NSIndexPath *selectedIndexPath;//时间的选择项
    NSIndexPath *typeSelectedIndexPath;//活动类型的选择项
    
    int pickerType;//0时间 1活动类型
    NSNumber *type;// 活动类型:0 一般约会, 1 饭饭之交,2 约定一生
    NSDictionary *userInfo;
}

@end

@implementation FabuyaoyueTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setTheme:) name:@"setTheme" object:nil];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    self.tableView.rowHeight = 44.0f;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 5)];
    view.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = view;
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseLocation:) name:@"chooseLocation" object:nil];
    
    dataSource = @[@"不限时间",@"平时周末",@"指定日期"];
    typeDataSource = @[@"一般约会",@"饭饭之交",@"约定一生"];
    
    
    
    
    currencyPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(12.0f, 44.0f, self.view.frame.size.width-24, 216.0f)];
    currencyPicker.delegate = self;
    currencyPicker.dataSource = self;
    currencyPicker.showsSelectionIndicator = YES;
    
    typeCurrencyPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(12.0f, 44.0f, self.view.frame.size.width-24, 216.0f)];
    typeCurrencyPicker.delegate = self;
    typeCurrencyPicker.dataSource = self;
    typeCurrencyPicker.showsSelectionIndicator = YES;
    
    datePicker = [ [ UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 0, 0)];
    datePicker.datePickerMode = UIDatePickerModeDate;
//    [datePicker setMaximumDate:[NSDate date]];
    
}

/**
 *  设置地址
 *
 *  @param text
 */
-(void)chooseLocation:(NSNotification *)text{
    
    userInfo = text.userInfo;
    
    NSString *name = text.userInfo[@"name"];
    NSNumber *latitude = text.userInfo[@"latitude"];
    NSNumber *longitude = text.userInfo[@"longitude"];
    
    DLog(@"%f",[latitude floatValue]);
    DLog(@"%f",[longitude floatValue]);
    self.locationLabel.text = name;
    self.locationLabel.textColor = [UIColor blackColor];
    
}

/**
 *  设置主题
 *
 *  @param text NSNotification
 */
-(void)setTheme:(NSNotification *)text{
    _themeLabel.text = text.userInfo[@"textOne"];
    _themeLabel.textColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (pickerType) {
        case 0:
            return [dataSource count];
            break;
        case 1:
            return [typeDataSource count];
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch (pickerType) {
        case 0:
        {
            NSString *date = [dataSource objectAtIndex:row];
            return date;
        }
            break;
        case 1:
        {
            NSString *typename = [typeDataSource objectAtIndex:row];
            return typename;
        }
            break;
        default:
            return @"";
            break;
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (pickerType) {
        case 0:
            selectedIndexPath = [NSIndexPath indexPathForRow:row inSection:component];
            break;
        case 1:
            typeSelectedIndexPath = [NSIndexPath indexPathForRow:row inSection:component];
            type = [NSNumber numberWithLong:row];
            break;
        default:
            break;
    }
}

/**
 *  ios7以上显示actionsheet自定义视图
 *
 *  @param picker UIView
 *  @param title  不需要
 */
-(void)alertWithPicer:(UIView *)picker title:(NSString *)title
{
    
    
    alert = [UIAlertController alertControllerWithTitle:nil
                                                message:[NSString stringWithFormat:@"\n\n\n\n\n\n\n\n\n\n\n\n\n"]// change UIAlertController height
                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    //Make a frame for the picker & then create the picker
    CGRect pickerFrame = CGRectMake(12, 44, self.view.frame.size.width-24-20, 216);
    picker.frame = pickerFrame;
    
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, alert.view.frame.size.width-16, 44)];
    toolbar.barStyle = UIBarStyleDefault;
    [toolbar sizeToFit];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(PickerCancelClick)];
    [barItems addObject:cancelBtn];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    [barItems addObject:flexSpace];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(PickerDoneClick)];
    [barItems addObject:doneBtn];
    [toolbar setItems:barItems animated:YES];
    [alert.view addSubview:toolbar];
    [alert.view addSubview:picker];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)alertWithPicer2:(UIView *)picker title:(NSString *)title
{
    
        typeAlert = [UIAlertController alertControllerWithTitle:nil
                                                        message:[NSString stringWithFormat:@"\n\n\n\n\n\n\n\n\n\n\n\n\n"]// change UIAlertController height
                                                 preferredStyle:UIAlertControllerStyleActionSheet];
        
        //Make a frame for the picker & then create the picker
        CGRect pickerFrame = CGRectMake(12, 44, self.view.frame.size.width-24-20, 216);
        picker.frame = pickerFrame;
        
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, typeAlert.view.frame.size.width-16, 44)];
    
        toolbar.barStyle = UIBarStyleDefault;
        [toolbar sizeToFit];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(PickerCancelClick)];
        [barItems addObject:cancelBtn];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [barItems addObject:flexSpace];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(PickerDoneClick)];
        [barItems addObject:doneBtn];
        [toolbar setItems:barItems animated:YES];
        [typeAlert.view addSubview:toolbar];
        [typeAlert.view addSubview:picker];
    
    
    [self presentViewController:typeAlert animated:YES completion:nil];
}

/**
 *  时间范围 取消
 */
-(void)PickerCancelClick{
    if (pickerType == 0) {
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
            [alert dismissViewControllerAnimated:YES completion:nil];
        }else{
            [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        }
    }else if (pickerType == 1){
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
            [typeAlert dismissViewControllerAnimated:YES completion:nil];
        }else{
            [typeActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        }
    }
    
}
/**
 *  精确日期 取消
 */
-(void)PickerCancelClick2{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
        [alert2 dismissViewControllerAnimated:YES completion:nil];
    }else{
        [actionSheet2 dismissWithClickedButtonIndex:-1 animated:YES];
    }
}
/**
 *  确定
 */
-(void)PickerDoneClick{
    
    if (pickerType == 0) {
        if(selectedIndexPath.row == 2) {
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
                [alert dismissViewControllerAnimated:YES completion:nil];
            }else{
                [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
            }
            [self performSelector:@selector(showDatePicker) withObject:nil afterDelay:0.3f];
        }else{
            NSString *date = [dataSource objectAtIndex:selectedIndexPath.row];
            self.dateLabel.text = date;
            self.dateLabel.textColor = [UIColor blackColor];
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
                [alert dismissViewControllerAnimated:YES completion:nil];
            }else{
                [actionSheet dismissWithClickedButtonIndex:-1 animated:YES];
            }
        }
    }else if (pickerType == 1){
        NSString *typename = [typeDataSource objectAtIndex:typeSelectedIndexPath.row];
        
        _themeLabel.text = typename;
        _themeLabel.textColor = [UIColor blackColor];
        
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
            [typeAlert dismissViewControllerAnimated:YES completion:nil];
        }else{
            [typeActionSheet dismissWithClickedButtonIndex:-1 animated:YES];
        }
    }
    
}
/**
 *  延迟显示第二个actionsheet
 */
-(void)showDatePicker{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
        
        alert2 = [UIAlertController alertControllerWithTitle:nil
                                                     message:@"\n\n\n\n\n\n\n\n\n\n\n\n"// change UIAlertController height
                                              preferredStyle:UIAlertControllerStyleActionSheet];
        
        //Make a frame for the picker & then create the picker
        CGRect pickerFrame = CGRectMake(12, 44, self.view.frame.size.width-24-20, 216);
        datePicker.frame = pickerFrame;
        
        toolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, alert.view.frame.size.width-16, 44)];
        toolbar2.barStyle = UIBarStyleBlack;
        [toolbar2 sizeToFit];
        toolbar2.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(PickerCancelClick2)];
        [barItems addObject:cancelBtn];
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [barItems addObject:flexSpace];
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(PickerDoneClick2)];
        [barItems addObject:doneBtn];
        [toolbar2 setItems:barItems animated:YES];
        //    [toolbar sizeToFit];
        [alert2.view addSubview:toolbar2];
        [alert2.view addSubview:datePicker];
        
        [self presentViewController:alert2 animated:YES completion:nil];
    }else{
        
        actionSheet2 = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:nil, nil];
        actionSheet2.tag = 2;
        
        toolbar2 = [[UIToolbar alloc] initWithFrame:CGRectMake(8, 0, self.view.frame.size.width-16, 44)];
        toolbar2.barStyle = UIBarStyleBlack;
        //                [toolbar sizeToFit];
        //                toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        NSMutableArray *barItems = [[NSMutableArray alloc] init];
        
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(PickerCancelClick2)];
        [barItems addObject:cancelBtn];
        
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        [barItems addObject:flexSpace];
        
        UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(PickerDoneClick2)];
        [barItems addObject:doneBtn];
        [toolbar2 setItems:barItems animated:YES];
        //    [toolbar sizeToFit];
        [actionSheet2 addSubview:toolbar2];
        
        [actionSheet2 addSubview:datePicker];
        
        [actionSheet2 showInView:self.view];
    }
}
/**
 *  精确时间 确定
 */
-(void)PickerDoneClick2{
    NSDate *date = datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    self.dateLabel.text = destDateString;
    self.dateLabel.textColor = [UIColor blackColor];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
        [alert2 dismissViewControllerAnimated:YES completion:nil];
    }else{
        [actionSheet2 dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
//            ChooseThemeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseThemeViewController"];
//            if (![_themeLabel.text isEqualToString:@"做什么"]) {
//                vc.theme = _themeLabel.text;
//            }
//            [self.navigationController pushViewController:vc animated:YES];
            
            pickerType = 1;
            
            if (typeSelectedIndexPath == nil) {
                typeSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                type = [NSNumber numberWithInt:0];
            }
            
            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
                [self alertWithPicer2:typeCurrencyPicker title:@""];
            }else{
                
                
                    typeActionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n"
                                                                  delegate:self
                                                         cancelButtonTitle:nil
                                                    destructiveButtonTitle:nil
                                                         otherButtonTitles:nil, nil];
                    typeActionSheet.tag = 1;
                    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(8, 0, self.view.frame.size.width-16, 44)];
                    toolbar.barStyle = UIBarStyleDefault;
                    //                [toolbar sizeToFit];
                    //                toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                    NSMutableArray *barItems = [[NSMutableArray alloc] init];
                    
                    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(PickerCancelClick)];
                    [barItems addObject:cancelBtn];
                    
                    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
                    [barItems addObject:flexSpace];
                    
                    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(PickerDoneClick)];
                    [barItems addObject:doneBtn];
                    [toolbar setItems:barItems animated:YES];
                    //    [toolbar sizeToFit];
                    [typeActionSheet addSubview:toolbar];
                    
                    [typeActionSheet addSubview:currencyPicker];
                    
                    [typeActionSheet showInView:self.view];
                
                
            }
//            [currencyPicker selectedRowInComponent:typeSelectedIndexPath.row];
        }
    }else if (indexPath.section == 1){
//        if (indexPath.row == 0) {//时间
//            
//            pickerType = 0;
//            
//            if (selectedIndexPath == nil) {
//                selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//            }
//            if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
//                [self alertWithPicer:currencyPicker title:@""];
//            }else{
//                actionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n\n"
//                                                          delegate:self
//                                                 cancelButtonTitle:nil
//                                            destructiveButtonTitle:nil
//                                                 otherButtonTitles:nil, nil];
//                actionSheet.tag = 1;
//                toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(8, 0, self.view.frame.size.width-16, 44)];
//                toolbar.barStyle = UIBarStyleDefault;
//                //                [toolbar sizeToFit];
//                //                toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//                NSMutableArray *barItems = [[NSMutableArray alloc] init];
//                
//                UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(PickerCancelClick)];
//                [barItems addObject:cancelBtn];
//                
//                UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//                [barItems addObject:flexSpace];
//                
//                UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(PickerDoneClick)];
//                [barItems addObject:doneBtn];
//                [toolbar setItems:barItems animated:YES];
//                //    [toolbar sizeToFit];
//                [actionSheet addSubview:toolbar];
//                
//                [actionSheet addSubview:currencyPicker];
//                
//                [actionSheet showInView:self.view];
//            }
////            [currencyPicker selectedRowInComponent:selectedIndexPath.row];
//        }
        if (indexPath.row == 0){//位置
            ChooseLocationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseLocationViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 10;
            break;
        case 1:
            return 10;
            break;
        case 2:
            return 25;
            break;
        default:
            return 10;
            break;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 5;
            break;
        case 1:
            return 5;
            break;
        case 2:
            return 5;
            break;
        default:
            return 5;
            break;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 90, 20)];
        label.text = @"活动说明";
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor darkGrayColor];
        [view addSubview:label];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }else{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 5)];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    
    DLog(@"发布邀约");
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    //参数
    [parameters setValue:token forKey:@"token"];
    
    if (type == nil) {
        [self showHint:@"请选择活动主题"];
        return;
    }
    [parameters setValue:type forKey:@"type"];
    [parameters setValue:userInfo[@"name"] forKey:@"location_desc"];
    
    if (userInfo == nil) {
        [self showHint:@"请选择位置"];
        return;
    }
    NSNumber *latitude = userInfo[@"latitude"];
    NSNumber *longitude = userInfo[@"longitude"];
    
    [parameters setValue:[NSString stringWithFormat:@"%f,%f",[longitude floatValue],[latitude floatValue]] forKey:@"location"];
    if ([self.mytextview.text isEqualToString:@""]) {
        [self showHint:@"请填写活动内容"];
        return;
    }
    [parameters setValue:self.mytextview.text forKey:@"description"];
    
    [self showHudInView:self.view hint:@"加载中"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,ACTIVITY_CREATE_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //        NSLog(@"JSON: %@", operation.responseString);
        [self hideHud];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            [self hideHud];
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                NSDictionary *message = [[dic objectForKey:@"message"] cleanNull];
                [self showHint:@"发布成功"];
                DLog(@"%@",message);
                
                int64_t delayInSeconds = 1.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadYaoyue" object:nil];
                });
                
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self hideHud];
        [self showHint:@"连接失败"];
    }];
    
    
}
@end
