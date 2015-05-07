//
//  tweetAnnotation.m
//  socialTraffic
//
//  Created by Gareth Day on 11/04/2015.
//  Copyright (c) 2015 Gareth Day. All rights reserved.
//

#import "tweetAnnotation.h"

@implementation tweetAnnotation

@synthesize tweetIdentifier, title, subtitle, coordinate, tweeterImg, tweetMedia, tweetText;

-(id) initWithTitle: (NSString *)header subtitle:(NSString *) subtitles tweetIdentifier:(NSString *)tweetyID tweeterImg: (NSURL *)tweetImg tweetText: (NSString *)tweetTextContent tweetImg: (NSURL *)tweetImageContent andCoordinate: (CLLocationCoordinate2D)Coord2D {
    
    title = header;
    subtitle = subtitles;
    coordinate = Coord2D;
    tweetIdentifier = tweetyID;
    tweeterImg = tweetImg;
    tweetText = tweetTextContent;
    tweetMedia = tweetImageContent;
    
    
    return  self;
}


@end
