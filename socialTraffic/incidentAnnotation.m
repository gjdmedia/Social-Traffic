//
//  incidentAnnotation.m
//  socialTraffic
//
//  Created by Gareth Day on 19/04/2015.
//  Copyright (c) 2015 Gareth Day. All rights reserved.
//

#import "incidentAnnotation.h"

@implementation incidentAnnotation

@synthesize title, subtitle,incidentTweet, incidentTime, incidentAverageBPM, incidentBPM, incidentSpeed, incidentTemperature, incidentWeatherConditions, coordinate;


-(id) initWithTitle: (NSString *)header subtitle:(NSString *) subtitles tweetIdentifier:(NSString *)tweetyID incidentTime: (NSString *)time incidentSpeed: (NSString *)speed incidentBPM: (NSString *)bpm incidentAverageBPM: (NSString *)avBpm incidentTemperature: (NSString *)temperature incidentWeatherConditions: (NSString *)conditions andCoordinate: (CLLocationCoordinate2D)Coord2D {
    
    title = header;
    subtitle = subtitles;
    coordinate = Coord2D;
    incidentTweet = tweetyID;
    incidentTime = time;
    incidentSpeed = speed;
    incidentBPM = bpm;
    incidentAverageBPM = avBpm;
    incidentTemperature = temperature;
    incidentWeatherConditions = conditions;
    
    return  self;
}

@end
