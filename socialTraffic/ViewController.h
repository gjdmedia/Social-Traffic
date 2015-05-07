//
//  ViewController.h
//  socialTraffic
//
//  Created by Gareth Day on 23/03/2015.
//  Copyright (c) 2015 Gareth Day. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "EFCircularSlider.h"
#import <MapKit/MapKit.h>
#import "IncidentDetails.h"
#import "twitterDetails.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <TwitterKit/TwitterKit.h>


@interface ViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, CBCentralManagerDelegate> {
    
    float curLat;
    float curLong;
    NSString *currentTown;
    NSString *currentCountry;
    NSString *currentRoad;
    NSString *weatherDescription;
    int temperatureCelcius;
    int speed;
    NSString *heartRate;
    CBCentralManager *centralManager;
    CBPeripheral *discoveredPeripheral;
    BOOL mapInteraction;
    NSString *roadItem;
    NSString *townItem;
    
}



@property (weak, nonatomic) IBOutlet UIImageView *weatherIndicatorImage;
@property (weak, nonatomic) IBOutlet UIImageView *heartrateConnected;
@property (weak, nonatomic) IBOutlet UIButton *triggerIncident;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *speedText;
@property (weak, nonatomic) IBOutlet UILabel *averageSpeedText;
@property (weak, nonatomic) IBOutlet UILabel *averageBpmText;
@property (weak, nonatomic) IBOutlet UILabel *bpmText;
@property (weak, nonatomic) IBOutlet UILabel *tempText;

@property (weak, nonatomic) NSString *pinTitle;
@property (weak, nonatomic) NSString *pinSubtitle;
//Twitter Pins
@property (weak, nonatomic) NSString *pinTweetID;
@property (weak, nonatomic) NSString *pinTweetTextID;
@property (weak, nonatomic) NSURL *pinTweetImageID;
// Incident Pins
@property (weak, nonatomic) NSString *incidentTweetID;
@property (weak, nonatomic) NSString *incidentTime;
@property (weak, nonatomic) NSString *incidentSpeed;
@property (weak, nonatomic) NSString *incidentBPM;
@property (weak, nonatomic) NSString *incidentAverageBPM;
@property (weak, nonatomic) NSString *incidentTemperature;
@property (weak, nonatomic) NSString *incidentWeatherConditions;
@property (nonatomic) CLLocationCoordinate2D incidentLocation;


@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *location;

@property (weak, nonatomic) IBOutlet UIButton *refreshDataFeeds;
@property (weak, nonatomic) IBOutlet EFCircularSlider *heartBPMSlider;
@property (weak, nonatomic) IBOutlet EFCircularSlider *vehichleSpeedSlider;
@property (retain, nonatomic) NSMutableArray *speedArray;
@property (retain, nonatomic) NSMutableArray *bpmArray;
@property (retain, nonatomic) NSMutableDictionary *tweetsResponse;
@property (retain, nonatomic) NSMutableArray *tweetDistanceArray;
@property (retain, nonatomic) NSMutableArray *tweetIDArray;


@end

