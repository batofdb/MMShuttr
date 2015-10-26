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

@interface MainLoginViewController () <SignInDelegate, SignUpDelegate>

@end

@implementation MainLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


-(void)cancelButtonPressedFromSignIn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)cancelButtonPressedFromSignUp:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
