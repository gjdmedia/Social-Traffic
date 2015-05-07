//
//  incidentAnnotation.h
//  socialTraffic
//
//  Created by Gareth Day on 19/04/2015.
//  Copyright (c) 2015 Gareth Day. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface incidentAnnotation : NSObject <MKAnnotation> {
    NSString * title;
    NSString * subtitle;
    NSString * incidentTweet;
    NSString * incidentTime;
    NSString * incidentSpeed;
    NSString * incidentBPM;
    NSString * incidentAverageBPM;
    NSString * incidentTemperature;
    NSString * incidentWeatherConditions;
    
    
    CLLocationCoordinate2D coordinate;
}


@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, copy) NSString * incidentTweet;
@property (nonatomic, copy) NSString * incidentTime;
@property (nonatomic, copy) NSString * incidentSpeed;
@property (nonatomic, copy) NSString * incidentBPM;
@property (nonatomic, copy) NSString * incidentAverageBPM;
@property (nonatomic, copy) NSString * incidentTemperature;
@property (nonatomic, copy) NSString * incidentWeatherConditions;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id) initWithTitle: (NSString *)header subtitle:(NSString *) subtitles tweetIdentifier:(NSString *)tweetyID incidentTime: (NSString *)time incidentSpeed: (NSString *)speed incidentBPM: (NSString *)bpm incidentAverageBPM: (NSString *)avBpm incidentTemperature: (NSString *)temperature incidentWeatherConditions: (NSString *)conidtions andCoordinate: (CLLocationCoordinate2D)Coord2D;

@end
