//
//  MapViewController.m
//  TWeiBo
//
//  Created by 健锋 章 on 11-9-20.
//  Copyright (c) 2011年 Zelome Inc. All rights reserved.
//

#import "MapViewController.h"

@implementation MapViewController

@synthesize mapView;
@synthesize locManager;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager error: %@", [error description]);
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    return;    
    /*
    CLLocationCoordinate2D loc = [newLocation coordinate];
    MKCoordinateRegion theRegion;
    theRegion.center = loc;
    
    latitude = loc.latitude;
    longitude = loc.longitude;
    
    //地图的范围 越小越精确
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.01;
    theSpan.longitudeDelta = 0.01;
    theRegion.span = theSpan;
    [mapView setRegion:theRegion];
     */
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView1 viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = nil;
    
    static NSString *defaultPinID = @"com.zelome.pin";
    pinView = (MKPinAnnotationView *)[mapView1 dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
    if ( pinView == nil ) pinView = [[[MKPinAnnotationView alloc]
                                      initWithAnnotation:annotation reuseIdentifier:defaultPinID] autorelease];
    pinView.pinColor = MKPinAnnotationColorRed;
    pinView.canShowCallout = YES;
    pinView.animatesDrop = NO;
    //[mapView1.userLocation setTitle:@"欧陆经典"];
    //[mapView1.userLocation setSubtitle:@"vsp"];
       
    return pinView;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 44, 320, 420)];
    mapView.userInteractionEnabled = YES;
    mapView.showsUserLocation = YES;
    mapView.delegate = self;
    [mapView setMapType:MKMapTypeStandard];
    [self.view addSubview:mapView];
    
    locManager = [[CLLocationManager alloc] init];
    [locManager setDelegate:self]; 
    [locManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [locManager setDistanceFilter:5.0f];
    [locManager startUpdatingLocation];
    
    MKCoordinateRegion theRegion;
    theRegion.center = [[locManager location] coordinate];
    
    //地图的范围 越小越精确
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta = 0.01;
    theSpan.longitudeDelta = 0.01;
    theRegion.span = theSpan;
    [mapView setRegion:theRegion];
    
    
    UILongPressGestureRecognizer *lpress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    lpress.minimumPressDuration = 0.3;//按0.5秒响应longPress方法
    lpress.allowableMovement = 10.0;
    //给MKMapView加上长按事件
    [self.mapView addGestureRecognizer:lpress];//mapView是MKMapView的实例
    [lpress release];
}

- (void)longPress:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){  //这个状态判断很重要
        //坐标转换
        CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
        CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint   toCoordinateFromView:self.mapView];
        
        //这里的touchMapCoordinate.latitude和touchMapCoordinate.longitude就是你要的经纬度，
        //NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?latlng=%f,%f&sensor=false&region=sh&language=zh-CN", touchMapCoordinate.latitude, touchMapCoordinate.longitude];
        //[NSThread detachNewThreadSelector:@selector(loadMapDetailByUrl:) toTarget:self withObject:url];
        NSLog(@"%f %f", touchMapCoordinate.latitude, touchMapCoordinate.longitude);
    }
}

- (IBAction) back:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    [mapView release];
    [locManager release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
