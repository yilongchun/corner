//
//  ChooseZhiyeViewController.m
//  corner
//
//  Created by yons on 15-7-3.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "ChooseZhiyeViewController.h"
#import "IQKeyboardManager.h"
#import "UIViewController+updateUserInfo.h"

@interface ChooseZhiyeViewController (){
    NSArray *array;
    CGFloat height;
    UIButton *oldBtn;
    
    UIImage *grayImage;
    UIImage *yellowImage;
}

@end

@implementation ChooseZhiyeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (kCurrentSystemVersion > 6.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.title = @"职业";
    
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    self.themeTextField.leftView = paddingView;
    self.themeTextField.leftViewMode = UITextFieldViewModeAlways;
    
    yellowImage = [UIImage imageNamed:@"btn_yellow"];
    yellowImage = [yellowImage stretchableImageWithLeftCapWidth:floorf(yellowImage.size.width/2) topCapHeight:0];
    
    grayImage = [UIImage imageNamed:@"btn_gray"];
    grayImage = [grayImage stretchableImageWithLeftCapWidth:floorf(grayImage.size.width/2) topCapHeight:0];
    
    array = @[@"职业经理人",@"私营企业主",@"中层管理者",@"高校学生",@"公司职员",@"工程师",@"军人",@"警察",@"医生",@"护士",@"空乘",@"航空公司",@"演艺人员",@"模特",@"教师",@"国企工作者",@"机关工作者",@"媒体工作者",@"互联网从业者",@"风险投资人"];
    
    self.themeTextField.text = self.zhiye;
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = done;
    
    [self addBtn];
}

-(void)done{
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    DLog(@"done");
    if (self.themeTextField.text.length == 0) {
        [self showHint:@"请填写内容"];
        return;
    }else{
        [self updateUserInfo:@"zhiye" value:self.themeTextField.text];
    }
}


-(void)addBtn{
    
    CGRect rect;
    CGFloat x = 0;
    CGFloat y = 70;
    CGFloat width = 0;
//    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    int i = 0;
    for (NSString *theme in array) {
        
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        CGSize textSize;
        if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
            NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
            textSize = [theme boundingRectWithSize:CGSizeMake(MAXFLOAT, 28)
                                           options:options
                                        attributes:attributes
                                           context:nil].size;
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            textSize = [theme sizeWithFont:font
                         constrainedToSize:CGSizeMake(MAXFLOAT, 28)
                             lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
            
        }
        
        if (textSize.width < 60) {
            textSize.width = 60;
        }
        textSize.width += 20;
        
        x = width + 10;
        
        if (i != 0 && i % 2 == 0) {
            x = 10;
            y += 38;
        }
        
        rect = CGRectMake(x, y, textSize.width, 28);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([theme isEqualToString:self.zhiye]) {
            [btn setBackgroundImage:yellowImage forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            oldBtn = btn;
        }else{
            [btn setBackgroundImage:grayImage forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
        [btn setBackgroundImage:yellowImage forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setFrame:rect];
        [btn setTitle:theme forState:UIControlStateNormal];
        
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_myscrollview addSubview:btn];
        width = btn.frame.origin.x + textSize.width + 5;
        height = btn.frame.origin.y + 40;
        
        i++;
    }
}

-(void)btnClick:(UIButton *)btn{
    if (oldBtn) {
        [oldBtn setBackgroundImage:grayImage forState:UIControlStateNormal];
        [oldBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    oldBtn = btn;
    [btn setBackgroundImage:yellowImage forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.themeTextField.text = btn.currentTitle;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_myscrollview setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, height)];
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
