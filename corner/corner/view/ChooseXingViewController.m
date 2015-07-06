//
//  ChooseXingViewController.m
//  corner
//
//  Created by yons on 15-7-3.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "ChooseXingViewController.h"
#import "IQKeyboardManager.h"
#import "UIViewController+updateUserInfo.h"

@interface ChooseXingViewController (){
    NSArray *array;
    CGFloat height;
    UIButton *oldBtn;
    
    UIImage *grayImage;
    UIImage *yellowImage;
}

@end

@implementation ChooseXingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"对性的看法";
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    self.xingTextView.text = self.xing;
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"提交" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    self.navigationItem.rightBarButtonItem = done;
    
    yellowImage = [UIImage imageNamed:@"btn_yellow"];
    yellowImage = [yellowImage stretchableImageWithLeftCapWidth:floorf(yellowImage.size.width/2) topCapHeight:0];
    
    grayImage = [UIImage imageNamed:@"btn_gray"];
    grayImage = [grayImage stretchableImageWithLeftCapWidth:floorf(grayImage.size.width/2) topCapHeight:0];
    
    array = @[@"保守",@"保守且无性经历",@"顺其自然随感觉",@"享受两情相悦的性爱",@"开放",@"疯狂"];
    
    [self addBtn];
}

-(void)done{
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    DLog(@"done");
    if (self.xingTextView.text.length == 0) {
        [self showHint:@"请填写内容"];
        return;
    }else{
        [self updateUserInfo:@"xing" value:self.xingTextView.text];
    }
}

-(void)addBtn{
    
    CGRect rect;
    CGFloat x = 0;
    CGFloat y = 190;
    CGFloat width = 0;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
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
        
        if (textSize.width < 40) {
            textSize.width = 40;
        }
        textSize.width += 20;
        
        x = width + 8;
        
        if (x + textSize.width > screenWidth) {
            x = 8;
            y += 38;
        }
        
        rect = CGRectMake(x, y, textSize.width, 28);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([theme isEqualToString:self.xing]) {
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
        [self.view addSubview:btn];
        width = btn.frame.origin.x + textSize.width + 5;
        height = btn.frame.origin.y + 40;
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
    self.xingTextView.text = btn.currentTitle;
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
