//
//  IncidentDetails.h
//  socialTraffic
//
//  Created by Gareth Day on 31/03/2015.
//  Copyright (c) 2015 Gareth Day. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface IncidentDetails : UIViewController {
    
    NSString *tweetUserDetails;
    NSString *tweetTextDetails;
    NSString *heartRateInfo;
    
}

@property (weak, nonatomic) NSString *incidentTitle;
@property (weak, nonatomic) NSString *incidentTime;
@property (weak, nonatomic) NSString *incidentDate;
@property (weak, nonatomic) NSString *incidentRoad;
@property (weak, nonatomic) NSString *incidentTown;
@property (weak, nonatomic) NSString *incidentCountry;
@property (weak, nonatomic) NSString *incidentSpeed;
@property (weak, nonatomic) NSString *incidentAverageBPM;
@property (weak, nonatomic) NSString *incidentBPM;
@property (weak, nonatomic) NSString *nearestTweet;
@property (weak, nonatomic) NSString *incidentTemperature;
@property (weak, nonatomic) NSString *incidentWeatherCond;

@property CLLocationCoordinate2D incidentLocation;

@property (weak, nonatomic) IBOutlet UILabel *incidentTitleLAbel;
@property (weak, nonatomic) IBOutlet UITextView *IncidentDescriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *incidentTwitterDescription;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;



- (IBAction)dismissView:(id)sender;
@end
