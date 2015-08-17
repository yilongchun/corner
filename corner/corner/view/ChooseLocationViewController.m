//
//  ChooseLocationViewController.m
//  corner
//
//  Created by yons on 15-6-9.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import "ChooseLocationViewController.h"

@implementation ChooseLocationViewController{
    UIImageView *img;//大头针图片
    NSMutableArray *dataSource;
    
    MAUserLocation *myuserLocation;
}


-(void)viewDidLoad{
    [super viewDidLoad];
    
//    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.automaticallyAdjustsScrollViewInsets = YES;
//        self.extendedLayoutIncludesOpaqueBars = YES;
//    }
    
    img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_3_v1"]];
    
    dataSource = [NSMutableArray array];
    
    
    //配置用户Key
    [MAMapServices sharedServices].apiKey = GAODE_API_KEY;
    
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.bounds), 200)];
    _mapView.logoCenter = CGPointMake(CGRectGetWidth(self.view.bounds)-55, 190);
    _mapView.showsCompass= NO;// 设置成NO表示关闭指南针；YES表示显示指南针
    _mapView.showsScale = NO;  //设置成NO表示不显示比例尺；YES表示显示比例尺
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    [self.view addSubview:_mapView];
    
    
    [img setFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 7, 64 + 100 - 36, 14, 36)];
    [self.view addSubview:img];
    
    self.mytableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 200 + 64, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 264) style:UITableViewStylePlain];
    self.mytableview.delegate = self;
    self.mytableview.dataSource = self;
    [self.view addSubview:self.mytableview];
        
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] initWithSearchKey:GAODE_API_KEY Delegate:self];
    
}

#pragma mark - AMapSearchDelegate

//实现 POI 搜索对应的回调函数
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)response
{
    self.title = @"选择地点";
    if(response.pois.count == 0) {
        [self.mytableview reloadData];
        return;
    }
    //处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %ld",(long)response.count];
    NSString *strSuggestion = [NSString stringWithFormat:@"Suggestion: %@",response.suggestion];
    NSString *strPoi = @"";
    for (AMapPOI *p in response.pois) {
        strPoi = [NSString stringWithFormat:@"%@\nPOI: %@", strPoi, p.description];
        [dataSource addObject:p];
    }
//    NSString *result = [NSString stringWithFormat:@"%@ \n %@ \n %@", strCount, strSuggestion, strPoi];
//    NSLog(@"Place: %@", result);
    [self.mytableview reloadData];
}

#pragma mark - MAMapViewDelegate

-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        myuserLocation = userLocation;
    }
}

- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    NSLog(@" regionWillChangeAnimated");
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
    self.title = @"正在获取数据";
    
    //缩放动画
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.5;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [img.layer addAnimation:animation forKey:nil];
    
    [dataSource removeAllObjects];
    
    MACoordinateRegion region;//定义一个区域（用定义的经纬度和范围来定义）
    CLLocationCoordinate2D centerCoordinate = mapView.region.center;//经纬度
    region.center= centerCoordinate;
    
    
    AMapPlaceSearchRequest *request = [[AMapPlaceSearchRequest alloc] init];
    
    request.searchType          = AMapSearchType_PlaceAround;
    request.location            = [AMapGeoPoint locationWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude];
    /* 按照距离排序. */
    request.sortrule            = 1;
    request.requireExtension    = YES;
    
    /* 添加搜索结果过滤 */
//    AMapPlaceSearchFilter *filter = [[AMapPlaceSearchFilter alloc] init];
//    filter.costFilter = @[@"100", @"200"];
//    filter.requireFilter = AMapRequireGroupbuy;
//    request.searchFilter = filter;
    
    [_search AMapPlaceSearch:request];
    
}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [dataSource count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ditucell"];
    if (cell ==  nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ditucell"];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = [UIColor darkGrayColor];
    }
    
    AMapPOI *p = [dataSource objectAtIndex:indexPath.row];

    NSString *name = p.name;
    NSString *address = p.address;
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"当前地图位置";
    }else{
        cell.textLabel.text = name;
    }
    cell.detailTextLabel.text = address;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < dataSource.count) {
        AMapPOI *p = [dataSource objectAtIndex:indexPath.row];
        NSString *name = p.name;
        CGFloat latitude = p.location.latitude;
        CGFloat longitude = p.location.longitude;
        
        
        NSDictionary *dict =[[NSDictionary alloc] initWithObjectsAndKeys:name,@"name",[NSNumber numberWithFloat:latitude],@"latitude",[NSNumber numberWithFloat:longitude],@"longitude", nil];
        //创建通知
        NSNotification *notification =[NSNotification notificationWithName:@"chooseLocation" object:nil userInfo:dict];
        //通过通知中心发送通知
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


- (IBAction)location:(id)sender {
    
    _mapView.showsUserLocation = YES;
    
    if (myuserLocation != nil) {
        [_mapView setCenterCoordinate:myuserLocation.coordinate animated:YES];
    }
    
}
@end
