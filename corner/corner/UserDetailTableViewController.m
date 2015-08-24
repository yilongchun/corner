//
//  UserDetailTableViewController.m
//  corner
//
//  Created by yons on 15-5-29.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "UserDetailTableViewController.h"
#import "UserDetailTableViewCell1.h"
#import "UserDetailTableViewCell2.h"
#import "UserDetailTableViewCell3.h"
#import "UserDetailTableViewCell5.h"
#import "GrzxTableViewCell.h"
#import "YaoyueDetailViewController.h"
#import "MLPhotoBrowserViewController.h"
#import "DongtaiTableViewController.h"
#import "LCEChatRoomVC.h"
#import "SVPullToRefresh.h"
#import "GiveGiftViewController.h"

#define PICTURE_NUMBER 3
#define PICTURE_MARGIN 2

@interface UserDetailTableViewController (){
    NSMutableDictionary *userinfo;
    
    UIView *view1;//公开照片 父视图
    UIView *view2;//隐私照片 父视图
    NSMutableArray *photo1;//公开照片
    NSMutableArray *photo2;//隐私照片
    int currentImageIndex;//当前点击的图片
    CGRect resetRect;
    BOOL rectFlag;
    int viewtype;//用于区别点的是哪个区域的图片
    
    NSMutableDictionary *loginUserInfo;
}

@end

@implementation UserDetailTableViewController
@synthesize userinfo;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
//    UIImage *image = [[UIImage imageNamed:@"pub_title_8_v1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(action1)];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    photo1 = [NSMutableArray array];
    photo2 = [NSMutableArray array];
    rectFlag = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainbackground"]];
    self.tableView.backgroundView = view;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    
    __weak UserDetailTableViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
    //初始化数据
    [self.tableView triggerPullToRefresh];

}

- (void)insertRowAtTop {
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadUser];
    });
}

-(void)loadUser{
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@?token=%@",HOST,USER_DETAIL_URL,userid,token];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                loginUserInfo = [NSMutableDictionary dictionaryWithDictionary:[[dic objectForKey:@"message"] cleanNull] ];
                [self loadData];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self.tableView.pullToRefreshView stopAnimating];
        [self showHint:@"连接失败"];
    }];
}

-(void)loadData{
    NSString *userid = [userinfo objectForKey:@"id"];
    NSString *myuserid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,myuserid]];
//    [self showHudInView:self.view hint:@"加载中"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@?token=%@",HOST,USER_DETAIL_URL,userid,token];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.tableView.pullToRefreshView stopAnimating];
//        [self hideHud];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                userinfo = [NSMutableDictionary dictionaryWithDictionary:[[dic objectForKey:@"message"] cleanNull]];
                NSNumber *userid = [userinfo objectForKey:@"id"];
//                NSString *name = [userinfo objectForKey:@"name"];
                NSString *nickname = [userinfo objectForKey:@"nickname"];
                NSArray *posts = [userinfo objectForKey:@"posts"];
                
                
                if ([posts count] > 0) {
//                    NSDictionary *post = [posts objectAtIndex:0];
//                    NSString *created_at = [post objectForKey:@"created_at"];
//                    NSString *pic_url = [post objectForKey:@"pic_url"];
//                    NSString *post_body = [post objectForKey:@"post_body"];
                }
                
                if ([nickname isEqualToString:@""]) {
                    self.title = [NSString stringWithFormat:@"%d",[userid intValue]];
                }else{
                    self.title = nickname;
                }
                
                //用户的照片
                NSArray *photos = [userinfo objectForKey:@"photos"];
                [photo1 removeAllObjects];
                [photo2 removeAllObjects];
                for (int i = 0; i < [photos count]; i++) {
                    NSDictionary *imgdic = [photos objectAtIndex:i];
                    //                    NSString *url = [dic objectForKey:@"url"];
                    NSNumber *imagetype = [imgdic objectForKey:@"type"];
                    NSNumber *status = [imgdic objectForKey:@"status"];
                    if ([imagetype intValue]== 0) {//公开
                        if ([status intValue] == 0) {
                            [photo1 addObject:imgdic];
                        }
                        
                    }else if ([imagetype intValue] == 1){//隐私
                        if ([status intValue] == 0) {
                            [photo2 addObject:imgdic];
                        }
                    }
                }
                [self.tableView reloadData];
                
                [self addPicture];
                
                
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.tableView.pullToRefreshView stopAnimating];
        NSLog(@"发生错误！%@",error);
//        [self hideHud];
        [self showHint:@"连接失败"];
        
    }];
}

/**
 *  添加公开图片和隐私图片
 */
-(void)addPicture{
    //设置第一行的公开图片和隐私图片
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    GrzxTableViewCell *cell = (GrzxTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    //一个cell刷新
    //    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    //    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationFade];
    
    
    
    [cell.view1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *btn = obj;
        if (btn.tag != -1) {
            [btn removeFromSuperview];
        }
    }];
    [cell.view2.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *btn = obj;
        if (btn.tag != -1) {
            [btn removeFromSuperview];
        }
    }];
    if (rectFlag == NO) {
        resetRect = cell.gongkaiBtn.frame;
        resetRect.origin.x = 2;
        resetRect.origin.y = 0;
        rectFlag = YES;
    }
    
    [cell.gongkaiBtn setFrame:resetRect];
    [cell.yinsiBtn setFrame:resetRect];
    
    if ([photo1 count] == 0) {
        CGRect rect = cell.gongkaiBtn.frame;
        cell.leadingConstraint.constant = rect.origin.x;
        cell.topConstraint.constant = rect.origin.y;
        cell.view1HeightConstraint.constant = rect.origin.y + rect.size.height;
    }else{
        
        
        for (int i = 0; i < [photo1 count]; i++) {
            UIImageView *img = [[UIImageView alloc] initWithFrame:cell.gongkaiBtn.frame];
            img.contentMode = UIViewContentModeScaleToFill;
            [img setImageWithURL:[NSURL URLWithString:[[photo1 objectAtIndex:i] objectForKey:@"url"]]];
            img.tag = i;
            img.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
            [img addGestureRecognizer:tap];
            [cell.view1 addSubview:img];
            CGRect rect = cell.gongkaiBtn.frame;
            if (i !=0 && (i+1) % PICTURE_NUMBER == 0) {//应该换行
                rect.origin.x = 2;
                rect.origin.y = ((i + 1) / PICTURE_NUMBER) * (rect.size.height + PICTURE_MARGIN);
                cell.view1HeightConstraint.constant = rect.origin.y + rect.size.height + PICTURE_MARGIN;
            }else{
                rect.origin.x = cell.gongkaiBtn.frame.size.width + cell.gongkaiBtn.frame.origin.x + PICTURE_MARGIN;
                cell.view1HeightConstraint.constant = rect.origin.y + rect.size.height;
            }
            cell.leadingConstraint.constant = rect.origin.x;
            cell.topConstraint.constant = rect.origin.y;
            [cell.gongkaiBtn setFrame:rect];
        }
    }
    
    if ([photo2 count] == 0) {
        CGRect rect = cell.yinsiBtn.frame;
        cell.leadingConstraint2.constant = rect.origin.x;
        cell.topConstraint2.constant = rect.origin.y;
        cell.view2HeightConstraint.constant = rect.origin.y + rect.size.height;
    }else{
        for (int i = 0; i < [photo2 count]; i++) {
            UIImageView *img = [[UIImageView alloc] initWithFrame:cell.yinsiBtn.frame];
            img.contentMode = UIViewContentModeScaleToFill;
            [img setImageWithURL:[NSURL URLWithString:[[photo2 objectAtIndex:i] objectForKey:@"url"]]];
            img.tag = i;
            img.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
            [img addGestureRecognizer:tap];
            [cell.view2 addSubview:img];
            CGRect rect = cell.yinsiBtn.frame;
            if (i !=0 && (i+1) % PICTURE_NUMBER == 0) {//应该换行
                rect.origin.x = 2;
                rect.origin.y = ((i + 1) / PICTURE_NUMBER) * (rect.size.height + PICTURE_MARGIN);
                cell.leadingConstraint2.constant = rect.origin.x;
                cell.topConstraint2.constant = rect.origin.y;
                cell.view2HeightConstraint.constant = rect.origin.y + rect.size.height + PICTURE_MARGIN;
            }else{
                rect.origin.x = cell.yinsiBtn.frame.size.width + cell.yinsiBtn.frame.origin.x + PICTURE_MARGIN;
                cell.leadingConstraint2.constant = rect.origin.x;
                cell.topConstraint2.constant = rect.origin.y;
                cell.view2HeightConstraint.constant = rect.origin.y + rect.size.height;
            }
            [cell.yinsiBtn setFrame:rect];
        }
    }
}

/**
 *  点击图片
 *
 *  @param recognizer
 */
- (void)imageClick:(UITapGestureRecognizer *)recognizer
{
    currentImageIndex = (int)recognizer.view.tag;
    if (recognizer.view.superview.tag == 1) {
        viewtype = 1;
    }else if(recognizer.view.superview.tag == 2){
        viewtype = 2;
    }
    [self showPic];
}

-(void)action1{
    DLog(@"action1");
}

/**
 *  点击图片查看大图
 */
-(void)showPic{
    // 图片游览器
    MLPhotoBrowserViewController *photoBrowser = [[MLPhotoBrowserViewController alloc] init];
    // 缩放动画
    photoBrowser.status = UIViewAnimationAnimationStatusFade;
    // 可以删除
    photoBrowser.editing = NO;
    // 数据源/delegate
    //    photoBrowser.delegate = self;
    // 同样支持数据源/DataSource
    //                    photoBrowser.dataSource = self;
    
    NSMutableArray *imgDataSource = [NSMutableArray array];
    if (viewtype == 1) {
        for (int i = 0; i < photo1.count; i++) {
            MLPhotoBrowserPhoto *photo = [[MLPhotoBrowserPhoto alloc] init];
            photo.photoURL = [NSURL URLWithString:[[photo1 objectAtIndex:i] objectForKey:@"url"]];
            [imgDataSource addObject:photo];
        }
    }else if (viewtype == 2){
        for (int i = 0; i < photo2.count; i++) {
            MLPhotoBrowserPhoto *photo = [[MLPhotoBrowserPhoto alloc] init];
            photo.photoURL = [NSURL URLWithString:[[photo2 objectAtIndex:i] objectForKey:@"url"]];
            [imgDataSource addObject:photo];
        }
    }
    photoBrowser.photos = imgDataSource;
    
    // 当前选中的值
    photoBrowser.currentIndexPath = [NSIndexPath indexPathForItem:currentImageIndex inSection:0];
    // 展示控制器
    [photoBrowser showPickerVc:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        CGFloat imgWidth = ([UIScreen mainScreen].bounds.size.width - PICTURE_MARGIN * (PICTURE_NUMBER +1)) / PICTURE_NUMBER;//图片宽度
        CGFloat height1;//第一个图片集高度
        CGFloat height2;//第二个图片集高度
        
        CGFloat y = 290 - 17;//减去自我介绍的高度 下面有算高度
        CGFloat jiange = 32;//第一个图片集 和 第二个图片集间隔
        CGFloat totalHeight = y + jiange + 10;
        if ((photo1.count + 1) % PICTURE_NUMBER == 0) {
            height1 = ((photo1.count + 1) / PICTURE_NUMBER) * (imgWidth + ((photo1.count + 1) / PICTURE_NUMBER -1) * PICTURE_MARGIN);
        }else{
            height1 = (((photo1.count + 1) / PICTURE_NUMBER) + 1) * (imgWidth + ((photo1.count + 1) / PICTURE_NUMBER) * PICTURE_MARGIN);
        }
        if ((photo2.count + 1) % PICTURE_NUMBER == 0) {
            height2 = ((photo2.count + 1) / PICTURE_NUMBER) * (imgWidth + ((photo2.count + 1) / PICTURE_NUMBER -1) * PICTURE_MARGIN);
        }else{
            height2 = (((photo2.count + 1) / PICTURE_NUMBER) + 1) * (imgWidth + ((photo2.count + 1) / PICTURE_NUMBER) * PICTURE_MARGIN);
        }
        
        
        
        // 列寬
        CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width - 40;
        // 用何種字體進行顯示
        UIFont *font = [UIFont systemFontOfSize:14];
        // 該行要顯示的內容
        NSString *content = [userinfo objectForKey:@"aboutme"];//自我介绍
        // 計算出顯示完內容需要的最小尺寸
        
        CGSize textSize;
        if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
            NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
            textSize = [content boundingRectWithSize:CGSizeMake(contentWidth, MAXFLOAT)
                                             options:options
                                          attributes:attributes
                                             context:nil].size;
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            textSize = [content sizeWithFont:font
                           constrainedToSize:CGSizeMake(contentWidth, MAXFLOAT)
                               lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
            
        }
        return totalHeight + height1 + height2 + textSize.height;
    }else if (indexPath.section == 1){//动态计算高度
        NSArray *posts = [userinfo objectForKey:@"posts"];
        if ([posts count] == 0) {
            return 90;
        }else{
            
            NSDictionary *post = [[posts objectAtIndex:0] cleanNull];
            NSString *pic_url = [post objectForKey:@"pic_url"];
            NSString *post_body = [post objectForKey:@"post_body"];
            
            CGFloat labelWidth;
            if ([pic_url hasSuffix:@"post.jpg"]) {//无图片
                labelWidth = ([UIScreen mainScreen].bounds.size.width - 62 - 8 - 33);
            }else{
                labelWidth = ([UIScreen mainScreen].bounds.size.width - 142 - 8 - 33);
            }
            
            UIFont *font = [UIFont systemFontOfSize:13];
            CGSize textSize;
            if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                //[paragraphStyle setLineSpacing:5];//调整行间距
                NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
                textSize = [post_body boundingRectWithSize:CGSizeMake(labelWidth, MAXFLOAT)
                                                   options:options
                                                attributes:attributes
                                                   context:nil].size;
            }
            CGFloat height;
            if (15 + 8 + textSize.height + 8 + 15 < 65) {
                height = 65;
            }else{
                height = 15 + 8 + textSize.height + 8 + 15;
            }
            return 14 + height + 8;
        }
    }else if (indexPath.section == 2){//邀约计算高度
        
        NSArray *activities = [userinfo objectForKey:@"activities"];
        
        if ([activities count] == 0) {
            return 167;
        }else{
            NSDictionary *activity = [[activities objectAtIndex:indexPath.row] cleanNull];
            NSString *pic_url = [activity objectForKey:@"pic_url"];
            NSString *description = [activity objectForKey:@"description"];
            NSString *location_desc = [activity objectForKey:@"location_desc"];
            CGFloat label1Width = ([UIScreen mainScreen].bounds.size.width - 45 - 8 - 8 - 65);
            
            if ([pic_url hasSuffix:@"activity.jpg"]) {//没有图片
                label1Width += 65;
            }
            
            UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
            CGSize textSize;
            CGSize textSize2;
            if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                //[paragraphStyle setLineSpacing:5];//调整行间距
                NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
                textSize = [description boundingRectWithSize:CGSizeMake(label1Width, MAXFLOAT)
                                                     options:options
                                                  attributes:attributes
                                                     context:nil].size;
                
                textSize2 = [location_desc boundingRectWithSize:CGSizeMake(label1Width, MAXFLOAT)
                                                        options:options
                                                     attributes:attributes
                                                        context:nil].size;
            }
            
            CGFloat height;
            if (![pic_url hasSuffix:@"activity.jpg"]) {//有图片
                if (textSize.height + 8 + textSize2.height > 65) {
                    height = textSize.height + 8 + textSize2.height;
                }else{
                    height = 65;
                }
            }else{//没有图片
                height = textSize.height + 8 + textSize2.height;
            }
            
            return 44 + height + 10 + 34 + 10;
        }
        
    }else if (indexPath.section == 3){//礼物
        return 167;
    }else if (indexPath.section == 4){//电话
        return 50;
    }
    else if (indexPath.section == 5){//个人信息
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 15 - 10 - 15;
        switch (indexPath.row) {
            case 2:
            {
                NSString *aboutme = [userinfo objectForKey:@"aboutme"];
                aboutme =  [aboutme isEqualToString:@""] ? @"未填" : aboutme;
                UIFont *font = [UIFont systemFontOfSize:13];
                CGSize leftTextSize;
                CGSize textSize;
                if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
                    
                    leftTextSize = [@"对爱情的看法" boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                           options:options
                                                        attributes:attributes
                                                           context:nil].size;
                    textSize = [aboutme boundingRectWithSize:CGSizeMake(width - leftTextSize.width, MAXFLOAT)
                                                     options:options
                                                  attributes:attributes
                                                     context:nil].size;
                }
                if (textSize.height + 17 +17 > 50) {
                    return textSize.height + 17 + 17;
                }else{
                    return 50;
                }
            }
                break;
            case 11:
            {
                NSString *aiqing = [userinfo objectForKey:@"aiqing"];//对爱情的想法
                aiqing =  [aiqing isEqualToString:@""] ? @"未填" : aiqing;
                
                UIFont *font = [UIFont systemFontOfSize:13];
                CGSize leftTextSize;
                CGSize textSize;
                if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
                    
                    leftTextSize = [@"对爱情的看法" boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                           options:options
                                                        attributes:attributes
                                                           context:nil].size;
                    textSize = [aiqing boundingRectWithSize:CGSizeMake(width - leftTextSize.width, MAXFLOAT)
                                                    options:options
                                                 attributes:attributes
                                                    context:nil].size;
                }
                if (textSize.height + 17 +17 > 50) {
                    return textSize.height + 17 + 17;
                }else{
                    return 50;
                }
            }
                break;
                
            default:
                return 50;
                break;
        }
    }else if (indexPath.section == 6){
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 15 - 10 - 15;
        switch (indexPath.row) {
            case 0:
            {
                NSString *xue = [userinfo objectForKey:@"xue"];
                xue =  [xue isEqualToString:@""] ? @"未填" : xue;
                
                UIFont *font = [UIFont systemFontOfSize:13];
                CGSize leftTextSize;
                CGSize textSize;
                if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
                    
                    leftTextSize = [@"想学" boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                       options:options
                                                    attributes:attributes
                                                       context:nil].size;
                    textSize = [xue boundingRectWithSize:CGSizeMake(width - leftTextSize.width, MAXFLOAT)
                                                 options:options
                                              attributes:attributes
                                                 context:nil].size;
                }
                if (textSize.height + 17 +17 > 50) {
                    return textSize.height + 17 + 17;
                }else{
                    return 50;
                }
            }
                break;
            case 1:
            {
                NSString *chang = [userinfo objectForKey:@"chang"];
                chang =  [chang isEqualToString:@""] ? @"未填" : chang;
                
                UIFont *font = [UIFont systemFontOfSize:13];
                CGSize leftTextSize;
                CGSize textSize;
                if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
                    
                    leftTextSize = [@"擅长" boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                       options:options
                                                    attributes:attributes
                                                       context:nil].size;
                    textSize = [chang boundingRectWithSize:CGSizeMake(width - leftTextSize.width, MAXFLOAT)
                                                   options:options
                                                attributes:attributes
                                                   context:nil].size;
                }
                if (textSize.height + 17 +17 > 50) {
                    return textSize.height + 17 + 17;
                }else{
                    return 50;
                }
            }
                break;
            case 2:
            {
                NSString *manyi = [userinfo objectForKey:@"manyi"];
                manyi =  [manyi isEqualToString:@""] ? @"未填" : manyi;
                
                UIFont *font = [UIFont systemFontOfSize:13];
                CGSize leftTextSize;
                CGSize textSize;
                if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
                    
                    leftTextSize = [@"最满意部位" boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                          options:options
                                                       attributes:attributes
                                                          context:nil].size;
                    textSize = [manyi boundingRectWithSize:CGSizeMake(width - leftTextSize.width, MAXFLOAT)
                                                   options:options
                                                attributes:attributes
                                                   context:nil].size;
                }
                if (textSize.height + 17 +17 > 50) {
                    return textSize.height + 17 + 17;
                }else{
                    return 50;
                }
            }
                break;
            default:
                return 50;
                break;
        }
    }else{
        return 44;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) {//动态
        NSArray *posts = [userinfo objectForKey:@"posts"];
        if ([posts count] == 0) {
            return 1;
        }else{
            return 1;
        }
    }
    else if (section == 2) {//邀约
        NSArray *activities = [userinfo objectForKey:@"activities"];
        if ([activities count] == 0) {
            return 1;
        }else{
            return [activities count];
        }
    }else if (section == 3){//礼物
        return 1;
    }else if (section == 4){//电话
        return 1;
    }else if (section == 5){//个人象形
        return 13;
    }else if (section == 6){//个人喜好
        return 3;
    }else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {//头像
        if (indexPath.row == 0) {
            GrzxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GrzxTableViewCell"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"GrzxTableViewCell" owner:self options:nil] lastObject];
                cell.userImage.layer.cornerRadius = 50;
                cell.userImage.layer.masksToBounds = YES;
//                [cell.gongkaiBtn addTarget:self action:@selector(gongkaiBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.yinsiBtn addTarget:self action:@selector(yinsiBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                if (view1 == nil) {
                    view1 = cell.view1;
                }
                if (view2 == nil) {
                    view2 = cell.view2;
                }
            }
            
            NSString *avatar_url = [userinfo objectForKey:@"avatar_url"];//头像
            
            if (avatar_url == nil || [avatar_url isEqualToString:@""]) {
                //                cell.userImageCenter.hidden = NO;
                //                cell.userImageBtn.hidden = NO;
            }else{
                //                cell.userImageCenter.hidden = YES;
                //                cell.userImageBtn.hidden = YES;
                [cell.userImage setImageWithURL:[NSURL URLWithString:avatar_url]];
            }
            
            NSString *nickname = [userinfo objectForKey:@"nickname"];//昵称
            NSString *aboutme = [userinfo objectForKey:@"aboutme"];//自我介绍
            cell.nameLabel.text = nickname;
            
            if ([aboutme isEqualToString:@""]) {
                cell.jieshaoLabel.text = @"未填写个性签名";
            }else{
                cell.jieshaoLabel.text = aboutme;
            }
            
//            UITapGestureRecognizer *jieshaotap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toJieshao)];
//            [cell.jieshaoLabel addGestureRecognizer:jieshaotap];
            
            
            NSString *birthday = [userinfo objectForKey:@"birthday"];
            if (birthday == nil || [birthday isEqualToString:@""] || (birthday != nil && [birthday isEqualToString:@"1900-01-01"])) {
                cell.ageLabel.text = @"-";
            }else{
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                NSDate *date= [dateFormatter dateFromString:birthday];
                NSInteger age = [NSDate ageWithDateOfBirth:date];
                cell.ageLabel.text = [NSString stringWithFormat:@"%ld岁",(long)age];
            }
            
            NSNumber *sexnum = [userinfo objectForKey:@"sex"];
            switch ([sexnum intValue]) {
                case 0:
                    cell.sexImageView.image = [UIImage imageNamed:@"man"];
                    break;
                case 1:
                    cell.sexImageView.image = [UIImage imageNamed:@"women"];
                    break;
                default:
                    break;
            }
            
            NSNumber *count_a = [userinfo objectForKey:@"count_a"];
            NSNumber *count_b = [userinfo objectForKey:@"count_b"];
            cell.btn1.text = [NSString stringWithFormat:@"%d\n%@",[count_a intValue],@"关注数"];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:cell.btn1.text];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,cell.btn1.text.length - 3)];
            cell.btn1.attributedText = str;
//            UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myaction:)];
//            [cell.btn1 addGestureRecognizer:click];
            
            cell.btn2.text = [NSString stringWithFormat:@"%d\n%@",[count_b intValue],@"被关注数"];
            NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:cell.btn2.text];
            [str2 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,cell.btn2.text.length - 4)];
            cell.btn2.attributedText = str2;
//            UITapGestureRecognizer *click2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myaction:)];
//            [cell.btn2 addGestureRecognizer:click2];
            NSArray *posts = [userinfo objectForKey:@"posts"];
            cell.btn3.text = [NSString stringWithFormat:@"%lu\n%@",(unsigned long)[posts count],@"动态数"];
            NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:cell.btn3.text];
            [str3 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,cell.btn3.text.length - 3)];
            cell.btn3.attributedText = str3;
//            UITapGestureRecognizer *click3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myaction:)];
//            [cell.btn3 addGestureRecognizer:click3];
            
            
            NSNumber *connected = [userinfo objectForKey:@"connected"];//是否关注 1 关注 0未关注

            if ([connected boolValue]) {//已关注
                cell.likeBtn.imageView.image = [UIImage imageNamed:@"like"];
                [cell.likeBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateNormal];
                [cell.likeBtn setImage:[UIImage imageNamed:@"like"] forState:UIControlStateHighlighted];
            }else{//未关注
                cell.likeBtn.imageView.image = [UIImage imageNamed:@"unlike2"];
                [cell.likeBtn setImage:[UIImage imageNamed:@"unlike2"] forState:UIControlStateNormal];
                [cell.likeBtn setImage:[UIImage imageNamed:@"unlike2"] forState:UIControlStateHighlighted];
            }
            
            [cell.likeBtn addTarget:self action:@selector(like) forControlEvents:UIControlEventTouchUpInside];
//            chatBtn = cell.talkBtn;
            [cell.talkBtn addTarget:self action:@selector(chat) forControlEvents:UIControlEventTouchUpInside];
//            NSInteger totalUnreadCount = [[CDStorage storage] countUnread];
//            chatBtn.badgeValue = [NSString stringWithFormat:@"%d",totalUnreadCount];
            return cell;
            
            
            
//            UserDetailTableViewCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell1"];
//            if (cell == nil) {
//                cell = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell1" owner:self options:nil] lastObject];
//                
//                cell.likebtn.layer.borderWidth = 1.0;
//                cell.likebtn.layer.borderColor = [UIColor whiteColor].CGColor;
//                cell.likebtn.layer.cornerRadius = 20.0;
//                cell.likebtn.layer.masksToBounds = YES;
//                [cell.likebtn addTarget:self action:@selector(like) forControlEvents:UIControlEventTouchUpInside];
//                
//                cell.chatbtn.layer.borderWidth = 1.0;
//                cell.chatbtn.layer.borderColor = [UIColor whiteColor].CGColor;
//                cell.chatbtn.layer.cornerRadius = 20.0;
//                cell.chatbtn.layer.masksToBounds = YES;
//                [cell.chatbtn addTarget:self action:@selector(chat) forControlEvents:UIControlEventTouchUpInside];
//                
////                UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-20, 60) byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
////                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
////                maskLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-20, 60);
////                maskLayer.path = maskPath.CGPath;
////                cell.userImageBottom.layer.mask = maskLayer;
//                view1 = cell.view1;
//            }
//            
//            NSNumber *connected = [userinfo objectForKey:@"connected"];//是否关注 1 关注 0未关注
//            
//            if ([connected boolValue]) {//已关注
//                cell.likebtn.imageView.image = [UIImage imageNamed:@"like_love1_v1"];
//            }else{//未关注
//                cell.likebtn.imageView.image = [UIImage imageNamed:@"menu9_v1_2x"];
//            }
//            
//            
//            NSString *avatar_url = [userinfo objectForKey:@"avatar_url"];//头像
//            [cell.userImage setImageWithURL:[NSURL URLWithString:avatar_url]];
//            return cell;
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {//动态
            NSArray *posts = [userinfo objectForKey:@"posts"];
            if ([posts count] == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dogntaicell"];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"dogntaicell"];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 32, 20)];
                    label.font = [UIFont systemFontOfSize:14];
                    label.text = @"动态";
                    label.textColor = [UIColor blackColor];
                    [label sizeToFit];
                    [cell.contentView addSubview:label];
                    
                    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(60, 15, [UIScreen mainScreen].bounds.size.width - 70 - 40, 60)];
                    label2.font = [UIFont systemFontOfSize:13];
                    label2.textAlignment = NSTextAlignmentCenter;
                    label2.text = @"这个人很懒，什么都没发布";
                    label2.textColor = [UIColor lightGrayColor];
                    label2.backgroundColor = RGBACOLOR(240, 240, 240, 1);
                    [cell.contentView addSubview:label2];
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                return cell;
            }else{
                UserDetailTableViewCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell2"];
                if (cell == nil) {
                    cell = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell2" owner:self options:nil] lastObject];
                }
                NSDictionary *post = [[posts objectAtIndex:0] cleanNull];
                NSString *created_at = [post objectForKey:@"created_at"];
                NSString *pic_url = [post objectForKey:@"pic_url"];
                NSString *post_body = [post objectForKey:@"post_body"];
                
                cell.dateLabel.text = created_at;
                if ([pic_url hasSuffix:@"post.jpg"]) {//没有图片
                    cell.imageviewWidth.constant = 0;
                    cell.leadingSpace.constant = 0;
                }else{
                    [cell.userImageView setImageWithURL:[NSURL URLWithString:pic_url] placeholderImage:[UIImage imageNamed:@"public_load"]];
                }
                cell.descLabel.text = post_body;
                return cell;
            }
        }
    }else if (indexPath.section == 2){//邀约
        NSArray *activities = [userinfo objectForKey:@"activities"];
        if ([activities count] == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"zanwuyaoyuecell"];
            return cell;
        }else{
            UserDetailTableViewCell3 *cell = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell3"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell3" owner:self options:nil] lastObject];
                cell.btn.layer.borderColor = RGBACOLOR(90, 175, 235, 1).CGColor;
                cell.btn.layer.borderWidth = 1.0;
                cell.btn.layer.cornerRadius = 17.0;
                cell.btn.layer.masksToBounds = YES;
                [cell.numLabel setHidden:YES];
            }
            NSDictionary *activity = [[activities objectAtIndex:indexPath.row] cleanNull];
            
            NSString *pic_url = [activity objectForKey:@"pic_url"];
            NSString *location_desc = [activity objectForKey:@"location_desc"];
            NSString *description = [activity objectForKey:@"description"];
            NSNumber *typen = [activity objectForKey:@"type"];
            
            switch ([typen intValue]) {
                case 0:
                    cell.typeLabel.text = @"一般约会";
                    break;
                case 1:
                    cell.typeLabel.text = @"饭饭之交";
                    break;
                case 2:
                    cell.typeLabel.text = @"约定一生";
                    break;
                default:
                    cell.typeLabel.text = @"";
                    break;
            }
            cell.descLabel.font = [UIFont systemFontOfSize:14];
            cell.descLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.descLabel.text = description;
            cell.addressLabel.text = location_desc;
            if ([pic_url hasSuffix:@"activity.jpg"]) {//没有图片
                cell.imageviewWidth.constant = 0;
            }else{
                [cell.userImageView setImageWithURL:[NSURL URLWithString:pic_url] placeholderImage:[UIImage imageNamed:@"public_load"]];
            }
            if (indexPath.row == [activities count]) {
                [cell.bottomLabel setHidden:YES];
            }
            return cell;
        }
    }
    else if (indexPath.section == 3){//礼物
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell4"];
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userdetailcell4"];
//        }
//        cell.textLabel.text = @"她想去的餐厅 (1)";
//        cell.textLabel.font = [UIFont systemFontOfSize:13];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        return cell;
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"liwucell"];
        return cell;
    }
    else if (indexPath.section == 4){
        
        UserDetailTableViewCell5 *cell = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell55"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell5" owner:self options:nil] lastObject];
            cell.rightLayoutCons.constant = 15;
        }
        
        NSNumber *type = [loginUserInfo objectForKey:@"type"];
        if ([type intValue] >=10) {
            NSString *phone = [userinfo objectForKey:@"phone"];//电话
            cell.rightLabel.text = [phone isEqualToString:@""] ? @"未填" : phone;
        }else{
            cell.rightLabel.text = @"仅VIP可查看联系方式";
        }
        
        cell.leftLabel.text = @"手机号";
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
    else if (indexPath.section == 5){
        UserDetailTableViewCell5 *cell = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell5"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell5" owner:self options:nil] lastObject];
            cell.rightLayoutCons.constant = 15;
        }
        
        if (indexPath.row < 12) {
            UILabel *bottom = [[UILabel alloc] initWithFrame:CGRectMake(15, 49, [UIScreen mainScreen].bounds.size.width-15, 1)];
            bottom.backgroundColor = RGBACOLOR(229, 229, 229, 1);
            bottom.tag = 999;
            [cell.contentView addSubview:bottom];
        }
        
        NSNumber *userid = [userinfo objectForKey:@"id"];
        NSString *nickname = [userinfo objectForKey:@"nickname"];//昵称
        NSString *aboutme = [userinfo objectForKey:@"aboutme"];//自我介绍
        NSString *xuanshi = [userinfo objectForKey:@"xuanshi"];//美丽宣誓
        NSString *qinggan = [userinfo objectForKey:@"qinggan"];//感情状况
        NSString *diqu = [userinfo objectForKey:@"diqu"];//地区
//        NSString *age = [userinfo objectForKey:@"age"];//年龄
        NSString *zhiye = [userinfo objectForKey:@"zhiye"];//职业
        NSString *shouru = [userinfo objectForKey:@"shouru"];//收入
        NSString *shengao = [userinfo objectForKey:@"shengao"];//身高
        NSString *tizhong = [userinfo objectForKey:@"tizhong"];//体重
        NSString *aiqing = [userinfo objectForKey:@"aiqing"];//对爱情的想法
        NSString *xing = [userinfo objectForKey:@"xing"];//对性的想法
        
        switch (indexPath.row) {
            case 0:
                cell.leftLabel.text = @"转角ID";
                cell.rightLabel.text = [[userid stringValue] isEqualToString:@""] ? @"未填" : [userid stringValue];
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 1:
                cell.leftLabel.text = @"昵称";
                cell.rightLabel.text = [nickname isEqualToString:@""] ? @"未填" : nickname;
                break;
            case 2:
            {
                UserDetailTableViewCell5 *cell5 = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell5"];
                if (cell5 == nil) {
                    cell5 = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell5" owner:self options:nil] lastObject];
                }
                cell5.leftLabel.text = @"自我介绍";
                cell5.rightLabel.text = [aboutme isEqualToString:@""] ? @"未填" : aboutme;
                cell5.rightLabel.textAlignment = [aboutme isEqualToString:@""] ? NSTextAlignmentRight : NSTextAlignmentLeft;
                cell5.rightLabel.numberOfLines = 0;
                CGFloat width = [UIScreen mainScreen].bounds.size.width - 15 - 10 - 15;
                UIFont *font = [UIFont systemFontOfSize:13];
                CGSize leftTextSize;
                CGSize textSize;
                if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
                    leftTextSize = [cell5.leftLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 16)
                                                                      options:options
                                                                   attributes:attributes
                                                                      context:nil].size;
                    textSize = [cell5.rightLabel.text boundingRectWithSize:CGSizeMake(width - leftTextSize.width, MAXFLOAT)
                                                                   options:options
                                                                attributes:attributes
                                                                   context:nil].size;
                }
                CGFloat height;
                if (textSize.height + 17 +17 > 50) {
                    height = textSize.height + 17 + 17;
                }else{
                    height = 50;
                }
                [cell5.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[UILabel class]]) {
                        UILabel *label = (UILabel *)obj;
                        if (label.tag == 999) {
                            [label removeFromSuperview];
                        }
                    }
                }];
                UILabel *bottom = [[UILabel alloc] initWithFrame:CGRectMake(15, height-1, [UIScreen mainScreen].bounds.size.width-15, 1)];
                bottom.backgroundColor = RGBACOLOR(229, 229, 229, 1);
                bottom.tag = 999;
                [cell5.contentView addSubview:bottom];
                cell5.rightLayoutCons.constant = 15;
                return cell5;
            }
                break;
            case 3:
                cell.leftLabel.text = @"美丽宣誓";
                cell.rightLabel.text = [xuanshi isEqualToString:@""] ? @"未填" : xuanshi;
                cell.rightLabel.textAlignment = NSTextAlignmentRight;
                break;
            case 4:
                cell.leftLabel.text = @"感情状况";
                cell.rightLabel.text = [qinggan isEqualToString:@""] ? @"未填" : qinggan;
                cell.rightLabel.textAlignment = NSTextAlignmentRight;
                break;
            case 5:
                cell.leftLabel.text = @"所在地区";
                cell.rightLabel.text = [diqu isEqualToString:@""] ? @"未填" : diqu;
                break;
            case 6:
            {
                cell.leftLabel.text = @"年龄";
                NSString *birthday = [userinfo objectForKey:@"birthday"];
                if (birthday == nil || [birthday isEqualToString:@""] || (birthday != nil && [birthday isEqualToString:@"1900-01-01"])) {
                    cell.rightLabel.text = @"未填";
                }else{
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSDate *date= [dateFormatter dateFromString:birthday];
                    NSInteger age = [NSDate ageWithDateOfBirth:date];
                    cell.rightLabel.text = [NSString stringWithFormat:@"%ld",(long)age];
                }
            }
                
                
                break;
            case 7:
                cell.leftLabel.text = @"职业";
                cell.rightLabel.text = [zhiye isEqualToString:@""] ? @"未填" : zhiye;
                break;
            case 8:
                cell.leftLabel.text = @"收入";
                cell.rightLabel.text = [shouru isEqualToString:@""] ? @"未填" : shouru;
                break;
            case 9:
                cell.leftLabel.text = @"身高";
                cell.rightLabel.text = [shengao isEqualToString:@""] ? @"未填" : [NSString stringWithFormat:@"%@",shengao];
                break;
            case 10:
                cell.leftLabel.text = @"体重";
                cell.rightLabel.text = [tizhong isEqualToString:@""] ? @"未填" : tizhong;
                break;
            case 11:
            {
                UserDetailTableViewCell5 *cell5 = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell6"];
                if (cell5 == nil) {
                    cell5 = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell5" owner:self options:nil] lastObject];
                }
                cell5.leftLabel.text = @"对爱情的看法";
                cell5.rightLabel.text = [aiqing isEqualToString:@""] ? @"未填" : aiqing;
                cell5.rightLabel.textAlignment = [aiqing isEqualToString:@""] ? NSTextAlignmentRight : NSTextAlignmentLeft;
                cell5.rightLabel.numberOfLines = 0;
                CGFloat width = [UIScreen mainScreen].bounds.size.width - 15 - 10 - 15;
                UIFont *font = [UIFont systemFontOfSize:13];
                CGSize leftTextSize;
                CGSize textSize;
                if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
                    leftTextSize = [cell5.leftLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 16)
                                                                      options:options
                                                                   attributes:attributes
                                                                      context:nil].size;
                    textSize = [cell5.rightLabel.text boundingRectWithSize:CGSizeMake(width - leftTextSize.width, MAXFLOAT)
                                                                   options:options
                                                                attributes:attributes
                                                                   context:nil].size;
                }
                CGFloat height;
                if (textSize.height + 17 +17 > 50) {
                    height = textSize.height + 17 + 17;
                }else{
                    height = 50;
                }
                UILabel *bottom = [[UILabel alloc] initWithFrame:CGRectMake(15, height-1, [UIScreen mainScreen].bounds.size.width-15, 1)];
                bottom.backgroundColor = RGBACOLOR(229, 229, 229, 1);
                bottom.tag = 999;
                [cell5.contentView addSubview:bottom];
                cell5.rightLayoutCons.constant = 15;
                return cell5;
            }
                break;
            case 12:
                cell.leftLabel.text = @"对性的看法";
                cell.rightLabel.text = [xing isEqualToString:@""] ? @"未填" : xing;
                [cell.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[UILabel class]]) {
                        UILabel *label = (UILabel *)obj;
                        if (label.tag == 999) {
                            [label setHidden:YES];
                            *stop = YES;
                        }
                    }
                }];
                break;
            default:
                break;
        }
        return cell;
    }
    else if (indexPath.section == 6){
        
        NSString *xue = [userinfo objectForKey:@"xue"];
        NSString *chang = [userinfo objectForKey:@"chang"];
        NSString *manyi = [userinfo objectForKey:@"manyi"];
        
        switch (indexPath.row) {
            case 0:
            {
                UserDetailTableViewCell5 *cell5 = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell7"];
                if (cell5 == nil) {
                    cell5 = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell5" owner:self options:nil] lastObject];
                }
                cell5.leftLabel.text = @"想学";
                cell5.rightLabel.text = [xue isEqualToString:@""] ? @"未填" : xue;
                cell5.rightLabel.textAlignment = [xue isEqualToString:@""] ? NSTextAlignmentRight : NSTextAlignmentLeft;
                cell5.rightLabel.numberOfLines = 0;
                CGFloat width = [UIScreen mainScreen].bounds.size.width - 15 - 10 - 15;
                UIFont *font = [UIFont systemFontOfSize:13];
                CGSize leftTextSize;
                CGSize textSize;
                if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
                    leftTextSize = [cell5.leftLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 16)
                                                                      options:options
                                                                   attributes:attributes
                                                                      context:nil].size;
                    textSize = [cell5.rightLabel.text boundingRectWithSize:CGSizeMake(width - leftTextSize.width, MAXFLOAT)
                                                                   options:options
                                                                attributes:attributes
                                                                   context:nil].size;
                }
                CGFloat height;
                if (textSize.height + 17 +17 > 50) {
                    height = textSize.height + 17 + 17;
                }else{
                    height = 50;
                }
                UILabel *bottom = [[UILabel alloc] initWithFrame:CGRectMake(15, height-1, [UIScreen mainScreen].bounds.size.width-15, 1)];
                bottom.backgroundColor = RGBACOLOR(229, 229, 229, 1);
                bottom.tag = 999;
                [cell5.contentView addSubview:bottom];
                cell5.rightLayoutCons.constant = 15;
                return cell5;
            }
                break;
            case 1:
            {
                UserDetailTableViewCell5 *cell5 = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell8"];
                if (cell5 == nil) {
                    cell5 = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell5" owner:self options:nil] lastObject];
                }
                cell5.leftLabel.text = @"擅长";
                cell5.rightLabel.text = [chang isEqualToString:@""] ? @"未填" : chang;
                cell5.rightLabel.textAlignment = [chang isEqualToString:@""] ? NSTextAlignmentRight : NSTextAlignmentLeft;
                cell5.rightLabel.numberOfLines = 0;
                
                CGFloat width = [UIScreen mainScreen].bounds.size.width - 15 - 10 - 15;
                UIFont *font = [UIFont systemFontOfSize:13];
                CGSize leftTextSize;
                CGSize textSize;
                if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                    NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
                    leftTextSize = [cell5.leftLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, 16)
                                                                      options:options
                                                                   attributes:attributes
                                                                      context:nil].size;
                    textSize = [cell5.rightLabel.text boundingRectWithSize:CGSizeMake(width - leftTextSize.width, MAXFLOAT)
                                                                   options:options
                                                                attributes:attributes
                                                                   context:nil].size;
                }
                CGFloat height;
                if (textSize.height + 17 +17 > 50) {
                    height = textSize.height + 17 + 17;
                }else{
                    height = 50;
                }
                UILabel *bottom = [[UILabel alloc] initWithFrame:CGRectMake(15, height-1, [UIScreen mainScreen].bounds.size.width-15, 1)];
                bottom.backgroundColor = RGBACOLOR(229, 229, 229, 1);
                bottom.tag = 999;
                [cell5.contentView addSubview:bottom];
                cell5.rightLayoutCons.constant = 15;
                return cell5;
            }
                break;
            case 2:
            {
                UserDetailTableViewCell5 *cell5 = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell9"];
                if (cell5 == nil) {
                    cell5 = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell5" owner:self options:nil] lastObject];
                }
                cell5.leftLabel.text = @"最满意部位";
                cell5.rightLabel.text = [manyi isEqualToString:@""] ? @"未填" : manyi;
                cell5.rightLabel.textAlignment = [manyi isEqualToString:@""] ? NSTextAlignmentRight : NSTextAlignmentLeft;
                cell5.rightLabel.numberOfLines = 0;
                cell5.rightLayoutCons.constant = 15;
                return cell5;
            }
                break;
            default:
                break;
        }
        return nil;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }else if (section == 2 || section == 3){
        return 30;
    }else{
        return 5;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1 || section == 2) {
        return 10;
    }else if(section < 6){
        return 5;
    }else{
        return 20;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 20, 10)];
        NSArray *activities = [userinfo objectForKey:@"activities"];
        label.text = [NSString stringWithFormat:@"邀约 (%lu)",(unsigned long)[activities count]];;
        label.font = [UIFont systemFontOfSize:13];
        [label sizeToFit];
        [view addSubview:label];
        return view;
    }else if (section == 3) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 20, 10)];
        NSArray *activities = [userinfo objectForKey:@"activities"];
        label.text = [NSString stringWithFormat:@"礼物 (%lu)",(unsigned long)[activities count]];;
        label.font = [UIFont systemFontOfSize:13];
        [label sizeToFit];
        [view addSubview:label];
        return view;
    }else{
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 5)];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
    
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 5)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 1://动态
        {
            switch (indexPath.row) {
                case 0:
                {
                    DongtaiTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DongtaiTableViewController"];
                    NSNumber *userid = [userinfo objectForKey:@"id"];
                    vc.userid = [NSString stringWithFormat:@"%d",[userid intValue]];
                    vc.title = [NSString stringWithFormat:@"%@的动态",self.title];
                    
                    NSString *avatar_url = [userinfo objectForKey:@"avatar_url"];//头像
                    NSString *nickname = [userinfo objectForKey:@"nickname"];
                    if ([nickname isEqualToString:@""]) {
                        nickname = [NSString stringWithFormat:@"%d",[userid intValue]];
                    }
                    
                    NSNumber *sex = [userinfo objectForKey:@"sex"];
                    NSString *birthday = [userinfo objectForKey:@"birthday"];
                    vc.birthday = birthday;
                    vc.sexnum = sex;
                    vc.avatar_url = avatar_url;
                    vc.nickname = nickname;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2://邀约
        {
            NSArray *activities = [userinfo objectForKey:@"activities"];
            
            if ([activities count] == 0) {
            }else{
                YaoyueDetailViewController *vc = [[YaoyueDetailViewController alloc] init];
                vc.title = @"邀约";
                vc.activityDic = [[activities objectAtIndex:indexPath.row] cleanNull];
                [self.navigationController pushViewController:vc animated:YES];
            }
            
            
        }
            break;
        case 3://礼物
        {
            GiveGiftViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GiveGiftViewController"];
            NSNumber *receive_user_id = [userinfo objectForKey:@"id"];
            NSString *avatar_url = [userinfo objectForKey:@"avatar_url"];
            vc.receive_user_id = receive_user_id;
            vc.avatar_url = avatar_url;
            NSNumber *userid = [userinfo objectForKey:@"id"];
            NSString *nickname = [userinfo objectForKey:@"nickname"];
            NSString *receive_user_name;
            if ([nickname isEqualToString:@""]) {
                receive_user_name = [NSString stringWithFormat:@"%d",[userid intValue]];
            }else{
                receive_user_name = nickname;
            }
            vc.receive_user_name = receive_user_name;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
    
    
}

//喜欢
-(void)like{
    NSNumber *user_b_id = [userinfo objectForKey:@"id"];
    
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:user_b_id forKey:@"user_b_id"];
    
    [self showHudInView:self.view hint:@"加载中"];
    
    NSNumber *connected = [userinfo objectForKey:@"connected"];//是否关注 1 关注 0未关注
    NSString *urlString;
    if ([connected boolValue]) {//已关注
        urlString = [NSString stringWithFormat:@"%@%@",HOST,CONTACT_DESTROY_URL];
    }else{
        urlString = [NSString stringWithFormat:@"%@%@",HOST,CONSTACTS_CREATE_URL];
        
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager POST:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self hideHud];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                GrzxTableViewCell *cell = (GrzxTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                if ([connected boolValue]) {//已关注 设置取消
                    [userinfo setObject:[NSNumber numberWithBool:NO] forKey:@"connected"];
                    cell.likeBtn.imageView.image = [UIImage imageNamed:@"unlike2"];
                    [self showHintInCenter:@"取消关注!"];
                }else{//未关注 添加关注
                    [userinfo setObject:[NSNumber numberWithBool:YES] forKey:@"connected"];
                    cell.likeBtn.imageView.image = [UIImage imageNamed:@"like"];
                    [self showHintInCenter:@"关注成功!"];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshIlike" object:nil];
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

//聊天
-(void)chat{
    WEAKSELF
    NSNumber *userid = [userinfo objectForKey:@"id"];
    [[CDIM sharedInstance] fetchConvWithOtherId:[userid stringValue] callback : ^(AVIMConversation *conversation, NSError *error) {
        if (error) {
            DLog(@"%@", error);
        }
        else {
            LCEChatRoomVC *chatRoomVC = [[LCEChatRoomVC alloc] initWithConv:conversation];
            [weakSelf.navigationController pushViewController:chatRoomVC animated:YES];
        }
    }];
}

@end
