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

@interface MainLoginViewController () <SignInDelegate, SignUpDelegate>

@end

@implementation MainLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
