//
//  XiangxueViewController.m
//  corner
//
//  Created by yons on 15-7-3.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "XiangxueViewController.h"
#import "IQKeyboardManager.h"
#import "UIViewController+updateUserInfo.h"

@interface XiangxueViewController (){
    NSArray *array;
    CGFloat height;
    
    UIImage *grayImage;
    UIImage *yellowImage;
    NSMutableArray *selectedArr;
}

@end

@implementation XiangxueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    selectedArr = [NSMutableArray array];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    self.xueTextField.leftView = paddingView;
    self.xueTextField.leftViewMode = UITextFieldViewModeAlways;
    
    yellowImage = [UIImage imageNamed:@"btn_yellow"];
    yellowImage = [yellowImage stretchableImageWithLeftCapWidth:floorf(yellowImage.size.width/2) topCapHeight:0];
    
    grayImage = [UIImage imageNamed:@"btn_gray"];
    grayImage = [grayImage stretchableImageWithLeftCapWidth:floorf(grayImage.size.width/2) topCapHeight:0];
    
    array = @[@"摄影",@"游泳",@"羽毛球",@"烹饪美食",@"驾驶",@"瑜伽",@"英语",@"日语",@"韩语",@"小语种",@"涂鸦",@"弹钢琴",@"k歌",@"舞蹈",@"美甲",@"化妆",@"造型设计",@"魔术",@"健身指导",@"钓鱼",@"高尔夫球",@"心理辅导",@"户外探险",@"修电脑",@"PS照片",@"越狱刷机",@"手机贴膜",@"ios编程",@"Android编程",@"期货",@"股票投资",@"企业经营"];
    
    if (self.type == 1) {
        self.xueTextField.text = self.xue;
        selectedArr = [NSMutableArray arrayWithArray:[self.xue componentsSeparatedByString:@","]];
    }else if (self.type == 2){
        self.xueTextField.text = self.shanchang;
        selectedArr = [NSMutableArray arrayWithArray:[self.shanchang componentsSeparatedByString:@","]];
    }
    
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = done;
    
    [self addBtn];
}

-(void)done{
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    DLog(@"done");
    if (self.xueTextField.text.length == 0) {
        [self showHint:@"请填写内容"];
        return;
    }else{
        if (self.type == 1) {
            [self updateUserInfo:@"xue" value:self.xueTextField.text];
        }else if (self.type == 2){
            [self updateUserInfo:@"chang" value:self.xueTextField.text];
        }
        
    }
}


-(void)addBtn{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGRect rect;
    CGFloat x = (screenWidth - 220) / 2;
    CGFloat y = 70;
    CGFloat width = 0;
    CGFloat btnWidth = 100;
    
    int i = 0;
    for (NSString *theme in array) {
        if (i % 2 == 0) {
            x = (screenWidth - 220) / 2;
            if (i != 0) {
                y += 38;
            }
        }
        
        rect = CGRectMake(x, y, btnWidth, 28);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        
        if (self.type == 1) {
            if ([selectedArr indexOfObject:theme] != NSNotFound) {
                [btn setBackgroundImage:yellowImage forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }else{
                [btn setBackgroundImage:grayImage forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            }
        }else if (self.type == 2){
            if ([selectedArr indexOfObject:theme] != NSNotFound) {
                [btn setBackgroundImage:yellowImage forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }else{
                [btn setBackgroundImage:grayImage forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            }
        }
        [btn setBackgroundImage:yellowImage forState:UIControlStateHighlighted];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setFrame:rect];
        [btn setTitle:theme forState:UIControlStateNormal];
        
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_myscrollview addSubview:btn];
        width = btn.frame.origin.x + btnWidth;
        height = btn.frame.origin.y + 40;
        x = width + 20;
        i++;
    }
}

-(void)btnClick:(UIButton *)btn{
//    if (oldBtn) {
//        [oldBtn setBackgroundImage:grayImage forState:UIControlStateNormal];
//        [oldBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    }
//    if (oldBtn != btn) {
//        oldBtn = btn;
//    }
//    
//    [btn setBackgroundImage:yellowImage forState:UIControlStateNormal];
//    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    DLog(@"%@",selectedArr);
    
    if ([selectedArr indexOfObject:btn.currentTitle] != NSNotFound) {
        [selectedArr removeObject:btn.currentTitle];
        [btn setBackgroundImage:grayImage forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }else{
        
        if ([selectedArr count] < 5) {
            [selectedArr addObject:btn.currentTitle];
            [btn setBackgroundImage:yellowImage forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            [self showHint:@"最多只能选5个技能"];
            return;
        }
    }
    DLog(@"%@",selectedArr);
    NSString *value = [selectedArr componentsJoinedByString:@","];
    self.xueTextField.text = value;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    [_myscrollview setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
