//
//  twitterDetails.h
//  socialTraffic
//
//  Created by Gareth Day on 19/04/2015.
//  Copyright (c) 2015 Gareth Day. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface twitterDetails : UIViewController {
    
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) NSString *titleText;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) NSString *subTitleText;
@property (weak, nonatomic) NSString *tweetID;
@property (weak, nonatomic) NSString *tweetTextID;
@property (weak, nonatomic) NSURL *tweetMediaID;



- (IBAction)dismissView:(id)sender;

@end
