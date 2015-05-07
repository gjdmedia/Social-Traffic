
//  ViewController.m
//  socialTraffic
//
//  Created by Gareth Day on 23/03/2015.
//  Copyright (c) 2015 Gareth Day. All rights reserved.
//

#import "ViewController.h"

#import "tweetAnnotation.h"
#import "incidentAnnotation.h"

#define Rgb2UIColor(r, g, b)  [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialise Arrays, Dictionaries, location manager, bluetooth manager etc and set initial values.
    
    mapInteraction = NO;
    _locationManager = [[CLLocationManager alloc] init];
    _speedArray = [[NSMutableArray alloc] init];
    _bpmArray = [[NSMutableArray alloc] init];
    _tweetsResponse = [[NSMutableDictionary alloc] init];
    _tweetDistanceArray = [[NSMutableArray alloc] init];
    _tweetIDArray = [[NSMutableArray alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    [_locationManager requestAlwaysAuthorization];
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];
    _location = [[CLLocation alloc] init];
    _heartBPMSlider.enabled = NO;
    _heartBPMSlider.maximumValue = 120;
    _heartBPMSlider.lineWidth = 6;
    _heartBPMSlider.filledColor = Rgb2UIColor(224, 100, 98);
    _heartBPMSlider.unfilledColor = [UIColor colorWithRed:131 green:161 blue:191 alpha:100];
    
    
    // Initialise the speed slider values
    _vehichleSpeedSlider.enabled = NO;
    _vehichleSpeedSlider.maximumValue = 120;
    _vehichleSpeedSlider.lineWidth = 8;
    _vehichleSpeedSlider.filledColor = Rgb2UIColor(131, 161, 191);
    _vehichleSpeedSlider.unfilledColor = [UIColor colorWithRed:131 green:161 blue:191 alpha:100];
    
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    // Call the data acquisition methods after 1.0 sec delay
    [self performSelector:@selector(getThingSpeakData) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(getTwitterFeed) withObject:nil afterDelay:1.0];
    [self performSelector:@selector(getWeatherFeed) withObject:nil afterDelay:1.0];
    
    
    // Initialise the map view
    [_mapView setDelegate:self];
    [[_mapView layer] setMasksToBounds:NO];
    [[_mapView layer] setShadowColor:[UIColor blackColor].CGColor];
    [[_mapView layer] setShadowOpacity:1.0f];
    [[_mapView layer] setShadowRadius:6.0f];
    [[_mapView layer] setShadowOffset:CGSizeMake(0, 6)];
    
}


// Shared data


- (void)getThingSpeakData {
    
    // Load the data from the thingspeak channel
    
    NSString * urlString = [NSString stringWithFormat:@"%s","http://api.thingspeak.com/channels/31737/feed.json?results=100"];
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil)
         {
             // If we have received the thingspeak JSON data, add the required elements to their respective arrays
             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
             NSMutableDictionary *channelResponse = [[json valueForKey:@"feeds"] mutableCopy];
             NSArray *timeArray = [channelResponse valueForKey:@"created_at"];
             NSArray *lattitudeArray = [channelResponse valueForKey:@"field1"];
             NSArray *longitudeArray = [channelResponse valueForKey:@"field2"];
             NSArray *speedRateArray = [channelResponse valueForKey:@"field3"];
             NSArray *heartRatesArray = [channelResponse valueForKey:@"field4"];
             NSArray *tweetArray = [channelResponse valueForKey:@"field5"];
             NSArray *tempArray = [channelResponse valueForKey:@"field6"];
             NSArray *weatherArray = [channelResponse valueForKey:@"field7"];
             // NSLog(@"Number of Entries: %lu Data = %@",(unsigned long)[timeArray count] ,json);
             
             // Count the number of incident entries in the data and add annotations to the map using a while loop
             
             int i = 0;
             
             while (i <= [timeArray count]-1) {
                 
                 NSNumber * latitude = [lattitudeArray objectAtIndex:i];
                 NSNumber * longitude = [longitudeArray objectAtIndex:i];
                 NSString * speedItem = [speedRateArray objectAtIndex:i];
                 NSString * heartItem = [heartRatesArray objectAtIndex:i];
                 
                 NSString *annotationTitle = [NSString stringWithFormat:@"Incident"];
                 
                 NSArray *parsedTimeArray = [[timeArray objectAtIndex:i] componentsSeparatedByString:@"T"];
                 NSString *incidentDay = [parsedTimeArray objectAtIndex:0];
                 NSArray *formatTime = [[parsedTimeArray objectAtIndex:1] componentsSeparatedByString:@"Z"];
                 NSString *timeItem = [formatTime objectAtIndex:0];
                 
                 incidentAnnotation *incidentEntry = [[incidentAnnotation alloc] initWithTitle:annotationTitle subtitle:incidentDay tweetIdentifier:[tweetArray objectAtIndex:i] incidentTime:timeItem incidentSpeed:speedItem incidentBPM:heartItem incidentAverageBPM:heartItem incidentTemperature:[NSString stringWithFormat:@"%@", [tempArray objectAtIndex:i]] incidentWeatherConditions:[weatherArray objectAtIndex:i] andCoordinate:CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue])];
                 
                 [_mapView addAnnotation:incidentEntry];
                 
                 i++;
             }
             
             //NSLog(@"Number of Entries: %lu Values: %@", (unsigned long)[heartRatesArray count], heartRatesArray);
             
             
         }
         else {
             // If there is a data error, try again until data is succesful
             
             //NSLog(@"Cant Get Thingspeak!!");
             [self performSelector:@selector(getThingSpeakData) withObject:nil afterDelay:2.0];
         }
     }];
    
}


// Add an entry to the thingspeak data

-(void) sendUpdateToThingSpeak {
    
    // If the heart rate data array is empty i.e there is not monitor detected, set the heart rate value to '0'
    
    NSString *heartRateValue;
    
    if(!_bpmArray.count > 0) {
        heartRateValue =@"0";
        //NSLog(@"Heart Rate is Null");
    } else {
        heartRateValue = [_bpmArray lastObject];
        //NSLog(@"Heart Rate: %@", heartRateValue);
    }
    
    NSError *error = nil;
    
    // Create a http request and populate the URL with the required data
    NSString * updateString = [NSString stringWithFormat:@"%s%f%s%f%s%@%s%@%s%@%s%d%s%@","https://api.thingspeak.com/update?key=JAZIL40ER34BCUCC&field1=",curLat,"&field2=",curLong,"&field3=",[_speedArray lastObject],"&field4=",heartRateValue,"&field5=",[self findTheNearestTweet],"&field6=",temperatureCelcius,"&field7=",weatherDescription];
    NSURL * updateURL = [NSURL URLWithString:updateString];
    
    [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:updateURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0f] returningResponse:nil error:&error];
    
    
    // Handle any errors to avoid crashing the app
    if (error) {
        //  NSLog(@"Error: %@", error);
    }
    
}

// Location Data

// Get the users location and update the curLat and curLong values

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    _location = locations.lastObject;
    curLat = _locationManager.location.coordinate.latitude;
    curLong = _locationManager.location.coordinate.longitude;
    
    // Follow the user position unless the map is bein interacted with
    if (!mapInteraction) {
        CLLocationCoordinate2D zoomLocation;
        zoomLocation.latitude = curLat;
        zoomLocation.longitude = curLong;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomLocation, 5000, 5000);
        [_mapView setRegion:viewRegion animated:YES];
        
    }
    
    // Update the view controller labels each time the user locaiton is updated
    
    [self updateHUDLabels];
    
    
}

// Reverse Geocode the users location (No longer used in main view controller)

- (void) getLocationData {
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:_locationManager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        for (CLPlacemark * placemark in placemarks) {
            
            currentCountry = [[placemark addressDictionary] objectForKey:(NSString *)kABPersonAddressStateKey];
            currentTown = [placemark locality];
            currentRoad = [placemark thoroughfare];
            
            //NSLog(@"%@%@%@", currentRoad, currentTown, currentCountry);
        }
    }];
}


// Weather Feed

- (void)getWeatherFeed {
    
    // Request the users location for the open weather api using the users current location
    
    NSString * urlString = [NSString stringWithFormat:@"%s%f%s%f","http://api.openweathermap.org/data/2.5/weather?lat=",curLat,"&lon=",curLong];
    NSURL * url = [NSURL URLWithString:urlString];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // Request the data from the open weather api and handle any errors
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if ([data length] > 0 && error == nil)
         {
             // Received Data
             NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
             NSLog(@"Data = %@", json);
             NSMutableDictionary *temperatureResponse = [[json valueForKey:@"main"] mutableCopy];
             NSString *temperatureKelvin = [temperatureResponse valueForKey:@"temp"];
             
             // Get Weather Icon
             
             NSMutableArray *weatherResponse = [[json valueForKey:@"weather"] mutableCopy];
             NSMutableArray *weatherIconArray = [weatherResponse valueForKey:@"icon"];
             NSMutableArray *weatherDescriptionArray = [weatherResponse valueForKey:@"main"];
             NSString *weatherIcon = [weatherIconArray objectAtIndex:0];
             
             
             weatherDescription = [weatherDescriptionArray objectAtIndex:0];
             
             // Convert the temperature from degrees kelvin to celsius
             
             temperatureCelcius = [temperatureKelvin intValue] -273.15;
             
             
             //NSLog(@"%@", weatherIcon);
             
             // Download the weather indicator icon and display to the user
             
             NSString * weatherString = [NSString stringWithFormat:@"%s%@%s","http://openweathermap.org/img/w/",weatherIcon,".png"];
             
             NSURL * weatherIconUrl = [NSURL URLWithString:weatherString];
             
             //NSLog(@"Icon URL: %@", weatherIconUrl);
             
             
             NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:weatherIconUrl];
             
             //NSLog(@"Image Request URL: %@", request);
             
             [NSURLConnection sendAsynchronousRequest:request
                                                queue:[NSOperationQueue mainQueue]
                                    completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                        if ( !error )
                                        {
                                            //NSLog(@"Image Found");
                                            [_weatherIndicatorImage setImage:[UIImage imageWithData:data]];
                                            
                                            
                                        } else{
                                            
                                            //NSLog(@"Image Not Found: %@", response);
                                            [_weatherIndicatorImage setImage:[UIImage imageNamed:@"noEntry.png"]];
                                        }
                                    }];
             
         }
         else
         {
             
             
             // Error Handling , If No Connection try again in 2 seconds
             NSLog(@"Cant Get Weather!!");
             [self performSelector:@selector(getWeatherFeed) withObject:nil afterDelay:2.0];
         }
     }];
}

// Twitter Data Feed

- (void)getTwitterFeed {
    
    // Create a guest login session to the twitterkit API
    
    [[Twitter sharedInstance] logInGuestWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
        
        //Search for tweets within 5 miles of current users GPS coords
        
        // Format the url with the required parameters
        NSString *statusesShowEndpoint = [NSString stringWithFormat:@"%s%f%s%f%s","https://api.twitter.com/1.1/search/tweets.json?q=&geocode=",curLat,",",curLong,",5mi&result_type=recent"];
        
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
                     
                     
                     // Check for the number of tweets using the value of created at
                     _tweetsResponse = [[json valueForKey:@"statuses"] mutableCopy];
                     
                     
                     // Add all entries for created at to an array
                     NSArray *numberOfTweets = [_tweetsResponse valueForKey:@"created_at"];
                     // Get the Coordinates of the tweets
                     
                     NSArray *tweetLocations = [_tweetsResponse valueForKey:@"coordinates"];
                     NSArray *tweetCoordinates = [tweetLocations valueForKey:@"coordinates"];
                     NSArray *userDetails = [_tweetsResponse valueForKey:@"user"];
                     NSArray *tweeterName = [userDetails valueForKey:@"screen_name"];
                     NSArray *twitImg = [userDetails valueForKey:@"profile_image_url"];
                     NSArray *tweetID = [_tweetsResponse valueForKey:@"id"];
                     NSArray *tweetAge = [_tweetsResponse valueForKey:@"created_at"];
                     NSArray *tweetTextContent = [_tweetsResponse valueForKey:@"text"];
                     NSArray *tweetEntities = [_tweetsResponse valueForKey:@"entities"];
                     NSArray *tweetMedia = [tweetEntities valueForKey:@"media"];
                     NSArray *tweetImageContent = [tweetMedia valueForKey:@"media_url"];
                     
                     // Count the array to find the number of seperate tweets within the json feed
                     //NSLog(@"Number of Tweets: %lu", (unsigned long)[numberOfTweets count]);
                     //NSLog(@"Image URLS: %@", twitImg);
                     //NSLog(@"Tweet Names: %@ Count: %lu", tweeterName,  (unsigned long)[tweeterName count]);
                     NSLog(@"Full Twitter API: %@", json);
                     
                     
                     
                     [self performSelector:@selector(findTheNearestTweet) withObject:nil afterDelay:2.0];
                     
                     int i = 0;
                     
                     // Add tweets with their distance from current location to the dictionary
                     
                     while (i <=[numberOfTweets count]-1) {
                         
                         if ([tweetCoordinates objectAtIndex:i] == [NSNull null]) {
                             
                             //Ignore tweets with no location info
                             
                         } else {
                             
                             // Get the location of each tweet
                             NSString *tweetLon = [[tweetCoordinates objectAtIndex:i] objectAtIndex:0];
                             NSString *tweetLat = [[tweetCoordinates objectAtIndex:i] objectAtIndex:1];
                             
                             // Get the user image of the tweet
                             NSString *imgUrlString = [NSString stringWithFormat:@"%@", [twitImg objectAtIndex:i]];
                             NSURL *imgURL = [NSURL URLWithString:imgUrlString];
                             
                             NSURL *tweetMediaURL =[NSURL URLWithString:[NSString stringWithFormat:@"%@", [tweetImageContent objectAtIndex:i]]];
                             
                             // Get device location and measure distance to tweet
                             CLLocation *myLocation = [[CLLocation alloc] initWithLatitude:curLat longitude:curLong];
                             CLLocation *tweetLocation = [[CLLocation alloc] initWithLatitude:[tweetLat doubleValue] longitude:[tweetLon doubleValue]];
                             NSString *tweetDistance = [NSString stringWithFormat:@"%f", [myLocation distanceFromLocation:tweetLocation]];
                             
                             // Get the time of the tweet by parsing the string
                             
                             NSString *str = [tweetAge objectAtIndex:i];
                             NSArray *parsedTimeArray = [str componentsSeparatedByString:@" "];
                             
                             //NSLog(@"Tweeter: %@ Image URL: %@",[tweeterName objectAtIndex:i],tweetMediaURL);
                             
                             
                             // Add tweets to the map
                             tweetAnnotation *tweetEntry = [[tweetAnnotation alloc] initWithTitle:[NSString stringWithFormat:@"%@", [tweeterName objectAtIndex:i]] subtitle:[parsedTimeArray objectAtIndex:3] tweetIdentifier:[NSString stringWithFormat:@"%@", [tweetID objectAtIndex:i]] tweeterImg: imgURL tweetText: [NSString stringWithFormat:@"%@", [tweetTextContent objectAtIndex:i]] tweetImg: tweetMediaURL andCoordinate:CLLocationCoordinate2DMake([tweetLat doubleValue], [tweetLon doubleValue])];
                             [_mapView addAnnotation:tweetEntry];
                             
                             
                             [_tweetIDArray addObject:[tweetID objectAtIndex:i]];
                             [_tweetDistanceArray addObject:tweetDistance];
                         }
                         
                         i++;
                         
                     }
                     
                     
                 }
                 else {
                     
                     // Error Handling, if no twitter data is available retry in 2 seconds
                     
                     NSLog(@"Cant getTwitter");
                     [self performSelector:@selector(getTwitterFeed) withObject:nil afterDelay:2.0];
                 }
             }];
        }
        else {
            
            // Error Handling if we are unable to guest authenticate
            NSLog(@"Error: %@", clientError);
        }
        
    }];
    
    
}

-(NSString *)findTheNearestTweet {
    
    NSString *nearestTweet = [_tweetDistanceArray valueForKeyPath:@"@min.doubleValue"];
    int nearestTweetIndex = [_tweetDistanceArray indexOfObject:[NSString stringWithFormat:@"%f", [nearestTweet doubleValue]]];
    NSString *nearestTweetID = [_tweetIDArray objectAtIndex:nearestTweetIndex];
    
    return  nearestTweetID;
    
}

// Bluetooth Heart Rate Monitor

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    // Check the state of the device bluetooth
    if ([central state] == CBCentralManagerStatePoweredOff) {
        // If bluetooth is switched off, set the connection indicator to off
        [_heartrateConnected setImage:[UIImage imageNamed:@"bt_disconnected.png"]];
    }
    else if ([central state] == CBCentralManagerStatePoweredOn) {
        [centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    // Peripheral has been discovered
    
    NSUUID *localName = [peripheral name];
    // If the device peripheral is a MIO GLobal Link device then establish a connection
    if ([localName isEqual:@"MIO GLOBAL LINK"]) {
        discoveredPeripheral = peripheral;
        [centralManager connectPeripheral:peripheral options:nil];
    }
    
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {

    // Once connected to the device, set the conneciton indicator to connected
    [_heartrateConnected setImage:[UIImage imageNamed:@"bt_connected.png"]];
    
    // Stop scanning for peripheral devices
    [centralManager stopScan];
    
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    
}


- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error {
    
    // Descover the available services for the connected device
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Check if the connected device has heart rate data (Charecteristic ID 180D)
    for (CBCharacteristic *aChar in service.characteristics)
    {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]])  {
            [discoveredPeripheral setNotifyValue:YES forCharacteristic:aChar];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Call the getHeartBPMData method, each time the charecteristic is updated
    
    [self getHeartBPMData:characteristic error:error];
    
}

- (void) getHeartBPMData:(CBCharacteristic *)characteristic error:(NSError *)error
{
    // Get the Heart Rate Monitor BPM
    NSData *data = [characteristic value];
    const uint8_t *reportData = [data bytes];
    uint16_t bpm = 0;
    
    if ((reportData[0] & 0x01) == 0) {
        // Retrieve the BPM value for the Heart Rate Monitor
        bpm = reportData[1];
        
    }
    else {
        bpm = CFSwapInt16LittleToHost(*(uint16_t *)(&reportData[1]));
    }
    
    
    // Update the heart rate displays for the user and add the value to the heart rate array
    heartRate = [NSString stringWithFormat:@"%hu", bpm];
    _heartBPMSlider.currentValue = [heartRate floatValue];
    [_bpmText setText:heartRate];
    [_bpmArray addObject: heartRate];
    
}

// UX Design

- (void)updateHUDLabels {
    
    
    // Get the current speed from the location manager & convert from m/sec to mph
    speed = (int) (self.location.speed * 2.23693629);

    
    // Display the current speed reading
    [_speedText setText:[NSString stringWithFormat:@"%d", speed]];
    
    
    /* Add Speed Values to the Array*/
    
    NSNumber* speedValue = [NSNumber numberWithInt:speed]; //Convert integer to number value
    
    
    // Update the speed slider
    
    _vehichleSpeedSlider.currentValue = [speedValue floatValue];
    
    // Add speed value to the speed array
    [_speedArray addObject:speedValue];
    
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    id <MKAnnotation> annotation = [view annotation];
    
    if ([annotation isKindOfClass:[incidentAnnotation class]])
    {
        incidentAnnotation *annotation = (incidentAnnotation *) [view annotation];
        _pinTitle = [annotation title];
        _pinSubtitle = [annotation subtitle];
        _incidentTweetID = [annotation incidentTweet];
        _incidentTime = [annotation incidentTime];
        _incidentSpeed = [annotation incidentSpeed];
        _incidentBPM = [annotation incidentBPM];
        _incidentAverageBPM = [annotation incidentAverageBPM];
        _incidentLocation = [annotation coordinate];
        _incidentWeatherConditions = [annotation incidentWeatherConditions];
        _incidentTemperature = [annotation incidentTemperature];
        
        
        [self performSegueWithIdentifier:@"incidentDetails" sender: self];
        
        //NSLog(@"Nearest Tweet ID: %@", [self findTheNearestTweet]);
        
    }
    
    if ([annotation isKindOfClass:[tweetAnnotation class]])
    {
        
        tweetAnnotation *annotation = (tweetAnnotation *)[view annotation];
        _pinTitle = [annotation title];
        _pinSubtitle = [annotation subtitle];
        _pinTweetID = [annotation tweetIdentifier];
        _pinTweetTextID = [annotation tweetText];
        _pinTweetImageID = [annotation tweeterImg];
        
        // NSLog(@"%@ %@ %@ %@ %@", _pinTitle, _pinSubtitle, _pinTweetID, _pinTweetTextID, _pinTweetImageID);
        
        [self performSegueWithIdentifier:@"twitterDetails" sender: self];
        
    }
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    tweetAnnotation *annotationData = (tweetAnnotation *)annotation;
    
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[incidentAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKAnnotationView *pinView = (MKAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"incidentPin"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            
            
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"incidentPin"];
            
            pinView.canShowCallout = NO;
            pinView.image = [UIImage imageNamed:@"incident.png"];
            pinView.calloutOffset = CGPointMake(0, 32);
            
            [[pinView layer] setMasksToBounds:NO];
            [[pinView layer] setShadowColor:[UIColor blackColor].CGColor];
            [[pinView layer] setShadowOpacity:0.6f];
            [[pinView layer] setShadowRadius:6.0f];
            [[pinView layer] setShadowOffset:CGSizeMake(0, 3)];
            
            // Add a detail disclosure button to the callout.
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
            
            // Add an image to the left callout.
            UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"incident.png"]];
            pinView.leftCalloutAccessoryView = iconView;
            
            
        }
        
        return pinView;
    }
    
    if ([annotation isKindOfClass:[tweetAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKAnnotationView *pinView = nil;
        if (!pinView)
        {
            
            // Give each pin a unique identifier to prevent images from jumping between pins
            NSString *customerMarkerPinID = [NSString stringWithFormat:@"tweetPin%@",[annotationData tweetIdentifier]];
            
            // If an existing pin view was not available, create one.
            
            pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:customerMarkerPinID];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[annotationData tweeterImg]];
            
            [NSURLConnection sendAsynchronousRequest:request
                                               queue:[NSOperationQueue mainQueue]
                                   completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                       if ( !error )
                                       {
                                           //NSLog(@"Image Found");
                                           UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
                                           iconView.layer.cornerRadius = 2;
                                           iconView.clipsToBounds = YES;
                                           
                                           
                                           pinView.layer.cornerRadius = 5;
                                           pinView.layer.borderWidth = 3.0f;
                                           pinView.layer.borderColor = [UIColor whiteColor].CGColor;
                                           pinView.clipsToBounds = NO;
                                           pinView.leftCalloutAccessoryView = iconView;
                                           pinView.canShowCallout = NO;
                                           pinView.image = iconView.image;//[UIImage imageNamed:@"Twitter_logo_blue.png"];//[UIImage imageWithData:data];
                                           pinView.calloutOffset = CGPointMake(0, 10);
                                           [[pinView layer] setMasksToBounds:NO];
                                           [[pinView layer] setShadowColor:[UIColor blackColor].CGColor];
                                           [[pinView layer] setShadowOpacity:0.6f];
                                           [[pinView layer] setShadowRadius:6.0f];
                                           [[pinView layer] setShadowOffset:CGSizeMake(0, 3)];
                                           
                                           
                                           
                                       } else{
                                           //NSLog(@"Image Not Found");
                                           UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Twitter_logo_blue.png"]];
                                           pinView.leftCalloutAccessoryView = iconView;
                                           pinView.canShowCallout = YES;
                                           pinView.image = [UIImage imageNamed:@"Twitter_logo_blue.png"];
                                           pinView.calloutOffset = CGPointMake(0, 32);
                                           
                                       }
                                   }];
            
            
            
            
            
            // Add a detail disclosure button to the callout.
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
            
            
            
        }
        
        return pinView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView1 didSelectAnnotationView:(MKAnnotationView *)view
{
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[tweetAnnotation class]])
    {
        
        tweetAnnotation *annotation = (tweetAnnotation *)[view annotation];
        _pinTitle = [annotation title];
        _pinSubtitle = [annotation subtitle];
        _pinTweetID = [annotation tweetIdentifier];
        _pinTweetTextID = [annotation tweetText];
        _pinTweetImageID = [annotation tweeterImg];
        
        // NSLog(@"%@ %@ %@ %@ %@", _pinTitle, _pinSubtitle, _pinTweetID, _pinTweetTextID, _pinTweetImageID);
        
        [self performSegueWithIdentifier:@"twitterDetails" sender: self];
    }
    if ([annotation isKindOfClass:[incidentAnnotation class]])
    {
        incidentAnnotation *annotation = (incidentAnnotation *) [view annotation];
        _pinTitle = [annotation title];
        _pinSubtitle = [annotation subtitle];
        _incidentTweetID = [annotation incidentTweet];
        _incidentTime = [annotation incidentTime];
        _incidentSpeed = [annotation incidentSpeed];
        _incidentBPM = [annotation incidentBPM];
        _incidentAverageBPM = [annotation incidentAverageBPM];
        _incidentLocation = [annotation coordinate];
        _incidentWeatherConditions = [annotation incidentWeatherConditions];
        _incidentTemperature = [annotation incidentTemperature];
        
        
        [self performSegueWithIdentifier:@"incidentDetails" sender: self];
        
        //NSLog(@"Nearest Tweet ID: %@", [self findTheNearestTweet]);
        
    }
    
    
    
}

// Detect if the mapView has been moved from the current user location

- (BOOL)mapViewRegionDidChangeFromUserInteraction
{
    UIView *view = self.mapView.subviews.firstObject;
    //  Look through gesture recognizers to determine whether this region change is from user interaction
    for(UIGestureRecognizer *recognizer in view.gestureRecognizers) {
        if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
            return YES;
        }
    }
    
    return NO;
}

static BOOL mapChangedFromUserInteraction = NO;

// If the mapView has moved, delay for 10 seconds before retruning to allow for user to view tweets / incidents

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    mapChangedFromUserInteraction = [self mapViewRegionDidChangeFromUserInteraction];
    
    if (mapChangedFromUserInteraction) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(mapUserInteractionComplete) object:nil];
        // NSLog(@"User is using the map!");
        mapInteraction = YES;
        [self performSelector:@selector(mapUserInteractionComplete) withObject:nil afterDelay:10.0];
    }
}

// Reset the map interaction bool

-(void) mapUserInteractionComplete {
    mapInteraction = NO;
}


// Trigger an incident

- (IBAction)recordIncident:(id)sender {
    
    [self sendUpdateToThingSpeak];
    
}

// Refresh the data feeds when the user hits the refresh button
- (IBAction)refreshDataFeeds:(id)sender {
    [_mapView removeAnnotations:_mapView.annotations];
    [self getWeatherFeed];
    [self getTwitterFeed];
    [self getThingSpeakData];
    
}

-(void) refreshFeeds {
    [_mapView removeAnnotations:_mapView.annotations];
    [self getWeatherFeed];
    [self getTwitterFeed];
    [self getThingSpeakData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"twitterDetails"]) {
        
        // Send the required values through to the twitter view controller
        twitterDetails *twitterView = [segue destinationViewController];
        twitterView.titleText = _pinTitle;
        
        twitterView.subTitleText = _pinSubtitle;
        twitterView.tweetID = _pinTweetID;
        twitterView.tweetTextID = _pinTweetTextID;
        twitterView.tweetMediaID = _pinTweetImageID;
        
    }
    if ([[segue identifier] isEqualToString:@"incidentDetails"]) {
        
        // Send the required values through to the incident view controller
        IncidentDetails *incidentView = [segue destinationViewController];
        incidentView.incidentTitle = _pinTitle;
        incidentView.incidentTime = _incidentTime;
        incidentView.incidentDate = _pinSubtitle;
        incidentView.incidentSpeed = _incidentSpeed;
        incidentView.nearestTweet = _incidentTweetID;
        incidentView.incidentBPM = _incidentBPM;
        incidentView.incidentAverageBPM = _incidentAverageBPM;
        incidentView.incidentLocation = _incidentLocation;
        incidentView.incidentTemperature = _incidentTemperature;
        incidentView.incidentWeatherCond = _incidentWeatherConditions;
        
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.hyr
}

@end
