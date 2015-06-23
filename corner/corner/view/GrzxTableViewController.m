//
//  GrzxTableViewController.m
//  corner
//
//  Created by yons on 15-6-2.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "GrzxTableViewController.h"
#import "GrzxTableViewCell.h"
#import "UserDetailTableViewCell2.h"
#import "UserDetailTableViewCell3.h"
#import "UserDetailTableViewCell5.h"
#import "RESideMenu.h"
#import "YaoyueDetailViewController.h"
#import "DongtaiTableViewController.h"
#import "FabuyaoyueTableViewController.h"
#import "SVPullToRefresh.h"

//#import "MLPhotoBrowserAssets.h"
//#import "MLPhotoBrowserViewController.h"
//#import "UIButton+WebCache.h"

//@interface GrzxTableViewController ()<MLPhotoBrowserViewControllerDataSource,MLPhotoBrowserViewControllerDelegate>{
@interface GrzxTableViewController (){
    UIImagePickerController *imagePicker1;//照相机
    UIImagePickerController *imagePicker2;//照片选择
    
    NSDictionary *userinfo;//用户信息
    NSString *avatar_url;//用户头像图片链接
    
    UIImageView *userImage;//用户头像
    UIImageView *userImageCenter;//中间的头像
    UIButton *userImageBtn;//按钮
    
    UIView *view1;//公开照片 父视图
    UIView *view2;//隐私照片 父视图
    int viewtype;//用于区别点的是哪个区域的图片
    
    NSMutableArray *photo1;//公开照片
    NSMutableArray *photo2;//隐私照片
    
    int type;//上传图片的类型 0 - 头像上传 1 - 公开照片 2 - 隐私照片
    int currentImageIndex;//当前点击的图片
    
    CGRect resetRect;
    BOOL rectFlag;
}

@end

@implementation GrzxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"发布邀约" style:UIBarButtonItemStyleDone target:self action:@selector(fabuyaoyue)];
    self.navigationItem.rightBarButtonItem = item2;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData)
                                                 name:@"loadYaoyue"
                                               object:nil];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    rectFlag = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIImage *image = [[UIImage imageNamed:@"kiss_top1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    
    photo1 = [NSMutableArray array];
    photo2 = [NSMutableArray array];
    
    __weak GrzxTableViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
    //初始化数据
    [self.tableView triggerPullToRefresh];
}

-(void)fabuyaoyue{
    UINavigationController *nc =  [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"FabuyaoyueTableViewController"]];
    nc.navigationBar.barTintColor = [UIColor colorWithRed:0/255. green:0/255. blue:0/255. alpha:1];
    nc.navigationBar.tintColor = [UIColor whiteColor];
    [nc.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],
       NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [self presentViewController:nc animated:YES completion:nil];
    
    
}

- (void)insertRowAtTop {
    int64_t delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadData];
    });
}

-(void)loadData{
    
    
    
    NSString *userid = [UD objectForKey:USER_ID];
    
//    [self showHudInView:self.view hint:@"加载中"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@",HOST,USER_DETAIL_URL,userid];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", operation.responseString);
        [self.tableView.pullToRefreshView stopAnimating];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                userinfo = [dic objectForKey:@"message"];
                avatar_url = [userinfo objectForKey:@"avatar_url"];
                
                //用户的邀约
//                NSArray *activities = [userinfo objectForKey:@"activities"];
                
                //用户的动态
//                NSArray *posts = [userinfo objectForKey:@"posts"];
                
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
                
                [self imageAndBtnHidden];
                [self.tableView reloadData];
                
                //设置第一行的公开图片和隐私图片
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                GrzxTableViewCell *cell = (GrzxTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [self addPicture:cell];
                
                
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

/**
 *  添加公开图片和隐私图片
 */
-(void)addPicture:(GrzxTableViewCell *)cell{
    
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
        rectFlag = YES;
    }
    
    [cell.gongkaiBtn setFrame:resetRect];
    [cell.yinsiBtn setFrame:resetRect];
    
    for (int i = 0; i < [photo1 count]; i++) {
        UIImageView *img = [[UIImageView alloc] initWithFrame:cell.gongkaiBtn.frame];
        img.contentMode = UIViewContentModeScaleToFill;
//        img.layer.cornerRadius = 5.0;
//        img.layer.masksToBounds = YES;
        [img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@-small",[[photo1 objectAtIndex:i] objectForKey:@"url"]]]];
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
        }
        
        [cell.gongkaiBtn setFrame:rect];
        
        
    }
    for (int i = 0; i < [photo2 count]; i++) {
        
        UIImageView *img = [[UIImageView alloc] initWithFrame:cell.yinsiBtn.frame];
        img.contentMode = UIViewContentModeScaleToFill;
//        img.layer.cornerRadius = 5.0;
//        img.layer.masksToBounds = YES;
        [img setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@-small",[[photo2 objectAtIndex:i] objectForKey:@"url"]]]];
        img.tag = i;
        img.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick:)];
        [img addGestureRecognizer:tap];
        [cell.view2 addSubview:img];
        
        CGRect rect = cell.yinsiBtn.frame;
        if (i !=0 && (i+1) % 4 == 0) {//应该换行
            rect.origin.x = 0;
            rect.origin.y = (i / 3) * (rect.size.height + 2);
            cell.leadingConstraint2.constant = rect.origin.x;
            cell.topConstraint2.constant = rect.origin.y;
            
            cell.view2HeightConstraint.constant = rect.origin.y + rect.size.height + 2;
        }else{
            rect.origin.x = cell.yinsiBtn.frame.size.width + cell.yinsiBtn.frame.origin.x + 2;
            cell.leadingConstraint2.constant = rect.origin.x;
        }
        [cell.yinsiBtn setFrame:rect];
    }
    


}

-(void)leftMenu{
    [self.sideMenuViewController presentLeftMenuViewController];
    
}

/**
 *  点击用户头像 上传头像
 */
-(void)uploadUserImagePrefix{
    type = 1;
    [self uploadUserImage];
}

/**
 *  上传用户头像
 */
-(void)uploadUserImage{
    if (kCurrentSystemVersion < 8.0) {
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"拍照" otherButtonTitles:@"从相册选择", nil];
        actionsheet.tag = 1;
        [actionsheet showInView:self.view];
    }else{
        UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [actionsheet addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            //检查相机模式是否可用
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                NSLog(@"sorry, no camera or camera is unavailable.");
                return;
            }
            if (imagePicker1 == nil) {
                imagePicker1 = [[UIImagePickerController alloc] init];
                imagePicker1.delegate = self;
                imagePicker1.allowsEditing = YES;
                imagePicker1.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker1.mediaTypes =  [[NSArray alloc] initWithObjects:@"public.image", nil];
            }
            [self presentViewController:imagePicker1 animated:YES completion:nil];
        }]];
        [actionsheet addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if (imagePicker2 == nil) {
                imagePicker2 = [[UIImagePickerController alloc] init];
                imagePicker2.delegate = self;
                imagePicker2.allowsEditing = YES;
                imagePicker2.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                imagePicker2.mediaTypes =  [[NSArray alloc] initWithObjects:@"public.image", nil];
                [[imagePicker2 navigationBar] setTintColor:[UIColor whiteColor]];
                [[imagePicker2 navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
            }
            [self presentViewController:imagePicker2 animated:YES completion:nil];
        }]];
        [actionsheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:actionsheet animated:YES completion:nil];
    }
}

#pragma mark - UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 0://照相机
            {
                //检查相机模式是否可用
                if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                    NSLog(@"sorry, no camera or camera is unavailable.");
                    return;
                }
                if (imagePicker1 == nil) {
                    imagePicker1 = [[UIImagePickerController alloc] init];
                    imagePicker1.delegate = self;
                    imagePicker1.allowsEditing = YES;
                    imagePicker1.sourceType = UIImagePickerControllerSourceTypeCamera;
                    imagePicker1.mediaTypes =  [[NSArray alloc] initWithObjects:@"public.image", nil];
                }
                [self presentViewController:imagePicker1 animated:YES completion:nil];
            }
                break;
            case 1://本地相簿
            {
                if (imagePicker2 == nil) {
                    imagePicker2 = [[UIImagePickerController alloc] init];
                    imagePicker2.delegate = self;
                    imagePicker2.allowsEditing = YES;
                    imagePicker2.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    imagePicker2.mediaTypes =  [[NSArray alloc] initWithObjects:@"public.image", nil];
                    [[imagePicker2 navigationBar] setTintColor:[UIColor whiteColor]];
                    [[imagePicker2 navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil]];
                }
                [self presentViewController:imagePicker2 animated:YES completion:nil];
            }
                break;
            default:
                break;
        }
    }else if(actionSheet.tag == 2){
        
        switch (buttonIndex) {
            case 0://查看大图
            {
                
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
                    if (viewtype == 1) {
                        browser.sourceImagesContainerView = view1;//原图的父控件
                        browser.imageCount = photo1.count;//原图的数量
                    }else if (viewtype == 2){
                        browser.sourceImagesContainerView = view2;
                        browser.imageCount = photo2.count;
                    }
                    browser.currentImageIndex = currentImageIndex;//当前需要展示图片的index
                    browser.delegate = self;
                    [browser show]; // 展示图片浏览器
                });
            }
                break;
            case 1://删除
            {
                switch (viewtype) {
                    case 1:
                    {
                        int photoId = (int)[[photo1 objectAtIndex:currentImageIndex] objectForKey:@"id"];
                        [self deleteImg:photoId];
                    }
                        break;
                    case 2:
                    {
                        int photoId = (int)[[photo2 objectAtIndex:currentImageIndex] objectForKey:@"id"];
                        [self deleteImg:photoId];
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    if (actionSheet.tag == 2) {
        for (UIView *subViwe in actionSheet.subviews) {
            if ([subViwe isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton*)subViwe;
                if ([button.titleLabel.text isEqualToString:@"删除"]) {
                    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                }
                
            }
        }
    }
    
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        UIImage  *img = [info objectForKey:UIImagePickerControllerEditedImage];
        
        NSData* data = UIImagePNGRepresentation(img);
//        DLog(@"type:%d",type);
        [self uploadImage:data];
        

        
        
        
        //        NSData *fildData = UIImageJPEGRepresentation(img, 0.5);//UIImagePNGRepresentation(img); //
        //照片
        //        [self uploadImg:fildData];
        //        self.fileData = UIImageJPEGRepresentation(img, 1.0);
    }
    //视频
    //    else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"kUTTypeMovie"]) {
    //        NSString *videoPath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
    //        self.fileData = [NSData dataWithContentsOfFile:videoPath];
    //    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}

/**
 *  默认图片和按钮隐藏
 */
-(void)imageAndBtnHidden{
    if (avatar_url == nil) {
        userImageCenter.hidden = NO;
        userImageBtn.hidden = NO;
    }else{
        userImageCenter.hidden = YES;
        userImageBtn.hidden = YES;
    }
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // bug fixes: UIIMagePickerController使用中偷换StatusBar颜色的问题
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType ==     UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
    //    if([viewController isKindOfClass:[SettingViewController class]]){
    //        NSLog(@"返回");
    //        return;
    //    }
}

/**
 *  上传图片 第一步 获取token
 */
-(void)uploadImage:(NSData *)data{
    [self showHudInView:self.view hint:@"加载中"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,PHOTO_UPTOKEN_URL];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", operation.responseString);
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                NSString *token = [dic objectForKey:@"message"];
                [self photoCreate:token data:data];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self hideHud];
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

/**
 *  上传图片 第二步 带上 token 上传文件
 *
 *  @param token token
 */
-(void)photoCreate:(NSString *)token data:(NSData *)data{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:token forKey:@"token"];
    NSString *urlString = [NSString stringWithFormat:@"%@",QINIU_UPLOAD];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager POST:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"1.png" mimeType:@"image/png"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", operation.responseString);
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSString *key = [dic objectForKey:@"key"];
//                NSString *hash = [dic objectForKey:@"hash"];
            switch (type) {
                case 1:
                    [self updateImageData:key];//修改头像
                    break;
                case 2:
                    [self updateImageData2:key];//上传公开图片
                    break;
                case 3:
                    [self updateImageData2:key];//上传隐私照片
                    break;
                default:
                    break;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self hideHud];
        [self showHint:@"连接失败"];
    }];
}
/**
 *  第三部 修改数据 改头像
 *
 *  @param key key
 */
-(void)updateImageData:(NSString *)key{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:[NSString stringWithFormat:@"%@%@",QINIU_IMAGE_URL,key] forKey:@"pic_url"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,USER_AVATAR_URL];
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
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                NSDictionary *message = [[dic objectForKey:@"message"] cleanNull];
                [UD setObject:message forKey:LOGINED_USER];
                [userImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",QINIU_IMAGE_URL,key]]];
                [self imageAndBtnHidden];
                [[NSNotificationCenter defaultCenter] postNotificationName:USER_INFO_CHANGE object:nil];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self hideHud];
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

/**
 *  第三部 修改数据 上传公开图片 和 隐私图片
 *
 *  @param key key
 */
-(void)updateImageData2:(NSString *)key{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:[NSString stringWithFormat:@"%@%@",QINIU_IMAGE_URL,key] forKey:@"photo_url"];
    if (type == 2) {//公开
        [parameters setValue:[NSNumber numberWithInt:0] forKey:@"type"];
    }else if (type == 3){//隐私
        [parameters setValue:[NSNumber numberWithInt:1] forKey:@"type"];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,PHOTO_CREATE_URL];
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
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                [self loadData];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self hideHud];
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


/**
 *  上传公开图片
 */
-(void)gongkaiBtnClick:(UIButton *)btn{
    type = 2;
    [self uploadUserImage];
}
/**
 *  上传隐私图片
 */
-(void)yinsiBtnClick:(UIButton *)btn{
    type = 3;
    [self uploadUserImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  点击图片
 *
 *  @param recognizer
 */
- (void)imageClick:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.view.superview == view1) {
        viewtype = 1;
    }else if(recognizer.view.superview == view2){
        viewtype = 2;
    }
    
    currentImageIndex = (int)recognizer.view.tag;
    //弹出提示 查看大图 删除
    if (kCurrentSystemVersion < 8.0) {
        UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"查看大图",@"删除", nil];
        actionsheet.tag = 2;
        [actionsheet showInView:self.view];
        
        
    }else{
        UIAlertController *actionsheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [actionsheet addAction:[UIAlertAction actionWithTitle:@"查看大图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
            if (viewtype == 1) {
                browser.sourceImagesContainerView = view1;//原图的父控件
                browser.imageCount = photo1.count;//原图的数量
            }else if (viewtype == 2){
                browser.sourceImagesContainerView = view2;
                browser.imageCount = photo2.count;
            }
            browser.currentImageIndex = (int)recognizer.view.tag;//当前需要展示图片的index
            browser.delegate = self;
            [browser show]; // 展示图片浏览器
        }]];
        [actionsheet addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            
            
            switch (viewtype) {
                case 1:
                {
                    int photoId = (int)[[photo1 objectAtIndex:currentImageIndex] objectForKey:@"id"];
                    [self deleteImg:photoId];
                }
                    break;
                case 2:
                {
                    int photoId = (int)[[photo2 objectAtIndex:currentImageIndex] objectForKey:@"id"];
                    [self deleteImg:photoId];
                }
                    break;
                default:
                    break;
            }
            
        }]];
        [actionsheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:actionsheet animated:YES completion:nil];
    }
}

/**
 *  删除照片
 *
 *  @param photoId 照片id
 */
-(void)deleteImg:(int)photoId{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:@"DELETE" forKey:@"_METHOD"];
    [self showHudInView:self.view hint:@"删除中"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%d",HOST,PHOTO_DELETE_URL,photoId];
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
                [self loadData];
                [self showHint:@"删除成功"];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self hideHud];
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

#pragma mark - photobrowser代理方法

// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    if (viewtype == 1) {
        return [view1.subviews[index + 1] image];
    }else if (viewtype == 2){
        return [view2.subviews[index + 1] image];
    }
    return nil;
}


// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    if (viewtype == 1) {
        return [NSURL URLWithString:[[photo1 objectAtIndex:index] objectForKey:@"url"]];
    }else if (viewtype == 2){
        return [NSURL URLWithString:[[photo2 objectAtIndex:index] objectForKey:@"url"]];
    }
    return nil;
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 20 - 8) / 4;
        CGFloat height1 = (photo1.count / 4) * (width + 2);
        CGFloat height2 = (photo2.count / 4) * (width + 2);
        return 540 + height1 + height2;
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
            
            UIFont *font = [UIFont systemFontOfSize:14];
            CGSize textSize;
            CGSize textSize2;
            if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                //[paragraphStyle setLineSpacing:5];//调整行间距
                NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
                NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin;
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
    if (indexPath.section == 0) {//个人头像
        if (indexPath.row == 0) {
            GrzxTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GrzxTableViewCell"];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"GrzxTableViewCell" owner:self options:nil] lastObject];
                UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:cell.userImageBottom.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                maskLayer.frame = cell.userImageBottom.bounds;
                maskLayer.path = maskPath.CGPath;
                cell.userImageBottom.layer.mask = maskLayer;
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uploadUserImagePrefix)];
                [cell.userImage addGestureRecognizer:tap];
                
                
                userImage = cell.userImage;
                userImageCenter = cell.userImageCenter;
                userImageBtn = cell.userImageBtn;
                
                [cell.gongkaiBtn addTarget:self action:@selector(gongkaiBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell.yinsiBtn addTarget:self action:@selector(yinsiBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                if (view1 == nil) {
                    view1 = cell.view1;
                }
                if (view2 == nil) {
                    view2 = cell.view2;
                }
            }
            
            
            [cell.userImage setImageWithURL:[NSURL URLWithString:avatar_url]];
            
            return cell;
        }
    }else if (indexPath.section == 1){//动态
        if (indexPath.row == 0) {
            
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
                //            DLog(@"cell3 init");
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
            UILabel *bottom = [[UILabel alloc] initWithFrame:CGRectMake(15, 49, cell.bounds.size.width-15, 1)];
            bottom.backgroundColor = RGBACOLOR(229, 229, 229, 1);
            [cell.contentView addSubview:bottom];
        }
        
        
        switch (indexPath.row) {
            case 0:
                cell.leftLabel.text = @"转角ID";
                cell.rightLabel.text = @"93573390";
                break;
            case 1:
                cell.leftLabel.text = @"感情状况";
                break;
            case 2:
                cell.leftLabel.text = @"身高";
                cell.rightLabel.text = @"220cm";
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
    if (section == 2) {//邀约
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
        view.backgroundColor = [UIColor whiteColor];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 20, 10)];
        NSArray *activities = [userinfo objectForKey:@"activities"];
        label.text = [NSString stringWithFormat:@"邀约 (%lu)",(unsigned long)[activities count]];
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

    if (indexPath.section == 1){//动态
        if (indexPath.row == 0) {
            DongtaiTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DongtaiTableViewController"];
            NSString *userid = [UD objectForKey:USER_ID];
            vc.userid = userid;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if(indexPath.section == 2){//邀约
        NSArray *activities = [userinfo objectForKey:@"activities"];
        if ([activities count] == 0) {
        }else{
            YaoyueDetailViewController *vc = [[YaoyueDetailViewController alloc] init];
            vc.title = @"邀约";
            vc.activityDic = [[activities objectAtIndex:indexPath.row] cleanNull];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

@end
