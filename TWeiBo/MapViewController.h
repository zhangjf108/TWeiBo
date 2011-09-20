//
//  MapViewController.h
//  TWeiBo
//
//  Created by 健锋 章 on 11-9-20.
//  Copyright (c) 2011年 Zelome Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController<MKMapViewDelegate,MKAnnotation, CLLocationManagerDelegate> {
    MKMapView *mapView;
    CLLocationManager *locManager;
    
    float latitude;
    float longitude;
}

@property(nonatomic, retain) MKMapView *mapView;
@property(nonatomic, retain) CLLocationManager *locManager;

- (IBAction) back:(id)sender;

@end
