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
//#import "RESideMenu.h"
#import "YaoyueDetailViewController.h"
#import "DongtaiTableViewController.h"
#import "FabuyaoyueTableViewController.h"
#import "SVPullToRefresh.h"
#import "UIButton+Badge.h"
#import "WodeyaoyueViewController.h"
#import "LCEChatListVC.h"
#import "PhoneUpdateViewController.h"
#import "NichengUpdateViewController.h"
#import "ZiwojieshaoViewController.h"
#import "XuanshiViewController.h"
#import "ChooseZhiyeViewController.h"
#import "ChooseAiqingViewController.h"
#import "UIViewController+updateUserInfo.h"
#import "ChooseXingViewController.h"
#import "XiangxueViewController.h"
#import "MyLovePartViewController.h"
#import "UpdateAgeViewController.h"
#import "NSDate+Addition.h"
#import "ILikeCollectionViewController.h"
//#import "MLPhotoBrowserAssets.h"
//#import "MLPhotoBrowserViewController.h"
//#import "UIButton+WebCache.h"

//@interface GrzxTableViewController ()<MLPhotoBrowserViewControllerDataSource,MLPhotoBrowserViewControllerDelegate>{
@interface GrzxTableViewController (){
    UIImagePickerController *imagePicker1;//照相机
    UIImagePickerController *imagePicker2;//照片选择
    
    NSMutableDictionary *userinfo;//用户信息
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
    
    int pickerType;//判断选择的哪一项
    NSArray *ganqingArr;//感情状况
    
    NSDictionary *pickerDic;
    NSArray *provinceArray;
    NSArray *cityArray;
    NSArray *townArray;
    NSArray *selectedArray;
    
    NSArray *shouruArr;//收入
    NSArray *shengaoArr;//身高
    NSArray *tizhongArr;//体重
    
    UIButton *chatBtn;
}

@property (strong, nonatomic) IBOutlet UIPickerView *myPicker;
@property (strong, nonatomic) IBOutlet UIView *pickerBgView;
@property (strong, nonatomic) UIView *maskView;

@end

#define PICTURE_NUMBER 3
#define PICTURE_MARGIN 2

@implementation GrzxTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setUnRadCount)
                                                 name:@"setUnRadCount"
                                               object:nil];
    [self setUnRadCount];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDetailChange:)
                                                 name:USER_DETAIL_CHANGE
                                               object:nil];
    
    [self initView];//初始化弹出选择控件
    [self initPickerData];//初始化选择数据
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"发布邀约" style:UIBarButtonItemStyleDone target:self action:@selector(fabuyaoyue)];
    self.navigationItem.rightBarButtonItem = item2;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadData:)
                                                 name:@"loadYaoyue"
                                               object:nil];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
    }
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainbackground"]];
    self.tableView.backgroundView = view;
    
    rectFlag = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    UIImage *image = [[UIImage imageNamed:@"leftMenu"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:image style:UIBarButtonItemStyleDone target:self action:@selector(leftMenu)];
//    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.tableFooterView = v;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    
    photo1 = [NSMutableArray array];
    photo2 = [NSMutableArray array];
    
    __weak GrzxTableViewController *weakSelf = self;
    
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf insertRowAtTop];
    }];
    
    //初始化数据
    [self.tableView triggerPullToRefresh];
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
    ganqingArr = [NSArray arrayWithObjects:@"单身",@"恋爱",@"貌似恋爱",@"已婚",@"分居",@"离异", nil];
    
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
    
    shouruArr = [NSArray arrayWithObjects:@"3,000元以上/月",@"5,000元以上/月",@"10,000元以上/月",@"20,000元以上/月",@"50万以上/年收入",@"1000万以上/年收入",@"500万以上/年收入",@"1000万以上/年收入",@"保密", nil];
    
    NSMutableArray *shengao = [NSMutableArray array];
    for (int i = 140 ; i <= 220 ; i++) {
        [shengao addObject:[NSString stringWithFormat:@"%dcm",i]];
    }
    shengaoArr = [NSArray arrayWithArray:shengao];
    
    NSMutableArray *tizhong = [NSMutableArray array];
    for (int i = 35 ; i <= 100 ; i++) {
        [tizhong addObject:[NSString stringWithFormat:@"%dkg",i]];
    }
    tizhongArr = [NSArray arrayWithArray:tizhong];
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
        [self loadData:YES];
    });
}

-(void)loadData:(BOOL)refreshAll{
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
//    [self showHudInView:self.view hint:@"加载中"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@/%@?token=%@",HOST,USER_DETAIL_URL,userid,token];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", operation.responseString);
        DLog(@"loadData 成功");
        rectFlag = NO;
        if (refreshAll) {
            [self.tableView.pullToRefreshView stopAnimating];
        }
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                userinfo = [NSMutableDictionary dictionaryWithDictionary:[[dic objectForKey:@"message"] cleanNull] ];
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
                
//                [self imageAndBtnHidden];
                
                if (refreshAll) {
                    [self.tableView reloadData];
                }else{
                    NSMutableIndexSet *idxSet = [[NSMutableIndexSet alloc] init];
                    [idxSet addIndex:0];
                    [self.tableView reloadSections:idxSet withRowAnimation:UITableViewRowAnimationNone];
                }
                
                [self addPicture];
                
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        DLog(@"loadData 失败");
        [self.tableView.pullToRefreshView stopAnimating];
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

//-(void)leftMenu{
//    [self.sideMenuViewController presentLeftMenuViewController];
//    
//}

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
    if (actionSheet.tag == 1) {//弹出框 上传照片
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
    }else if(actionSheet.tag == 2){//弹出框 上传照片
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
                        if (currentImageIndex < [photo1 count]) {
                            NSNumber *photoId = [[photo1 objectAtIndex:currentImageIndex] objectForKey:@"id"];
                            [self deleteImg:photoId];
                        }else{
                            DLog(@"photo1数组越界 currentImageIndex:%d",currentImageIndex);
                        }
                        
                    }
                        break;
                    case 2:
                    {
                        if (currentImageIndex < [photo2 count]) {
                            NSNumber *photoId = [[photo2 objectAtIndex:currentImageIndex] objectForKey:@"id"];
                            [self deleteImg:photoId];
                        }else{
                            DLog(@"photo2数组越界 currentImageIndex:%d",currentImageIndex);
                        }
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
//-(void)imageAndBtnHidden{
//    if (avatar_url == nil || [avatar_url isEqualToString:@""]) {
//        userImageCenter.hidden = NO;
//        userImageBtn.hidden = NO;
//    }else{
//        userImageCenter.hidden = YES;
//        userImageBtn.hidden = YES;
//    }
//}

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
        DLog(@"上传图片 第一步 获取token 成功");
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
        DLog(@"上传图片 第一步 获取token 失败");
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
        DLog(@"上传图片 第二步 带上 token 上传文件 成功");
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
        DLog(@"上传图片 第二步 带上 token 上传文件 失败");
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
        DLog(@"第三部 修改数据 改头像 成功");
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
                
                
                GrzxTableViewCell *cell = (GrzxTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                [cell.userImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",QINIU_IMAGE_URL,key]]];
                
                
//                [self imageAndBtnHidden];
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
        DLog(@"第三部 修改数据 改头像 成功");
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
        DLog(@"第三部 修改数据 上传公开图片 和 隐私图片 成功");
        [self hideHud];
        NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
        NSError *error;
        NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        if (dic == nil) {
            NSLog(@"json parse failed \r\n");
        }else{
            NSNumber *status = [dic objectForKey:@"status"];
            if ([status intValue] == 200) {
                [self loadData:NO];
            }else if([status intValue] >= 600){
                NSString *message = [dic objectForKey:@"message"];
                [self hideHud];
                [self showHint:message];
                [self validateUserToken:[status intValue]];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        DLog(@"第三部 修改数据 上传公开图片 和 隐私图片 失败");
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
    
    if (recognizer.view.superview.tag == 1) {
        viewtype = 1;
    }else if(recognizer.view.superview.tag == 2){
        viewtype = 2;
    }
    
    DLog(@"%@\tviewtype:%d",recognizer.view.superview,viewtype);
    
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
                    if (currentImageIndex < [photo1 count]) {
                        NSNumber *photoId = [[photo1 objectAtIndex:currentImageIndex] objectForKey:@"id"];
                        [self deleteImg:photoId];
                    }else{
                        DLog(@"photo1数组越界 currentImageIndex:%d",currentImageIndex);
                    }
                    
                }
                    break;
                case 2:
                {
                    if (currentImageIndex < [photo2 count]) {
                        NSNumber *photoId = [[photo2 objectAtIndex:currentImageIndex] objectForKey:@"id"];
                        [self deleteImg:photoId];
                    }else{
                        DLog(@"photo2数组越界 currentImageIndex:%d",currentImageIndex);
                    }
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
-(void)deleteImg:(NSNumber *)photoId{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:@"DELETE" forKey:@"_METHOD"];
    [parameters setValue:photoId forKey:@"photo_id"];
    [self showHudInView:self.view hint:@"删除中"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@%d",HOST,PHOTO_DELETE_URL,[photoId intValue]];
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
                [self loadData:NO];
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
        DLog(@"%d %d",index,[photo2 count]);
        DLog(@"%d",view2.subviews.count);
        
        
        return [NSURL URLWithString:[[photo2 objectAtIndex:index] objectForKey:@"url"]];
    }
    return nil;
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
            
            return 10 + height + 10 + 34 + 10;
        }
    }else if (indexPath.section == 3){//电话
        return 50;
    }else if (indexPath.section == 4){//个人信息
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 15 - 10 - 33;
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
    }else if (indexPath.section == 5){
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 15 - 10 - 33;
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
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
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
    }else if (section == 3){//电话
        return 1;
    }else if (section == 4){//个人详情
        return 13;
    }else if (section == 5){//个人爱好
        return 3;
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
                
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uploadUserImagePrefix)];
                [cell.userImage addGestureRecognizer:tap];
                
                cell.userImage.layer.cornerRadius = 50;
                cell.userImage.layer.masksToBounds = YES;
                
//                userImage = cell.userImage;
//                userImageCenter = cell.userImageCenter;
//                userImageBtn = cell.userImageBtn;
                
                [cell.gongkaiBtn addTarget:self action:@selector(gongkaiBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell.yinsiBtn addTarget:self action:@selector(yinsiBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                if (view1 == nil) {
                    view1 = cell.view1;
                }
                if (view2 == nil) {
                    view2 = cell.view2;
                }
            }
            
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
                cell.jieshaoLabel.text = @"请填写个性签名";
            }else{
                cell.jieshaoLabel.text = aboutme;
            }
            
            UITapGestureRecognizer *jieshaotap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toJieshao)];
            [cell.jieshaoLabel addGestureRecognizer:jieshaotap];
            
            
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
            
            
            cell.btn1.text = [NSString stringWithFormat:@"%d\n%@",111,@"关注数"];
            NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:cell.btn1.text];
            [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,cell.btn1.text.length - 3)];
            cell.btn1.attributedText = str;
            UITapGestureRecognizer *click = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myaction:)];
            [cell.btn1 addGestureRecognizer:click];
            
            cell.btn2.text = [NSString stringWithFormat:@"%d\n%@",111,@"被关注数"];
            NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:cell.btn2.text];
            [str2 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,cell.btn2.text.length - 4)];
            cell.btn2.attributedText = str2;
            UITapGestureRecognizer *click2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myaction:)];
            [cell.btn2 addGestureRecognizer:click2];
            
            cell.btn3.text = [NSString stringWithFormat:@"%d\n%@",111,@"动态数"];
            NSMutableAttributedString *str3 = [[NSMutableAttributedString alloc] initWithString:cell.btn3.text];
            [str3 addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,cell.btn3.text.length - 3)];
            cell.btn3.attributedText = str3;
            UITapGestureRecognizer *click3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(myaction:)];
            [cell.btn3 addGestureRecognizer:click3];
            
            
            [cell.likeBtn addTarget:self action:@selector(toMyLike) forControlEvents:UIControlEventTouchUpInside];
            chatBtn = cell.talkBtn;
            [cell.talkBtn addTarget:self action:@selector(toChat) forControlEvents:UIControlEventTouchUpInside];
            NSInteger totalUnreadCount = [[CDStorage storage] countUnread];
            chatBtn.badgeValue = [NSString stringWithFormat:@"%d",totalUnreadCount];
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
                [cell.btn setHidden:YES];
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
    }
    else if (indexPath.section == 3){
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell33"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell3"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:13];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSString *phone = [userinfo objectForKey:@"phone"];//电话
        cell.textLabel.text = @"手机号";
        cell.detailTextLabel.text = [phone isEqualToString:@""] ? @"未填" : phone;
        return cell;
    }
    else if (indexPath.section == 4){
        
        
        NSNumber *userid = [userinfo objectForKey:@"id"];
        NSString *nickname = [userinfo objectForKey:@"nickname"];//昵称
        NSString *aboutme = [userinfo objectForKey:@"aboutme"];//自我介绍
        NSString *xuanshi = [userinfo objectForKey:@"xuanshi"];//美丽宣誓
        NSString *qinggan = [userinfo objectForKey:@"qinggan"];//感情状况
        NSString *diqu = [userinfo objectForKey:@"diqu"];//地区
        NSString *zhiye = [userinfo objectForKey:@"zhiye"];//职业
        NSString *shouru = [userinfo objectForKey:@"shouru"];//收入
        NSString *shengao = [userinfo objectForKey:@"shengao"];//身高
        NSString *tizhong = [userinfo objectForKey:@"tizhong"];//体重
        NSString *aiqing = [userinfo objectForKey:@"aiqing"];//对爱情的想法
        NSString *xing = [userinfo objectForKey:@"xing"];//对性的想法
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell3"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:13];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        }
        
        
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"转角ID";
                cell.detailTextLabel.text = [[userid stringValue] isEqualToString:@""] ? @"未填" : [userid stringValue];
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 1:
                cell.textLabel.text = @"昵称";
                cell.detailTextLabel.text = [nickname isEqualToString:@""] ? @"未填" : nickname;
                break;
            case 2:
            {
                UserDetailTableViewCell5 *cell5 = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell5"];
                if (cell5 == nil) {
                    cell5 = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell5" owner:self options:nil] lastObject];
                }
                cell5.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell5.leftLabel.text = @"自我介绍";
                cell5.rightLabel.text = [aboutme isEqualToString:@""] ? @"未填" : aboutme;
                cell5.rightLabel.textAlignment = [aboutme isEqualToString:@""] ? NSTextAlignmentRight : NSTextAlignmentLeft;
                cell5.rightLabel.numberOfLines = 0;
                CGFloat width = [UIScreen mainScreen].bounds.size.width - 15 - 10 - 33;
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
                return cell5;
            }
                
                break;
            case 3:
                cell.textLabel.text = @"美丽宣誓";
                cell.detailTextLabel.text = [xuanshi isEqualToString:@""] ? @"未填" : xuanshi;
                break;
            case 4:
                cell.textLabel.text = @"感情状况";
                cell.detailTextLabel.text = [qinggan isEqualToString:@""] ? @"未填" : qinggan;
                break;
            case 5:
                cell.textLabel.text = @"所在地区";
                if (![diqu isEqualToString:@""]) {
                    NSArray *address =[diqu componentsSeparatedByString:NSLocalizedString(@",", nil)];
                    NSString *str = [address componentsJoinedByString:@" "];
                    cell.detailTextLabel.text = str;
                }else{
                    cell.detailTextLabel.text = @"未填";
                }
                break;
            case 6:
            {
                cell.textLabel.text = @"年龄";
                
                NSString *birthday = [userinfo objectForKey:@"birthday"];
                if (birthday == nil || [birthday isEqualToString:@""] || (birthday != nil && [birthday isEqualToString:@"1900-01-01"])) {
                    cell.detailTextLabel.text = @"未填";
                }else{
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                    NSDate *date= [dateFormatter dateFromString:birthday];
                    NSInteger age = [NSDate ageWithDateOfBirth:date];
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)age];
                }
            }
                break;
            case 7:
                cell.textLabel.text = @"职业";
                cell.detailTextLabel.text = [zhiye isEqualToString:@""] ? @"未填" : zhiye;
                break;
            case 8:
                cell.textLabel.text = @"收入";
                cell.detailTextLabel.text = [shouru isEqualToString:@""] ? @"未填" : shouru;
                break;
            case 9:
                cell.textLabel.text = @"身高";
                cell.detailTextLabel.text = [shengao isEqualToString:@""] ? @"未填" : shengao;
                break;
            case 10:
                cell.textLabel.text = @"体重";
                cell.detailTextLabel.text = [tizhong isEqualToString:@""] ? @"未填" : tizhong;
                break;
            case 11:
            {
                
                UserDetailTableViewCell5 *cell5 = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell6"];
                if (cell5 == nil) {
                    cell5 = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell5" owner:self options:nil] lastObject];
                }
                cell5.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell5.leftLabel.text = @"对爱情的看法";
                cell5.rightLabel.text = [aiqing isEqualToString:@""] ? @"未填" : aiqing;
                cell5.rightLabel.textAlignment = [aiqing isEqualToString:@""] ? NSTextAlignmentRight : NSTextAlignmentLeft;
                cell5.rightLabel.numberOfLines = 0;
                CGFloat width = [UIScreen mainScreen].bounds.size.width - 15 - 10 - 33;
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
                return cell5;
            }
                break;
            case 12:
            {
                cell.textLabel.text = @"对性的看法";
                cell.detailTextLabel.text = [xing isEqualToString:@""] ? @"未填" : xing;
                
            }
                
                break;
            default:
                break;
        }
        if (indexPath.row < 12) {
            [cell.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[UILabel class]]) {
                    UILabel *label = (UILabel *)obj;
                    if (label.tag == 999) {
                        [label removeFromSuperview];
                    }
                }
            }];
            UILabel *bottom = [[UILabel alloc] initWithFrame:CGRectMake(15, 49, [UIScreen mainScreen].bounds.size.width-15, 1)];
            bottom.backgroundColor = RGBACOLOR(229, 229, 229, 1);
            bottom.tag = 999;
            [cell.contentView addSubview:bottom];
        }
        return cell;
    }
    else if (indexPath.section == 5){
        
        
        NSString *xue = [userinfo objectForKey:@"xue"];//想学
        NSString *chang = [userinfo objectForKey:@"chang"];//擅长
        NSString *manyi = [userinfo objectForKey:@"manyi"];//最满意部位
        
        switch (indexPath.row) {
            case 0:
            {
                UserDetailTableViewCell5 *cell5 = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell7"];
                if (cell5 == nil) {
                    cell5 = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell5" owner:self options:nil] lastObject];
                }
                cell5.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell5.leftLabel.text = @"想学";
                cell5.rightLabel.text = [xue isEqualToString:@""] ? @"未填" : xue;
                cell5.rightLabel.textAlignment = [xue isEqualToString:@""] ? NSTextAlignmentRight : NSTextAlignmentLeft;
                cell5.rightLabel.numberOfLines = 0;
                CGFloat width = [UIScreen mainScreen].bounds.size.width - 15 - 10 - 33;
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
                return cell5;
            }
                break;
            case 1:
            {
                UserDetailTableViewCell5 *cell5 = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell8"];
                if (cell5 == nil) {
                    cell5 = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell5" owner:self options:nil] lastObject];
                }
                cell5.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell5.leftLabel.text = @"擅长";
                cell5.rightLabel.text = [chang isEqualToString:@""] ? @"未填" : chang;
                cell5.rightLabel.textAlignment = [chang isEqualToString:@""] ? NSTextAlignmentRight : NSTextAlignmentLeft;
                cell5.rightLabel.numberOfLines = 0;
                
                CGFloat width = [UIScreen mainScreen].bounds.size.width - 15 - 10 - 33;
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
                return cell5;
            }
                break;
            case 2:
            {
                UserDetailTableViewCell5 *cell5 = [tableView dequeueReusableCellWithIdentifier:@"userdetailcell9"];
                if (cell5 == nil) {
                    cell5 = [[[NSBundle mainBundle] loadNibNamed:@"UserDetailTableViewCell5" owner:self options:nil] lastObject];
                }
                cell5.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell5.leftLabel.text = @"最满意部位";
                cell5.rightLabel.text = [manyi isEqualToString:@""] ? @"未填" : manyi;
                cell5.rightLabel.textAlignment = [manyi isEqualToString:@""] ? NSTextAlignmentRight : NSTextAlignmentLeft;
                cell5.rightLabel.numberOfLines = 0;
                
                return cell5;
            }
                break;
            default:
                break;
        }
        return nil;
    }else{
        return nil;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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
    }else if(section < 5){
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 1://动态
        {
            if (indexPath.row == 0) {
                DongtaiTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DongtaiTableViewController"];
                NSString *userid = [UD objectForKey:USER_ID];
                vc.userid = userid;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
            break;
        case 2://邀约
        {
//            NSArray *activities = [userinfo objectForKey:@"activities"];
//            if ([activities count] == 0) {
//                [self fabuyaoyue];
//            }else{
                WodeyaoyueViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"WodeyaoyueViewController"];
                [self.navigationController pushViewController:vc animated:YES];
//            }
        }
            break;
        case 3://电话
        {
            PhoneUpdateViewController *vc = [[PhoneUpdateViewController alloc] init];
            NSString *phone = [userinfo objectForKey:@"phone"];
            vc.phone = phone;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4://详情
        {
            switch (indexPath.row) {
                case 1://昵称
                {
                    NichengUpdateViewController *vc = [[NichengUpdateViewController alloc] init];
                    vc.title = @"修改昵称";
                    NSString *nickname = [userinfo objectForKey:@"nickname"];
                    vc.nickname = nickname;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 2://自我介绍
                {
                    ZiwojieshaoViewController *vc = [[ZiwojieshaoViewController alloc] init];
                    vc.title = @"自我介绍";
                    NSString *aboutme = [userinfo objectForKey:@"aboutme"];
                    vc.jieshao = aboutme;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 3://美丽宣誓
                {
                    XuanshiViewController *vc = [[XuanshiViewController alloc] init];
                    vc.title = @"转角宣誓";
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 4://感情状况 需要actionsheet
                {
                    pickerType = 1;
                    [self showMyPicker];
                }
                    break;
                case 5://所在地区 需要actionsheet
                {
                    pickerType = 2;
                    [self showMyPicker];
                }
                    break;
                case 6://年龄 进入下个界面
                {
                    UpdateAgeViewController *vc = [[UpdateAgeViewController alloc] init];
                    NSString *birthday = [userinfo objectForKey:@"birthday"];
                    vc.title = @"修改年龄";
                    vc.birthday = birthday;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 7://职业
                {
                    ChooseZhiyeViewController *vc = [[ChooseZhiyeViewController alloc] init];
                    NSString *zhiye = [userinfo objectForKey:@"zhiye"];
                    vc.zhiye = zhiye;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 8://收入 需要actionsheet
                {
                    pickerType = 3;
                    [self showMyPicker];
                }
                    break;
                case 9://身高 需要actionsheet
                {
                    pickerType = 4;
                    [self showMyPicker];
                }
                    break;
                case 10://体重 需要actionsheet
                {
                    pickerType = 5;
                    [self showMyPicker];
                }
                    break;
                case 11://对爱情的看法
                {
                    ChooseAiqingViewController *vc = [[ChooseAiqingViewController alloc] init];
                    NSString *aiqing = [userinfo objectForKey:@"aiqing"];
                    vc.aiqing = aiqing;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 12://对性的看法
                {
                    ChooseXingViewController *vc = [[ChooseXingViewController alloc] init];
                    NSString *xing = [userinfo objectForKey:@"xing"];
                    vc.xing = xing;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 5://其他信息
        {
            switch (indexPath.row) {
                case 0://想学
                {
                    XiangxueViewController *vc = [[XiangxueViewController alloc] init];
                    NSString *xue = [userinfo objectForKey:@"xue"];
                    vc.xue = xue;
                    vc.type = 1;
                    vc.title = @"想学的技能";
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 1://擅长
                {
                    XiangxueViewController *vc = [[XiangxueViewController alloc] init];
                    NSString *chang = [userinfo objectForKey:@"chang"];
                    vc.shanchang = chang;
                    vc.type = 2;
                    vc.title = @"擅长的技能";
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 2://最满意部位
                {
                    MyLovePartViewController *vc = [[MyLovePartViewController alloc] init];
                    NSString *manyi = [userinfo objectForKey:@"manyi"];
                    NSNumber *sexnum = [userinfo objectForKey:@"sex"];
                    vc.part = manyi;
                    vc.sexnum = sexnum;
                    vc.title = @"最满意的部位";
                    [self.navigationController pushViewController:vc animated:YES];
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

#pragma mark - UIPicker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    switch (pickerType) {
        case 1://感情状况
            return 1;
            break;
        case 2://所在地区
            return 3;
            break;
        case 3://收入
            return 1;
            break;
        case 4://身高
            return 1;
            break;
        case 5://体重
            return 1;
            break;
        default:
            return 0;
            break;
    }
    
    
    
    
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (pickerType) {
        case 1://感情状况
            return [ganqingArr count];
            break;
        case 2://所在地区
        {
            if (component == 0) {
                return provinceArray.count;
            } else if (component == 1) {
                return cityArray.count;
            } else {
                return townArray.count;
            }
        }
            break;
        case 3://收入
            return shouruArr.count;
            break;
        case 4://身高
            return shengaoArr.count;
            break;
        case 5://体重
            return tizhongArr.count;
            break;
        default:
            return 0;
            break;
    }
    
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (pickerType) {
        case 1://感情状况
            return [ganqingArr objectAtIndex:row];
            break;
        case 2://所在地区
        {
            if (component == 0) {
                return [provinceArray objectAtIndex:row];
            } else if (component == 1) {
                return [cityArray objectAtIndex:row];
            } else {
                return [townArray objectAtIndex:row];
            }
        }
            break;
        case 3://收入
            return [shouruArr objectAtIndex:row];
            break;
        case 4://身高
            return [shengaoArr objectAtIndex:row];
            break;
        case 5://体重
            return [tizhongArr objectAtIndex:row];
            break;
        default:
            return @"";
            break;
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (pickerType) {
        case 1://感情状况
            
            break;
        case 2://所在地区
        {
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
            break;
        case 3://收入
            
            break;
        case 4://身高
            
            break;
        case 5://体重
            
            break;
        default:
            break;
    }
}

#pragma mark - private method
- (void)showMyPicker {
    [self.myPicker reloadAllComponents];
    
    switch (pickerType) {
        case 1://感情状况
        {
            NSString *qinggan = [userinfo objectForKey:@"qinggan"];//感情状况
            if (![qinggan isEqualToString:@""]) {
                for (int i = 0 ; i < [ganqingArr count] ; i++) {
                    if ([qinggan isEqualToString:[ganqingArr objectAtIndex:i]]) {
                        [self.myPicker selectRow:i inComponent:0 animated:YES];
                        break;
                    }
                }
            }
        }
            break;
        case 2://所在地区
        {
            NSString *diqu = [userinfo objectForKey:@"diqu"];//地区
            if (![diqu isEqualToString:@""]) {
                NSArray *address =[diqu componentsSeparatedByString:NSLocalizedString(@",", nil)];
                
                NSInteger index1 = [provinceArray indexOfObject:[address objectAtIndex:0]];
                if (index1 > -1) {
                    [self.myPicker selectRow:index1 inComponent:0 animated:NO];
                    selectedArray = [pickerDic objectForKey:[provinceArray objectAtIndex:index1]];
                    if (selectedArray.count > 0) {
                        cityArray = [[selectedArray objectAtIndex:0] allKeys];
                    } else {
                        cityArray = nil;
                    }

                    NSInteger index2 = [cityArray indexOfObject:[address objectAtIndex:1]];
                    if (index2 > -1) {
                        [self.myPicker selectRow:index2 inComponent:1 animated:NO];
                        if (selectedArray.count > 0 && cityArray.count > 0) {
                            townArray = [[selectedArray objectAtIndex:0] objectForKey:[cityArray objectAtIndex:index2]];
                        } else {
                            townArray = nil;
                        }
                        NSInteger index3 = [townArray indexOfObject:[address objectAtIndex:2]];
                        if (index3 > -1) {
                            [self.myPicker selectRow:index3 inComponent:2 animated:NO];
                        }
                    }
                }
            }else{
                [self.myPicker selectRow:0 inComponent:0 animated:YES];
                [self.myPicker selectRow:0 inComponent:1 animated:YES];
                [self.myPicker selectRow:0 inComponent:2 animated:YES];
            }
        }
            break;
        case 3://收入
        {
            NSString *shouru = [userinfo objectForKey:@"shouru"];//收入
            if (![shouru isEqualToString:@""]) {
                for (int i = 0 ; i < [shouruArr count] ; i++) {
                    if ([shouru isEqualToString:[shouruArr objectAtIndex:i]]) {
                        [self.myPicker selectRow:i inComponent:0 animated:YES];
                        break;
                    }
                }
            }
        }
            break;
        case 4://身高
        {
            NSString *shengao = [userinfo objectForKey:@"shengao"];//身高
            if (![shengao isEqualToString:@""]) {
                for (int i = 0 ; i < [shengaoArr count] ; i++) {
                    if ([shengao isEqualToString:[shengaoArr objectAtIndex:i]]) {
                        [self.myPicker selectRow:i inComponent:0 animated:YES];
                        break;
                    }
                }
            }
        }
            break;
        case 5://体重
        {
            NSString *tizhong = [userinfo objectForKey:@"tizhong"];//体重
            if (![tizhong isEqualToString:@""]) {
                for (int i = 0 ; i < [tizhongArr count] ; i++) {
                    if ([tizhong isEqualToString:[tizhongArr objectAtIndex:i]]) {
                        [self.myPicker selectRow:i inComponent:0 animated:YES];
                        break;
                    }
                }
            }
        }
            break;
        default:
            
            break;
    }
    
    [self.tableView.superview addSubview:self.maskView];
    [self.tableView.superview addSubview:self.pickerBgView];
    self.maskView.alpha = 0.3;
    self.pickerBgView.top = self.tableView.superview.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0.3;
        self.pickerBgView.bottom = self.tableView.superview.height;
    }];
}

- (void)hideMyPicker {
    [UIView animateWithDuration:0.3 animations:^{
        self.maskView.alpha = 0;
        self.pickerBgView.top = self.tableView.superview.height;
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
    switch (pickerType) {
        case 1://感情状况
        {
            DLog(@"%@",[ganqingArr objectAtIndex:[self.myPicker selectedRowInComponent:0]]);
            NSString *value = [ganqingArr objectAtIndex:[self.myPicker selectedRowInComponent:0]];
            [self updateUserInfo:@"qinggan" value:value];
        }
            break;
        case 2://所在地区
        {
            DLog(@"%@",[provinceArray objectAtIndex:[self.myPicker selectedRowInComponent:0]]);
            DLog(@"%@",[cityArray objectAtIndex:[self.myPicker selectedRowInComponent:1]]);
            DLog(@"%@",[townArray objectAtIndex:[self.myPicker selectedRowInComponent:2]]);
            
            NSString *province = [provinceArray objectAtIndex:[self.myPicker selectedRowInComponent:0]];
            NSString *city = [cityArray objectAtIndex:[self.myPicker selectedRowInComponent:1]];
            NSString *town = [townArray objectAtIndex:[self.myPicker selectedRowInComponent:2]];
            NSString *value = [NSString stringWithFormat:@"%@,%@,%@",province,city,town];
            [self updateUserInfo:@"diqu" value:value];
        }
            break;
        case 3://收入
        {
            DLog(@"%@",[shouruArr objectAtIndex:[self.myPicker selectedRowInComponent:0]]);
            NSString *value = [shouruArr objectAtIndex:[self.myPicker selectedRowInComponent:0]];
            [self updateUserInfo:@"shouru" value:value];
        }
            break;
        case 4://身高
        {
            DLog(@"%@",[shengaoArr objectAtIndex:[self.myPicker selectedRowInComponent:0]]);
            NSString *value = [shengaoArr objectAtIndex:[self.myPicker selectedRowInComponent:0]];
            [self updateUserInfo:@"shengao" value:value];
        }
            break;
        case 5://体重
        {
            DLog(@"%@",[tizhongArr objectAtIndex:[self.myPicker selectedRowInComponent:0]]);
            NSString *value = [tizhongArr objectAtIndex:[self.myPicker selectedRowInComponent:0]];
            [self updateUserInfo:@"tizhong" value:value];
        }
            break;
        default:
            break;
    }
    [self hideMyPicker];
}


/**
 *  用户信息显示
 */
-(void)userDetailChange:(NSNotification *)notification{
    
    NSDictionary *userDetailDic = notification.userInfo;
    
    NSArray *keys;
    int i, count;
    id key, value;
    
    keys = [userDetailDic allKeys];
    count = (int)[keys count];
    for (i = 0; i < count; i++)
    {
        key = [keys objectAtIndex: i];
        value = [userDetailDic objectForKey: key];
        [userinfo setValue:value forKey:key];
        NSLog (@"Key: %@ for value: %@", key, value);
    }
    
    NSMutableIndexSet *idxSet = [[NSMutableIndexSet alloc] init];
    [idxSet addIndex:3];
    [idxSet addIndex:4];
    [idxSet addIndex:5];
    [self.tableView reloadSections:idxSet withRowAnimation:UITableViewRowAnimationNone];
}

-(void)myaction:(UITapGestureRecognizer *)recognizer{
    
    UILabel *label=(UILabel *)recognizer.view;
    switch (label.tag) {
        case 1:
        {
            DLog(@"关注数");
            ILikeCollectionViewController *iLikeVc = [self.storyboard instantiateViewControllerWithIdentifier:@"ILikeCollectionViewController"];
            [self.navigationController pushViewController:iLikeVc animated:YES];
        }
            break;
        case 2:
        {
            DLog(@"被关注数");
            ILikeCollectionViewController *iLikeVc = [self.storyboard instantiateViewControllerWithIdentifier:@"ILikeCollectionViewController"];
            iLikeVc.segtype = 2;
            [self.navigationController pushViewController:iLikeVc animated:YES];
        }
            break;
        case 3:
        {
            DLog(@"动态");
            DongtaiTableViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DongtaiTableViewController"];
            NSString *userid = [UD objectForKey:USER_ID];
            vc.userid = userid;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        default:
            break;
    }
}

-(void)toJieshao{
    ZiwojieshaoViewController *vc = [[ZiwojieshaoViewController alloc] init];
    vc.title = @"自我介绍";
    NSString *aboutme = [userinfo objectForKey:@"aboutme"];
    vc.jieshao = aboutme;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)toMyLike{
    ILikeCollectionViewController *iLikeVc = [self.storyboard instantiateViewControllerWithIdentifier:@"ILikeCollectionViewController"];
    [self.navigationController pushViewController:iLikeVc animated:YES];
}

-(void)toChat{
    LCEChatListVC *chatListVC = [[LCEChatListVC alloc] init];
    [self.navigationController pushViewController:chatListVC animated:YES];
}

-(void)setUnRadCount{
    NSInteger totalUnreadCount = [[CDStorage storage] countUnread];
    chatBtn.badgeValue = [NSString stringWithFormat:@"%d",totalUnreadCount];
}
@end
