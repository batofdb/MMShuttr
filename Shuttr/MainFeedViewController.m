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


    // Test User
    [User logInWithUsernameInBackground:@"phil" password:@"hen"];


//    User *user = [User currentUser];
//
//    if (!user){
//        [User logInWithUsernameInBackground:@"admin" password:@"password"];
//    }

//    simulate activity

//    PFQuery *query = [Post query];
//    Post *testPost = [[query findObjects] firstObject];
//
//    Activity *testLikeActivity = [Activity new];
//    Activity *testFollowActivity = [Activity new];
//
//    testLikeActivity.activityType = @0;
//    testLikeActivity.toUser = testPost.author;
//    testLikeActivity.fromUser = [User currentUser];
//    testLikeActivity.post = testPost;
//
//    testFollowActivity.activityType = @2;
//    testFollowActivity.toUser = testPost.author;
//    testFollowActivity.fromUser = [User currentUser];
//
//    [testLikeActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//
//
//    }];
//
//    [testFollowActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//
//
//    }];


    

}


@end
