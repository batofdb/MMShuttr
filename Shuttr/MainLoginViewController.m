//
//  MainLoginViewController.m
//  Shuttr
//
//  Created by Philip Henson on 10/25/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "MainLoginViewController.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import <ParseUI/ParseUI.h>
#import "User.h"
#import <AVFoundation/AVFoundation.h>
#import "CustomMovieView.h"

@interface MainLoginViewController () <SignInDelegate, SignUpDelegate>

@property (nonatomic) AVPlayer *avPlayer;
@property (nonatomic) AVPlayerLayer *avLayer;
@property (weak, nonatomic) IBOutlet CustomMovieView *customMovieView;

@end

@implementation MainLoginViewController


- (void)viewWillAppear:(BOOL)animated {
    self.customMovieView.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add movie animation here
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"filmSceneb" ofType:@"mp4"];
    NSURL *fileURL = [NSURL fileURLWithPath:filepath];
    self.avPlayer = [AVPlayer playerWithURL:fileURL];
    self.avLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    self.avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [self.customMovieView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.avPlayer currentItem]];

    self.avLayer.frame = CGRectMake(0, 0, self.customMovieView.bounds.size.width, self.customMovieView.bounds.size.height);
    [self.customMovieView.layer addSublayer: self.avLayer];
    [self.avPlayer play];


}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];

    [self.customMovieView removeFromSuperview];

    // [self.avPlayer play];
    // Log in user if a current user exists
    if ([PFUser currentUser]) {
        [self performSegueWithIdentifier:@"toMainFeedSegueWithoutLogin" sender:self];
    }
}

-(void)cancelButtonPressedFromSignIn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)cancelButtonPressedFromSignUp:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToSignUpSegue"]) {
        SignUpViewController *vc = segue.destinationViewController;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ToSignInSegue"]) {
        SignInViewController *vc = segue.destinationViewController;
        vc.delegate = self;
    }
}

@end
