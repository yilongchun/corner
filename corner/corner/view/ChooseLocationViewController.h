//
//  ChooseLocationViewController.h
//  corner
//
//  Created by yons on 15-6-9.
//  Copyright (c) 2015年 hmzl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface ChooseLocationViewController : UIViewController<MAMapViewDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource>{
    MAMapView *_mapView;
    AMapSearchAPI *_search;
}

@property (retain, nonatomic) IBOutlet UITableView *mytableview;

- (IBAction)location:(id)sender;
@end
