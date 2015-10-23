//
//  MainFeedViewController.m
//  Shuttr
//
//  Created by Lin Wei on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "MainFeedViewController.h"
#import "User.h"

@interface MainFeedViewController ()

@end

@implementation MainFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // We have one test user for now
    [PFUser logInWithUsername:@"admin" password:@"password"];

    // Call this anywhere in the code to get a reference to our test user
    PFUser *user = [PFUser currentUser];
    
}


@end
