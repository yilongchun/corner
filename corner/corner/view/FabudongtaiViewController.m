//
//  FabudongtaiViewController.m
//  corner
//
//  Created by yons on 15-6-9.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "FabudongtaiViewController.h"
#import "ChooseLocationViewController.h"
#import "IQKeyboardManager.h"

@implementation FabudongtaiViewController{
    UIImagePickerController *imagePicker1;//照相机
    UIImagePickerController *imagePicker2;//照片选择
    
    NSDictionary *userInfo;
    NSData *imageData;//选择的图片
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseLocation:) name:@"chooseLocation" object:nil];
    
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        self.automaticallyAdjustsScrollViewInsets = NO; // Avoid the top UITextView space, iOS7 (~bug?)
    }
}

- (IBAction)toChooseLocation:(id)sender {
    ChooseLocationViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseLocationViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  设置地址
 *
 *  @param text
 */
-(void)chooseLocation:(NSNotification *)text{
    
    userInfo = text.userInfo;
    
    NSString *name = text.userInfo[@"name"];
//    NSNumber *latitude = text.userInfo[@"latitude"];
//    NSNumber *longitude = text.userInfo[@"longitude"];
//    
//    DLog(@"%f",[latitude floatValue]);
//    DLog(@"%f",[longitude floatValue]);
    [self.locationBtn setTitle:name forState:UIControlStateNormal];
    
}

- (void)textViewDidChange:(UITextView *)textView{
    if ([textView.text isEqualToString:@""]) {
        [self.tishiLabel setHidden:NO];
    }else{
        [self.tishiLabel setHidden:YES];
    }
}

- (IBAction)toChooseImage:(id)sender{
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
    }
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        UIImage  *img = [info objectForKey:UIImagePickerControllerEditedImage];
        imageData = UIImagePNGRepresentation(img);
//        [self uploadImage:data];
        [self.chooseImageBtn setImage:img forState:UIControlStateNormal];
        [self.chooseImageBtn setImage:img forState:UIControlStateHighlighted];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
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
            [self updateImageData:key];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"发生错误！%@",error);
        [self hideHud];
        [self showHint:@"连接失败"];
    }];
}

/**
 *  第三部 提交数据
 *
 *  @param key key
 */
-(void)updateImageData:(NSString *)key{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    //参数
    [parameters setValue:_mytextview.text forKey:@"post_body"];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:userInfo[@"name"] forKey:@"location_desc"];
    
    NSNumber *latitude = userInfo[@"latitude"];
    NSNumber *longitude = userInfo[@"longitude"];
    
    [parameters setValue:[NSString stringWithFormat:@"%f,%f",[longitude floatValue],[latitude floatValue]] forKey:@"location"];
    if (key != nil) {
        [parameters setValue:[NSString stringWithFormat:@"%@%@",QINIU_IMAGE_URL,key] forKey:@"pic_url"];
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,POST_CREATE_URL];
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
//                NSDictionary *message = [[dic objectForKey:@"message"] cleanNull];
                [self showHint:@"发布成功"];
//                DLog(@"%@",message);
                int64_t delayInSeconds = 1.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"loadDongTai" object:nil];
                });
                
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
- (IBAction)submit:(id)sender {
    [[IQKeyboardManager sharedManager] resignFirstResponder];
    if ([_mytextview.text isEqualToString:@""]) {
        [self showHint:@"请填写内容"];
        return;
    }
    if (userInfo == nil) {
        [self showHint:@"请选择位置"];
        return;
    }
    if (imageData != nil) {
        [self uploadImage:imageData];
    }else{
        [self updateImageData:nil];
    }
    
    
}

-(void)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
