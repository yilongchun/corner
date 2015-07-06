//
//  MyLovePartViewController.m
//  corner
//
//  Created by yons on 15-7-6.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "MyLovePartViewController.h"
#import "UIViewController+updateUserInfo.h"

@interface MyLovePartViewController (){
    NSArray *array;
    CGFloat height;
    
    UIImage *grayImage;
    UIImage *yellowImage;
    NSMutableArray *selectedArr;
    NSMutableArray *selectedBtnArr;
}

@end

@implementation MyLovePartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (kCurrentSystemVersion > 6.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    selectedArr = [NSMutableArray array];
    selectedBtnArr = [NSMutableArray array];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    yellowImage = [UIImage imageNamed:@"btn_yellow"];
    yellowImage = [yellowImage stretchableImageWithLeftCapWidth:floorf(yellowImage.size.width/2) topCapHeight:0];
    
    grayImage = [UIImage imageNamed:@"btn_gray"];
    grayImage = [grayImage stretchableImageWithLeftCapWidth:floorf(grayImage.size.width/2) topCapHeight:0];
    
    array = @[@"笑容",@"鼻梁",@"眼睛",@"酒窝",@"腹肌",@"络腮胡",@"腰肌",@"胸肌",@"富有财气的大鼻子",@"傻笑",@"磁性声音",@"只懂赚钱男",@"黝黑的皮肤"];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = done;
    
    selectedArr = [NSMutableArray arrayWithArray:[self.part componentsSeparatedByString:@","]];
    
    [self addBtn];
}

-(void)done{
    NSString *value = [selectedArr componentsJoinedByString:@","];
    if ([selectedArr count] == 0) {
        [self showHint:@"请选择至少一个部位"];
        return;
    }else{
        [self updateUserInfo:@"manyi" value:value];
    }
}

-(void)addBtn{
    
    CGRect rect;
    CGFloat x = 0;
    CGFloat y = 50;
    CGFloat width = 0;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
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
        
        x = width + 8;
        
        if (x + textSize.width > screenWidth) {
            x = 8;
            y += 38;
        }
        
        rect = CGRectMake(x, y, textSize.width, 28);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        if ([selectedArr indexOfObject:theme] != NSNotFound) {
            [selectedBtnArr addObject:btn];
            [btn setBackgroundImage:yellowImage forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
        width = btn.frame.origin.x + textSize.width;
        height = btn.frame.origin.y + 40;
        i++;
    }
}

-(void)btnClick:(UIButton *)btn{
    if ([selectedArr indexOfObject:btn.currentTitle] != NSNotFound) {
        [selectedBtnArr removeObject:btn];
        [selectedArr removeObject:btn.currentTitle];
        [btn setBackgroundImage:grayImage forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }else{
        if ([selectedArr count] < 5) {
            [selectedBtnArr addObject:btn];
            [selectedArr addObject:btn.currentTitle];
            [btn setBackgroundImage:yellowImage forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            [self showHint:@"最多只能选5个满意部位"];
            return;
        }
    }
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
