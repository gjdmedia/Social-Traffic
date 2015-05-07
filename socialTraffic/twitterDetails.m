//
//  twitterDetails.m
//  socialTraffic
//
//  Created by Gareth Day on 19/04/2015.
//  Copyright (c) 2015 Gareth Day. All rights reserved.
//

#import "twitterDetails.h"
#import <TwitterKit/TwitterKit.h>

@interface twitterDetails ()

@end

@implementation twitterDetails

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   NSLog(@"Twitter Details");
    
    float screenWidth = [[UIScreen mainScreen] bounds].size.width;
    
    
    [[Twitter sharedInstance] logInGuestWithCompletion:^(TWTRGuestSession *guestSession, NSError *error) {
        [[[Twitter sharedInstance] APIClient] loadTweetWithID:_tweetID completion:^(TWTRTweet *tweet, NSError *error) {
            TWTRTweetView *tweetView = [[TWTRTweetView alloc] initWithTweet:tweet style:TWTRTweetViewStyleCompact];
            [TWTRTweetView appearance].theme = TWTRTweetViewThemeDark;
            CGSize desiredSize = [tweetView sizeThatFits:CGSizeMake(screenWidth, CGFLOAT_MAX)];
            tweetView.frame = CGRectMake(0, 20, screenWidth, desiredSize.height);
            [self.view addSubview:tweetView];
        }];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
