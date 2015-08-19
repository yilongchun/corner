//
//  ShaixuanViewController.m
//  corner
//
//  Created by yons on 15-8-18.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "ShaixuanViewController.h"

@interface ShaixuanViewController ()

@end

@implementation ShaixuanViewController{
    NSDictionary *pickerDic;
    NSArray *provinceArray;
    NSArray *cityArray;
    NSArray *townArray;
    NSArray *selectedArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMyPicker)];
    [self.addressLabel addGestureRecognizer:tap];
    
    [self initView];//初始化弹出选择控件
    [self initPickerData];//初始化选择数据
}

#pragma mark - init view
- (void)initView {
    self.maskView = [[UIView alloc] initWithFrame:kScreen_Frame];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0.3;
    [self.maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMyPicker)]];
    
    self.pickerBgView.width = kScreen_Width;
}
//初始化选择数据
-(void)initPickerData{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Address" ofType:@"plist"];
    pickerDic = [[NSDictionary alloc] initWithContentsOfFile:path];
    provinceArray = [pickerDic allKeys];
    selectedArray = [pickerDic objectForKey:[[pickerDic allKeys] objectAtIndex:0]];
    if (selectedArray.count > 0) {
        cityArray = [[selectedArray objectAtIndex:0] allKeys];
    }
    if (cityArray.count > 0) {
        townArray = [[selectedArray objectAtIndex:0] objectForKey:[cityArray objectAtIndex:0]];
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

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)search:(id)sender {
    NSString *age = _ageText.text;
    int sex = _segSeg.selectedSegmentIndex;
    NSString *address = _addressLabel.text;
    
    DLog(@"%@ %d %@",age,sex,address);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIPicker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return provinceArray.count;
    } else if (component == 1) {
        return cityArray.count;
    } else {
        return townArray.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [provinceArray objectAtIndex:row];
    } else if (component == 1) {
        return [cityArray objectAtIndex:row];
    } else {
        return [townArray objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        selectedArray = [pickerDic objectForKey:[provinceArray objectAtIndex:row]];
        if (selectedArray.count > 0) {
            cityArray = [[selectedArray objectAtIndex:0] allKeys];
        } else {
            cityArray = nil;
        }
        if (cityArray.count > 0) {
            townArray = [[selectedArray objectAtIndex:0] objectForKey:[cityArray objectAtIndex:0]];
        } else {
            townArray = nil;
        }
    }
    [pickerView selectedRowInComponent:1];
    [pickerView reloadComponent:1];
    [pickerView selectedRowInComponent:2];
    
    if (component == 1) {
        if (selectedArray.count > 0 && cityArray.count > 0) {
            townArray = [[selectedArray objectAtIndex:0] objectForKey:[cityArray objectAtIndex:row]];
        } else {
            townArray = nil;
        }
        [pickerView selectRow:1 inComponent:2 animated:YES];
    }
    [pickerView reloadComponent:2];
}

#pragma mark - private method
- (void)showMyPicker {
    [self.pickerView reloadAllComponents];
    [self.pickerView selectRow:0 inComponent:0 animated:YES];
    [self.pickerView selectRow:0 inComponent:1 animated:YES];
    [self.pickerView selectRow:0 inComponent:2 animated:YES];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.pickerBgView];
    self.maskView.alpha = 0.3;
    self.pickerBgView.top = self.view.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0.3;
        self.pickerBgView.bottom = self.view.height;
    }];
}

- (void)hideMyPicker {
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0;
        self.pickerBgView.top = self.view.height;
    } completion:^(BOOL finished) {
        [self.maskView removeFromSuperview];
        [self.pickerBgView removeFromSuperview];
    }];
}


#pragma mark - xib click

- (IBAction)cancel:(id)sender {
    [self hideMyPicker];
}

- (IBAction)ensure:(id)sender {
    
    NSString *province = [provinceArray objectAtIndex:[self.pickerView selectedRowInComponent:0]];
    NSString *city = [cityArray objectAtIndex:[self.pickerView selectedRowInComponent:1]];
    NSString *town = [townArray objectAtIndex:[self.pickerView selectedRowInComponent:2]];
    NSString *value = [NSString stringWithFormat:@"%@%@%@",province,city,town];
    self.addressLabel.text = value;
    
    [self hideMyPicker];
}
@end
