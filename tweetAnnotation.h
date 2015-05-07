//
//  customAnno.h
//  socialTraffic
//
//  Created by Gareth Day on 11/04/2015.
//  Copyright (c) 2015 Gareth Day. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface tweetAnnotation : NSObject <MKAnnotation> {
    
    NSString * title;
    NSString * subtitle;
    NSString *tweetIdentifier;
    NSString *tweetText;
    NSURL *tweetMedia;
    NSURL *tweeterImg;
    CLLocationCoordinate2D coordinate;
    
}

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSString * subtitle;
@property (nonatomic, copy) NSString *tweetIdentifier;
@property (nonatomic, copy) NSString *tweetText;
@property (nonatomic, copy) NSURL *tweetMedia;
@property (nonatomic, copy) NSURL *tweeterImg;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

-(id) initWithTitle: (NSString *)header subtitle:(NSString *) subtitles tweetIdentifier:(NSString *)tweetyID tweeterImg: (NSURL *)tweetImg tweetText: (NSString *)tweetTextContent tweetImg: (NSURL *)tweetImageContent andCoordinate: (CLLocationCoordinate2D)Coord2D;

@end
