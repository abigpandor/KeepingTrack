//
//  KTFirstViewController.m
//  KeepingTrack
//
//  Copyright (c) 2013, ggeoffre, LLC
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//   * Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//   * Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//   * Neither the name of the ggeoffre, LLC nor the
//     names of its contributors may be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL GGEOFFRE, LLC BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "KTFirstViewController.h"

@interface KTFirstViewController ()

@end

@implementation KTFirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Map", @"Map");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // 13 - Working with Multiple Points
    double pointOneLatitude = 39.13333;
    double pointOneLongitude = -84.50000;
    CLLocationCoordinate2D pointOneCoordinate =
        {pointOneLatitude, pointOneLongitude};
    KTMapAnnotation *pointOneAnnotation =
        [[KTMapAnnotation alloc] initWithCoordinate:pointOneCoordinate];
    [pointOneAnnotation setTypeOfAnnotation:PIN_ANNOTATION];
    [self.myMapView addAnnotation:pointOneAnnotation];
    
    double pointTwoLatitude = 41.38376;
    double pointTwoLongitude = -82.64496;
    CLLocationCoordinate2D pointTwoCoordinate =
    {pointTwoLatitude, pointTwoLongitude};
     KTMapAnnotation *pointTwoAnnotation =
     [[KTMapAnnotation alloc] initWithCoordinate:pointTwoCoordinate];
    [pointTwoAnnotation setTypeOfAnnotation:ARROW_ANNOTATION];
    [self.myMapView addAnnotation:pointTwoAnnotation];

    [self.myMapView setRegion:MKCoordinateRegionMakeWithDistance(pointTwoCoordinate,300000, 300000) animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 03 - Become a MKMapViewDelegate
- (MKAnnotationView *) mapView:(MKMapView *) mapView viewForAnnotation: (id) annotation
{
    
    // 13 - Working with Multiple Points
    MKAnnotationView *customAnnotationView;
    if ([annotation isKindOfClass:[KTMapAnnotation class]] ){
        KTMapAnnotation *theAnnotation = (KTMapAnnotation*)annotation;
        if ([[theAnnotation typeOfAnnotation] isEqualToString:PIN_ANNOTATION]) {
            customAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];

            // 06 - Supporting Drag and Drop
            [customAnnotationView setDraggable:YES];
            
        }else{
            customAnnotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];

            // 17 - Determine the direction
            UIImage *arrowImage = [UIImage imageNamed:@"blue-arrow.png"];
            double direction = [theAnnotation direction];
            [customAnnotationView setImage:[self rotatedImage:arrowImage byDegreesFromNorth:direction]];
            
            // 08 - Add a Callout
            [customAnnotationView setCanShowCallout:YES];
            
            // 10 - Add an Image to the Callout
            UIImageView *leftIconView =
            [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"codemash-left-callout.png"]];
            [customAnnotationView setLeftCalloutAccessoryView:leftIconView];
            
            // 11 - Add a Button to the Callout
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [customAnnotationView setRightCalloutAccessoryView:rightButton];
            
        }
    }else{
        return nil;
    }

    return customAnnotationView;
}

// 07 - Do Something when Dropped
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        NSLog(@"Do something when annotation is dropped");
        
        // 14 - Draw a line between two points
        [self.myMapView removeOverlays:self.myMapView.overlays];
        MKMapPoint startPoint;
        MKMapPoint endPoint;
        CLLocation *startLocation;
        CLLocation *endLocation;
        KTMapAnnotation *startAnnotation;
        for (KTMapAnnotation *theAnnotation in [self.myMapView annotations]){
            if ([[theAnnotation typeOfAnnotation] isEqualToString:ARROW_ANNOTATION]) {
                startPoint = MKMapPointForCoordinate(theAnnotation.coordinate);
                startLocation = [[CLLocation alloc] initWithLatitude: theAnnotation.coordinate.latitude longitude: theAnnotation.coordinate.longitude];
                startAnnotation = theAnnotation;
            }else{
                endPoint = MKMapPointForCoordinate(theAnnotation.coordinate);
                endLocation = [[CLLocation alloc] initWithLatitude: theAnnotation.coordinate.latitude longitude: theAnnotation.coordinate.longitude];
            }
        }
        MKMapPoint *pointArray = malloc(sizeof(CLLocationCoordinate2D) * 2);
        pointArray[0] = startPoint;
        pointArray[1] = endPoint;
        MKPolyline *routeLine = [MKPolyline polylineWithPoints:pointArray count:2];
        [self.myMapView addOverlay:routeLine];
        
        // 16 - Determine the distance
        CLLocationDistance meters = [startLocation distanceFromLocation:endLocation];
        [self.myDistance setText:[NSString stringWithFormat:@"Distance: %.01f km", ( meters / 1000 ) ]];
        
        // 17 - Determine the direction
        double lat1 = startLocation.coordinate.latitude * M_PI / 180.0;
        double lon1 = startLocation.coordinate.longitude * M_PI / 180.0;
        double lat2 = endLocation.coordinate.latitude * M_PI / 180.0;
        double lon2 = endLocation.coordinate.longitude * M_PI / 180.0;
        
        double dLon = lon2 - lon1;
        double y = sin(dLon) * cos(lat2);
        double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        double radiansBearing = atan2(y, x);
        
        CLLocationDirection directionBetweenPoints = radiansBearing * 180.0 / M_PI;
        [self.myDirection setText:[NSString stringWithFormat:@"Direction: %.01f dir", directionBetweenPoints ]];
        
        double degrees = directionBetweenPoints + 180.0;
        if ((degrees >= 22.5 ) && (degrees < 67.5 )){
            [self.myDirection setText:@"Direction: SW"];
        }else if ((degrees >= 67.5 ) && (degrees < 112.5 )){
            [self.myDirection setText:@"Direction: W"];
        }else if ((degrees >= 112.5 ) && (degrees < 157.5 )){
            [self.myDirection setText:@"Direction: NW"];
        }else if ((degrees >= 157.5 ) && (degrees < 202.5 )){
            [self.myDirection setText:@"Direction: N"];
        }else if ((degrees >= 202.5 ) && (degrees < 247.5 )){
            [self.myDirection setText:@"Direction: NE"];
        }else if ((degrees >= 247.5 ) && (degrees < 292.5 )){
            [self.myDirection setText:@"Direction: E"];
        }else if ((degrees >= 292.5 ) && (degrees < 337.5 )){
            [self.myDirection setText:@"Direction: SE"];
        }else{
            [self.myDirection setText:@"Direction: S"];
        }
        
        [startAnnotation setDirection:directionBetweenPoints];
        [self.myMapView removeAnnotation:startAnnotation];
        [self.myMapView addAnnotation:startAnnotation];

        CLLocationCoordinate2D location = {startLocation.coordinate.latitude, startLocation.coordinate.longitude};
        [self.myMapView setRegion:MKCoordinateRegionMakeWithDistance(location,(meters * 1.30),(meters * 1.30)) animated:YES];

    }
}

// 17 - Determine the direction
- (UIImage*)rotatedImage:(UIImage*)sourceImage byDegreesFromNorth:(double)degrees
{
    
    CGSize rotateSize =  sourceImage.size;
    UIGraphicsBeginImageContext(rotateSize);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, rotateSize.width/2, rotateSize.height/2);
    CGContextRotateCTM(context, ( degrees * M_PI/180.0 ) );
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(UIGraphicsGetCurrentContext(),
                       CGRectMake(-rotateSize.width/2,-rotateSize.height/2,rotateSize.width, rotateSize.height),
                       sourceImage.CGImage);
    UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return rotatedImage;
}

// 09 - Auto Display Callout
- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    [self.myMapView selectAnnotation: [[self.myMapView annotations] lastObject] animated:YES];
}

// 12a - Do Something when Tapped
- (void)mapView:(MKMapView *) mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"Do Something when tapped");
    
    // 12c - Jump to the second tab
    [self.tabBarController setSelectedIndex:1];

}

// 15 - Draw a line between two points
- (MKOverlayView *) mapView:(MKMapView *) mapView viewForOverlay:(id) overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]){
        MKPolylineView *polylineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        [polylineView setFillColor:[UIColor blueColor]];
        [polylineView setStrokeColor:[UIColor blueColor]];
        [polylineView setLineWidth:3];
        MKOverlayView *overlayView = polylineView;
        return overlayView;
    }else {
        return nil;
    }
}

@end
