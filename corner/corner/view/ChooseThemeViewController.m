//
//  ChooseThemeViewController.m
//  corner
//
//  Created by yons on 15-5-8.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "ChooseThemeViewController.h"

@interface ChooseThemeViewController (){
    NSArray *array;
    CGFloat height;
    UIButton *oldBtn;
    
    UIImage *grayImage;
    UIImage *yellowImage;
}

@end

@implementation ChooseThemeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (kCurrentSystemVersion > 6.0) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 40)];
    self.themeTextField.leftView = paddingView;
    self.themeTextField.leftViewMode = UITextFieldViewModeAlways;
    
    yellowImage = [UIImage imageNamed:@"btn_yellow"];
    yellowImage = [yellowImage stretchableImageWithLeftCapWidth:floorf(yellowImage.size.width/2) topCapHeight:0];
    
    grayImage = [UIImage imageNamed:@"btn_gray"];
    grayImage = [grayImage stretchableImageWithLeftCapWidth:floorf(grayImage.size.width/2) topCapHeight:0];
    
    array = @[@"看电影",@"看话剧",@"打羽毛球",@"打网球",@"登山",@"徒步旅行",@"短途自驾游",@"看海",@"跑步",@"喝咖啡谈天",@"看露天电影",@"找美食小吃",@"去三亚",@"三两朋友K歌",@"拍创意照片",@"骑马",@"开车兜风",@"看日出",@"静看日落",@"吃冰欺凌",@"买菜做饭",@"烧烤",@"仰望星空",@"草地上看书",@"游泳",@"下午茶",@"早茶",@"宵夜",@"车里听歌",@"聊聊理想",@"看喜剧片",@"看恐怖片",@"健身",@"开卡丁车",@"赛车",@"钓鱼",@"打保龄球",@"滑雪",@"潜水",@"打高尔夫",@"射击",@"划船",@"滑旱冰",@"漂流",@"跳舞",@"蹦极",@"做推拿",@"互诉秘密",@"探讨某一话题",@"去周边度假",@"去远方度假",@"吃甜品",@"吃美味自助餐",@"喝点红酒",@"摄影",@"神聊然后放声大笑",@"登上山顶放声呐喊"];
    
    self.themeTextField.text = self.theme;
    
    [self addBtn];
}

-(void)addBtn{
    
    CGRect rect;
    CGFloat x = 0;
    CGFloat y = 140;
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
        if ([theme isEqualToString:self.theme]) {
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

- (IBAction)ok:(id)sender {
    if (![self.themeTextField.text isEqualToString:@""]) {
        //添加 字典，将label的值通过key值设置传递
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:self.themeTextField.text,@"textOne", nil];
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:@"setTheme" object:nil userInfo:dict];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请填写主题活动" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}
@end
