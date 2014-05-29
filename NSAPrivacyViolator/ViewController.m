//
//  ViewController.m
//  NSAPrivacyViolator
//
//  Created by Thomas Orten on 5/29/14.
//  Copyright (c) 2014 Orten, Thomas. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextView *myTextView;

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
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

@end
