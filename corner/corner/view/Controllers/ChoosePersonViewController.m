//
// ChoosePersonViewController.m
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ChoosePersonViewController.h"
#import "Person.h"
#import "MDCSwipeToChoose.h"
#import "UserDetailTableViewController.h"

static const CGFloat ChoosePersonButtonHorizontalPadding = 80.f;
static const CGFloat ChoosePersonButtonVerticalPadding = 20.f;

@interface ChoosePersonViewController ()
@property (nonatomic, strong) NSMutableArray *people;
@end

@implementation ChoosePersonViewController{
    BOOL flag;
    BOOL disabledFlag;
}

#pragma mark - Object Lifecycle

- (instancetype)init {
    self = [super init];
    if (self) {
        // This view controller maintains a list of ChoosePersonView
        // instances to display.
//        _people = [[self defaultPeople] mutableCopy];
//        [self loadData:YES];
    }
    return self;
}

#pragma mark - UIViewController Overrides

- (void)viewDidLoad {
    [super viewDidLoad];
    
    flag = NO;
    disabledFlag = YES;
    UIImageView *img = [[UIImageView alloc] initWithFrame:self.view.frame];
    [img setImage:[UIImage imageNamed:@"mainbackground"]];
    [self.view addSubview:img];
    
    UIButton *menuButton = [[UIButton alloc]initWithFrame:CGRectMake(17, 25, 24, 25)];
    [menuButton setImage:[UIImage imageNamed:@"leftMenu"] forState:UIControlStateNormal];
    [menuButton addTarget:self
                action:@selector(leftMenuClick)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:menuButton];
    
    
    _people = [NSMutableArray array];
    [self showHudInView:self.view hint:@"加载中"];
    [self loadData];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"You couldn't decide on %@.", self.currentPerson.name);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"You noped %@.", self.currentPerson.name);
    } else {
        [self like];
        NSLog(@"You liked %@.", self.currentPerson.name);
    }
    [self loadData];
    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    self.frontCardView = self.backCardView;
    if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backCardView.alpha = 1.f;
                         } completion:^(BOOL finished){
                             if (finished) {
                                 if (!disabledFlag) {
                                     disabledFlag = YES;
                                 }
                             }
                         }];
    }
}

#pragma mark - Internal Methods

- (void)setFrontCardView:(ChoosePersonView *)frontCardView {
    // Keep track of the person currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _frontCardView = frontCardView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDetail)];
    [_frontCardView addGestureRecognizer:tap];
    self.currentPerson = frontCardView.person;
}



- (ChoosePersonView *)popPersonViewWithFrame:(CGRect)frame {
    if ([self.people count] == 0) {
        return nil;
    }

    // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
    // Each take an "options" argument. Here, we specify the view controller as
    // a delegate, and provide a custom callback that moves the back card view
    // based on how far the user has panned the front card view.
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 160.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y - (state.thresholdRatio * 10.f),
                                             CGRectGetWidth(frame),
                                             CGRectGetHeight(frame));
    };

    // Create a personView with the top person in the people array, then pop
    // that person off the stack.
    ChoosePersonView *personView = [[ChoosePersonView alloc] initWithFrame:frame
                                                                    person:self.people[0]
                                                                   options:options];
    [self.people removeObjectAtIndex:0];
    return personView;
}

#pragma mark View Contruction

- (CGRect)frontCardViewFrame {
    CGFloat horizontalPadding = 20.f;
    CGFloat topPadding = 60.f;
    CGFloat bottomPadding = 200.f;
    return CGRectMake(horizontalPadding,
                      topPadding,
                      CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
                      CGRectGetHeight(self.view.frame) - bottomPadding);
}

- (CGRect)backCardViewFrame {
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y + 10.f,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}

// Create and add the "nope" button.
- (void)constructNopeButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"refresh"];
//    UIImage *image = [UIImage imageNamed:@"xButton"];
    button.frame = CGRectMake(ChoosePersonButtonHorizontalPadding,
                              CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [button setBackgroundImage:image forState:UIControlStateNormal];
//    [button setImage:image forState:UIControlStateNormal];
//    [button setTintColor:[UIColor colorWithRed:247.f/255.f
//                                         green:91.f/255.f
//                                          blue:37.f/255.f
//                                         alpha:1.f]];
    [button addTarget:self
               action:@selector(nopeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

// Create and add the "like" button.
- (void)constructLikedButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIImage *image = [UIImage imageNamed:@"like3"];
//    UIImage *image = [UIImage imageNamed:@"checkButton"];
    button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChoosePersonButtonHorizontalPadding,
                              CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding,
                              image.size.width,
                              image.size.height);
    [button setBackgroundImage:image forState:UIControlStateNormal];
//    [button setImage:image forState:UIControlStateNormal];
//    [button setTintColor:[UIColor colorWithRed:29.f/255.f
//                                         green:245.f/255.f
//                                          blue:106.f/255.f
//                                         alpha:1.f]];
    [button addTarget:self
               action:@selector(likeFrontCardView)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
}

#pragma mark Control Events

// Programmatically "nopes" the front card view.
- (void)nopeFrontCardView {
    if (disabledFlag) {
        disabledFlag = NO;
        [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
        [self loadData];
    }
}

// Programmatically "likes" the front card view.
- (void)likeFrontCardView {
    if (disabledFlag) {
        disabledFlag = NO;
        [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
        [self loadData];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

//加载照片
-(void)loadData{
    
    if (_people.count < 5) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *urlString = [NSString stringWithFormat:@"%@%@",HOST,USER_RANDOM_URL];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            manager.responseSerializer = [AFHTTPResponseSerializer serializer];
            manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", @"text/plain", @"text/html", nil];
            [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *result = [NSString stringWithFormat:@"%@",[operation responseString]];
                NSError *error;
                NSDictionary *dic= [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                if (dic == nil) {
                    NSLog(@"json parse failed \r\n");
                }else{
                    NSNumber *status = [dic objectForKey:@"status"];
                    if ([status intValue] == 200) {
                        NSDictionary *message = [[dic objectForKey:@"message"] cleanNull];
                        NSString *avatar_url = [message objectForKey:@"avatar_url"];
                        NSString *nickname = [message objectForKey:@"nickname"];
                        NSNumber *userid = [message objectForKey:@"id"];
                        Person *p = [[Person alloc] initWithName:nickname
                                                          userid:userid
                                                           image:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatar_url]]]
                                                             age:15
                                           numberOfSharedFriends:3
                                         numberOfSharedInterests:2
                                                  numberOfPhotos:1
                                                        userinfo:message];
                        [_people addObject:p];
                        DLog(@"people count:%d ",_people.count);
                        
                        [self loadData];
                        
                        if (!flag && _people.count > 2) {
                            
                            // Display the first ChoosePersonView in front. Users can swipe to indicate
                            // whether they like or dislike the person displayed.
                            self.frontCardView = [self popPersonViewWithFrame:[self frontCardViewFrame]];
                            [self.view addSubview:self.frontCardView];
                            // Display the second ChoosePersonView in back. This view controller uses
                            // the MDCSwipeToChooseDelegate protocol methods to update the front and
                            // back views after each user swipe.
                            self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
                            [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
                            
                            // Add buttons to programmatically swipe the view left or right.
                            // See the `nopeFrontCardView` and `likeFrontCardView` methods.
                            [self constructNopeButton];
                            [self constructLikedButton];
                            flag = YES;
                            [self hideHud];
                        }
                    }else if([status intValue] >= 600){
                        NSString *message = [dic objectForKey:@"message"];
                        [self showHint:message];
                        [self validateUserToken:[status intValue]];
                    }
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"发生错误！%@",error);
                //            [self showHint:@"连接失败"];
            }];
        });
        
        
    }
}
/**
 *  查看个人详情
 */
-(void)showDetail{
    NSString *nickname = self.currentPerson.name;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UserDetailTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"UserDetailTableViewController"];
    vc.title = nickname;
    vc.userinfo = self.currentPerson.userinfo;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  关注
 */
-(void)like{
    NSString *userid = [UD objectForKey:USER_ID];
    NSString *token = [UD objectForKey:[NSString stringWithFormat:@"%@%@",USER_TOKEN_ID,userid]];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:token forKey:@"token"];
    [parameters setValue:[self.currentPerson.userinfo objectForKey:@"id"] forKey:@"user_b_id"];
    
    NSString *urlString = urlString = [NSString stringWithFormat:@"%@%@",HOST,CONSTACTS_CREATE_URL];
    
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

-(void)leftMenuClick{
    [self.sideMenuViewController presentLeftMenuViewController];
}


@end
