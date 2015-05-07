//
//  IncidentDetails.m
//  socialTraffic
//
//  Created by Gareth Day on 31/03/2015.
//  Copyright (c) 2015 Gareth Day. All rights reserved.
//

#import "IncidentDetails.h"
#import "ViewController.h"
#import <TwitterKit/TwitterKit.h>

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:0.9]

@interface IncidentDetails ()

@end

@implementation IncidentDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Create coordinates from the incident location and reverse geo code to find the street and town
    CLLocation *locationCoords = [[CLLocation alloc] initWithLatitude:_incidentLocation.latitude longitude:_incidentLocation.longitude];
    [self reverseGeocode:locationCoords];
    
    //Set up the UI parameters for the view controller
    _bgImage.backgroundColor = Rgb2UIColor(41, 47, 51);
    _bgImage.layer.cornerRadius = 5;
    _bgImage.layer.borderColor = [UIColor whiteColor].CGColor;
    _bgImage.layer.borderWidth = 2.0f;
    [[_bgImage layer] setShadowColor:[UIColor blackColor].CGColor];
    [[_bgImage layer] setShadowOpacity:0.6f];
    [[_bgImage layer] setShadowRadius:6.0f];
    [[_bgImage layer] setShadowOffset:CGSizeMake(0, 3)];
    
}

// Update the viewcontroller with the details of the incident
-(void) updateIncidentDisplay {
    
    // If the incident has a tweetID associated with it, call the load tweet method
    if (![_nearestTweet isKindOfClass:[NSNull class]]) {
        [self getTweetbyID];
    } else {
        
        // If the tweetId is null, display default text
        [_incidentTwitterDescription setText: [NSString stringWithFormat:@"Nobody nearby was tweeting!"]];
        
    }
    
    // Check if the heart rate info is contained within the incident log, otherwise display the default text
    if (![_incidentBPM isKindOfClass:[NSNull class]]) {
        heartRateInfo = [NSString stringWithFormat:@"was %@ BPM",_incidentBPM];
    } else {
        NSLog(@"Heart Rate is Null");
        heartRateInfo = [NSString stringWithFormat:@"could not be recorded"];
    }
    
    
    // Format the incident details text string
    NSString *incidentDay = _incidentDate;
    NSString *incidentHours = _incidentTime;
    NSString *incidentTemp = _incidentTemperature;
    NSString *incidentWeather = _incidentWeatherCond;
    
    
    [_IncidentDescriptionLabel setText:[NSString stringWithFormat:@"%s%@%s%@%s%@%s%@%s%@%s%@%s%@%s%@%s","On ",incidentDay," at ", incidentHours," an incident took place on ", _incidentRoad, ", ", _incidentTown, ". The vehicle was travelling at ", _incidentSpeed, " mph and the drivers heartrate ", heartRateInfo, " at the time of the incident. The weather conditions were ", incidentWeather, " with a temperature of ", incidentTemp, " Celsius."]];
    _IncidentDescriptionLabel.textColor = [UIColor whiteColor];
    
    NSLog(@"Incident Stuff: %@", [_IncidentDescriptionLabel text]);
    
    
    
}


- (void)getTweetbyID {
    
    // Create a guest login session to the twitterkit API to load the tweet assosciated with the inident
    
    [[Twitter sharedInstance] logInGuestWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
        
        //Search for keywords at current users GPS coords
        NSString *statusesShowEndpoint = [NSString stringWithFormat:@"%s%@","https://api.twitter.com/1.1/statuses/show.json?id=",_nearestTweet];
        NSLog(@"URL Resuest %@", statusesShowEndpoint);
        
        NSError *clientError;
        NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                                 URLRequestWithMethod:@"GET"
                                 URL:statusesShowEndpoint
                                 parameters:nil
                                 error:&clientError];
        
        if (request) {
            [[[Twitter sharedInstance] APIClient]
             sendTwitterRequest:request
             completion:^(NSURLResponse *response,
                          NSData *data,
                          NSError *connectionError) {
                 if (data) {
                     // handle the response data e.g.
                     NSError *jsonError;
                     NSDictionary *json = [NSJSONSerialization
                                           JSONObjectWithData:data
                                           options:0
                                           error:&jsonError];
                     
                     
                     
                     NSArray *userDetails = [json valueForKey:@"user"];
                     NSArray *tweeterName = [userDetails valueForKey:@"screen_name"];
                     NSArray *tweetTextContent = [json valueForKey:@"text"];
                     
                     // Once the data is loaded from twitter, construct the string to display alongside the incident details.
                     
                     [_incidentTwitterDescription setText: [NSString stringWithFormat:@"%s%@%s%@%s", "Nearby, ",tweeterName, " tweeted ", tweetTextContent, " on Twitter"]];
                     _incidentTwitterDescription.textColor = [UIColor whiteColor];
                     
                 }
                 else {
                     NSLog(@"Error: %@", connectionError);
                     //[self performSelector:@selector(getTweetbyID) withObject:nil afterDelay:2.0];
                     [_incidentTwitterDescription setText: [NSString stringWithFormat:@"Couldn't load Twitter data"]];
                     _incidentTwitterDescription.textColor = [UIColor whiteColor];
                 }
             }];
        }
        else {
            // Handle any errors
            NSLog(@"Error: %@", clientError);
        }
        
    }];
    
    
}




// Reverse geocode the incident location
- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Finding address");
        if (error) {
            _incidentRoad = [NSString stringWithFormat:@"An unkown road"];
            _incidentTown = [NSString stringWithFormat:@"An unkown town"];
            
            
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            _incidentTown = [placemark locality];
            _incidentRoad = [placemark thoroughfare];
            [self updateIncidentDisplay];
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
