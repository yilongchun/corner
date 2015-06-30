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

#import "YaoyueDetailViewController.h"

#import "DongtaiTableViewController.h"
#import "LCEChatRoomVC.h"
#import "SVPullToRefresh.h"

@interface UserDetailTableViewController (){
    NSDictionary *userinfo;
    
    UIView *view1;//公开照片 父视图
    NSMutableArray *photo1;//公开照片
    int currentImageIndex;//当前点击的图片
    CGRect resetRect;
    BOOL rectFlag;
}

@end

@implementation UserDetailTableViewController
@synthesize userinfo;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIImage *image = [[UIImage imageNamed:@"pub_title_8_v1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(action1)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    photo1 = [NSMutableArray array];
    rectFlag = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
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
        [self loadData];
    });
}

-(void)loadData{
    NSString *userid = [userinfo objectForKey:@"id"];
    
//    [self showHudInView:self.view hint:@"加载中"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@",HOST,USER_DETAIL_URL,userid];
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
                userinfo = [[dic objectForKey:@"message"] cleanNull];
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
                
                NSArray *photos = [userinfo objectForKey:@"photos"];
                [photo1 removeAllObjects];
                for (int i = 0; i < [photos count]; i++) {
                    NSDictionary *imgdic = [photos objectAtIndex:i];
                    //                    NSString *url = [dic objectForKey:@"url"];
                    NSNumber *imagetype = [imgdic objectForKey:@"type"];
                    NSNumber *status = [imgdic objectForKey:@"status"];
                    if ([imagetype intValue]== 0) {//公开
                        if ([status intValue] == 0) {
                            [photo1 addObject:imgdic];
                        }
                    }
                }
                [self.tableView reloadData];
                //设置第一行的公开图片和隐私图片
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                UserDetailTableViewCell1 *cell = (UserDetailTableViewCell1 *)[self.tableView cellForRowAtIndexPath:indexPath];
                [self addPicture:cell];
                
                
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
-(void)addPicture:(UserDetailTableViewCell1 *)cell{
    
    [cell.view1.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIButton *btn = obj;
        if (btn.tag != -1) {
            [btn removeFromSuperview];
        }
    }];
    
    if (rectFlag == NO) {
        resetRect = cell.gongkaiBtn.frame;
        rectFlag = YES;
    }
    
    [cell.gongkaiBtn setFrame:resetRect];
    
    for (int i = 0; i < [photo1 count]; i++) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:cell.gongkaiBtn.frame];
        img.contentMode = UIViewContentModeScaleToFill;
//        img.layer.cornerRadius = 5.0;
//        img.layer.masksToBounds = YES;
        [img setImageWithURL:[NSURL URLWithString:[[photo1 objectAtIndex:i] objectForKey:@"url"]]];
        img.tag = i;
        img.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
        [img addGestureRecognizer:tap];
        
        [cell.view1 addSubview:img];
        
        CGRect rect = cell.gongkaiBtn.frame;
        
        if (i !=0 && (i+1) % 4 == 0) {//应该换行
            rect.origin.x = 0;
            rect.origin.y = (i / 3) * (rect.size.height + 2);
            cell.leadingConstraint.constant = rect.origin.x;
            cell.topConstraint.constant = rect.origin.y;
            
            cell.view1HeightConstraint.constant = rect.origin.y + rect.size.height + 2;
        }else{
            rect.origin.x = cell.gongkaiBtn.frame.size.width + cell.gongkaiBtn.frame.origin.x + 2;
            cell.leadingConstraint.constant = rect.origin.x;
            cell.view1HeightConstraint.constant = rect.origin.y + rect.size.height;
        }
        
        [cell.gongkaiBtn setFrame:rect];
        
        
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
    
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    
    browser.sourceImagesContainerView = view1;//原图的父控件
    browser.imageCount = photo1.count;//原图的数量
    
    browser.currentImageIndex = (int)recognizer.view.tag;//当前需要展示图片的index
    browser.delegate = self;
    [browser show]; // 展示图片浏览器
}

-(void)action1{
    DLog(@"action1");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - photobrowser代理方法

// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    
    return [view1.subviews[index + 1] image];
    
}


// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return [NSURL URLWithString:[[photo1 objectAtIndex:index] objectForKey:@"url"]];
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 20 - 8) / 4;
        CGFloat height1;
        
        CGFloat imgHeight = [UIScreen mainScreen].bounds.size.width - 20;
        CGFloat jiange = 32;
        
        CGFloat totalHeight = imgHeight + jiange + 10;
        
        if ((photo1.count + 1) % 4 == 0) {
            height1 = ((photo1.count + 1) / 4) * (width + ((photo1.count + 1) / 4 -1) * 2);
        }else{
            height1 = (((photo1.count + 1) / 4) + 1) * (width + ((photo1.count + 1) / 4) * 2);
        }
        
        return totalHeight + height1;
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
        
    }else if (indexPath.section == 3){
        return 50;
    }else if (indexPath.section == 4){
        return 50;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
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
    }else if (section == 4){
        return 6;
    }else{
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UserDetailTableViewCell1 *cell = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell1"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell1" owner:self options:nil] lastObject];
                
                cell.likebtn.layer.borderWidth = 1.0;
                cell.likebtn.layer.borderColor = [UIColor whiteColor].CGColor;
                cell.likebtn.layer.cornerRadius = 20.0;
                cell.likebtn.layer.masksToBounds = YES;
                [cell.likebtn addTarget:self action:@selector(like) forControlEvents:UIControlEventTouchUpInside];
                
                cell.chatbtn.layer.borderWidth = 1.0;
                cell.chatbtn.layer.borderColor = [UIColor whiteColor].CGColor;
                cell.chatbtn.layer.cornerRadius = 20.0;
                cell.chatbtn.layer.masksToBounds = YES;
                [cell.chatbtn addTarget:self action:@selector(chat) forControlEvents:UIControlEventTouchUpInside];
                
//                UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-20, 60) byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
//                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//                maskLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-20, 60);
//                maskLayer.path = maskPath.CGPath;
//                cell.userImageBottom.layer.mask = maskLayer;
                
                view1 = cell.view1;
                
            }
            
            NSString *avatar_url = [userinfo objectForKey:@"avatar_url"];//头像
            [cell.userImage setImageWithURL:[NSURL URLWithString:avatar_url]];
            return cell;
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
        
    }else if (indexPath.section == 3){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell4"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userdetailcell4"];
        }
        cell.textLabel.text = @"她想去的餐厅 (1)";
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if (indexPath.section == 4){
        UserDetailTableViewCell5 *cell = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell5"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell5" owner:self options:nil] lastObject];
        }
        if (indexPath.row < 5) {
            UILabel *bottom = [[UILabel alloc] initWithFrame:CGRectMake(15, 49, [UIScreen mainScreen].bounds.size.width-15, 1)];
            bottom.backgroundColor = RGBACOLOR(229, 229, 229, 1);
            [cell.contentView addSubview:bottom];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLatestTime)];
        switch (indexPath.row) {
            case 0:
            {
                cell.leftLabel.text = @"转角ID";
                NSNumber *userid = [userinfo objectForKey:@"id"];
                cell.rightLabel.text = [NSString stringWithFormat:@"%d",[userid intValue]];
            }
                break;
            case 1:
                cell.leftLabel.text = @"感情状况";
                break;
            case 2:
                cell.leftLabel.text = @"身高";
                break;
            case 3:
                cell.leftLabel.text = @"对爱情的看法";
                break;
            case 4:
                cell.leftLabel.text = @"对性的看法";
                break;
            case 5:
                cell.leftLabel.text = @"最近活跃时间";
                cell.rightLabel.text = @"查看";
                cell.rightLabel.textColor = RGBACOLOR(0, 122, 255, 1);
                [cell.rightLabel addGestureRecognizer:tap];
                break;
            default:
                break;
        }
        return cell;
        
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }else if (section == 2){
        return 30;
    }else{
        return 5;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return 10;
    }else if(section < 4){
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
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,CONSTACTS_CREATE_URL];
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
                [self showHintInCenter:@"关注成功!"];
                //@"取消关注"
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

-(void)showLatestTime{
    DLog(@"showLatestTime");
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
