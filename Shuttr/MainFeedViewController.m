//
//  MainFeedViewController.m
//  Shuttr
//
//  Created by Lin Wei on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "MainFeedViewController.h"
#import "User.h"
#import "ImageProcessing.h"
#import "Activity.h"

@interface MainFeedViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation MainFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

        User *user = [User currentUser];
    
        if (!user){
            [User logInWithUsernameInBackground:@"phil" password:@"hen"];
        }

}


@end
