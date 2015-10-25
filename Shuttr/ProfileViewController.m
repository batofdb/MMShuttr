//
//  ProfileViewController.m
//  Shuttr
//
//  Created by Philip Henson on 10/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "ProfileViewController.h"
#import "User.h"
#import "Post.h"
#import "Activity.h"
#import "ImageProcessing.h"
#import "EditProfileViewController.h"
#import "UIImage+ImageResizing.h"

@interface ProfileViewController () <EditProfileDelegate>
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *postsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;

@end

@implementation ProfileViewController\

//TODO: implement Feed View here, but just include photo reels taken by the user

- (void)viewDidLoad {
    [super viewDidLoad];

    [self queryAndPopulateView];
}

- (void) queryAndPopulateView {

    User *user = [User currentUser];
    [self getUserProperties];

    // TODO: possible refactor opportunities here
    // Get user posts
    PFQuery *queryPosts = [Post query];
    [queryPosts whereKey:@"user" equalTo:user];
    [queryPosts findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSArray *userPosts = [NSArray arrayWithArray:objects];
        self.postsCountLabel.text = [NSString stringWithFormat:@"Posts: %lu", userPosts.count];
    }];

    PFQuery *fromQuery = [Activity query];
    [fromQuery whereKey:@"fromUser" equalTo:user];

    PFQuery *toQuery = [Activity query];
    [toQuery whereKey:@"toUser" equalTo:user];

    PFQuery *activityQuery = [PFQuery orQueryWithSubqueries:@[toQuery, fromQuery]];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        NSMutableArray *userLikes = [NSMutableArray new];
        NSMutableArray *userFollowers = [NSMutableArray new];
        NSMutableArray *userFollowing = [NSMutableArray new];

        for (Activity *activity in objects){
            if ([activity.activityType  isEqual:@0] && [activity.toUser isEqual:user]){
                [userLikes addObject:activity];
            } else if ([activity.activityType  isEqual:@2] && [activity.toUser isEqual:user]) {
                [userFollowers addObject:activity];
            }else if ([activity.activityType  isEqual:@2] && [activity.fromUser isEqual:user]) {
                [userFollowing addObject:activity];
            }
        }

        self.likesCountLabel.text = [NSString stringWithFormat:@"Likes: %lu", userLikes.count];
        self.followersCountLabel.text = [NSString stringWithFormat:@"%lu Followers", userFollowers.count];
        self.followingCountLabel.text = [NSString stringWithFormat:@"%lu Following", userFollowing.count];
    }];


    }

- (void)getUserProperties {

    User *user = [User currentUser];
    // Get username
    self.usernameLabel.text = user.username;

    // Get full name
    self.fullNameLabel.text = user.fullName;

    // Get profile pic
    UIImage *profilePicture =[UIImage imageWithImage:[ImageProcessing getImageFromData:user.profilePicture] scaledToSize:CGSizeMake(self.profileImageView.frame.size.width, self.profileImageView.frame.size.height)] ;
    
    self.profileImageView.image = profilePicture;
}

- (void)profileWasChanged:(id)view {
    [self getUserProperties];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)editCancelled:(id)view {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    EditProfileViewController *vc = segue.destinationViewController;
    vc.user = [User currentUser];
    vc.delegate = self;

}



@end
