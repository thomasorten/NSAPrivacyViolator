//
//  ViewController.m
//  NSAPrivacyViolator
//
//  Created by Thomas Orten on 5/29/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *myTextView;
@property (weak, nonatomic) IBOutlet UIButton *noButton;
@property (weak, nonatomic) IBOutlet UIButton *yesButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.myLocationManager = [[CLLocationManager alloc] init];
    self.myLocationManager.delegate = self;
	// Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)startViolatingPrivacy:(id)sender
{
    [self.myLocationManager startUpdatingLocation];
    self.myTextView.text = @"Finding your location...";
    self.yesButton.hidden = YES;
    self.noButton.hidden = YES;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000) {
            self.myTextView.text = @"Location found. Reverse geooding...";
            [self reverseGeoCode: location];
            [self.myLocationManager stopUpdatingLocation];
            break;
        }
    }
}

- (void)reverseGeoCode:(CLLocation *)location
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        NSString *address = [NSString stringWithFormat:@"You can't hide from the NSA!! \n %@ %@ %@",
                             placemark.subThoroughfare,
                             placemark.thoroughfare,
                             placemark.locality];
        self.myTextView.text = address;
        [self findJailNear:location];
    }];
}

- (void)findJailNear:(CLLocation *)location
{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"prison";
    request.region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(1, 1));
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        MKMapItem *mapItem = response.mapItems.firstObject;
        self.myTextView.text = [NSString stringWithFormat:@"You should go to %@", mapItem.name];
        [self getDirectionsTo:mapItem];
    }];
}

- (void)getDirectionsTo:(MKMapItem *)mapItem
{
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = mapItem;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        MKRoute *route = response.routes.firstObject;
        NSMutableString *directionsString = [[NSMutableString alloc] init];
        int x = 1;
        for (MKRouteStep *step in route.steps) {
            [directionsString appendFormat:@"%d: %@ \n", x, step.instructions];
            x++;
        }
        self.myTextView.text = directionsString;
    }];
}

@end
