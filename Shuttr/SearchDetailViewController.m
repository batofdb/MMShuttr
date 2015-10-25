//
//  SearchDetailViewController.m
//  Shuttr
//
//  Created by Philip Henson on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "SearchDetailViewController.h"
#import "ImageProcessing.h"
#import "UIImage+ImageResizing.h"
#import "Activity.h"
#import "Post.h"

@interface SearchDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *postsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (nonatomic) Activity *followActivity;

@end

@implementation SearchDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self populateView];

}

- (void)populateView {
    [self getUserProperties];

    self.followActivity = [Activity new];
    [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    [self.followButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

    // Get user posts
    PFQuery *queryPosts = [Post query];
    [queryPosts whereKey:@"user" equalTo:self.user];
    [queryPosts findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSArray *userPosts = [NSArray arrayWithArray:objects];
        self.postsCountLabel.text = [NSString stringWithFormat:@"Posts: %lu", userPosts.count];
    }];

    PFQuery *fromQuery = [Activity query];
    [fromQuery whereKey:@"fromUser" equalTo:self.user];

    PFQuery *toQuery = [Activity query];
    [toQuery whereKey:@"toUser" equalTo:self.user];

    PFQuery *activityQuery = [PFQuery orQueryWithSubqueries:@[toQuery, fromQuery]];
    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        NSMutableArray *userLikes = [NSMutableArray new];
        NSMutableArray *userFollowers = [NSMutableArray new];
        NSMutableArray *userFollowing = [NSMutableArray new];

        for (Activity *activity in objects){
            if ([activity.activityType  isEqual:@0] && [activity.toUser isEqual:self.user]){
                [userLikes addObject:activity];
            } else if ([activity.activityType  isEqual:@2] && [activity.toUser isEqual:self.user]) {
                [userFollowers addObject:activity];
            } else if ([activity.activityType  isEqual:@2] && [activity.fromUser isEqual:self.user]) {
                [userFollowing addObject:activity];
            }

            if ([activity.activityType isEqual:@2] && [activity.fromUser isEqual:[User currentUser]] && [activity.toUser isEqual:self.user]) {
                [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
                [self.followButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                self.followActivity = activity;
            }
        }

        self.likesCountLabel.text = [NSString stringWithFormat:@"Likes: %lu", userLikes.count];
        self.followersCountLabel.text = [NSString stringWithFormat:@"%lu Followers", userFollowers.count];
        self.followingCountLabel.text = [NSString stringWithFormat:@"%lu Following", userFollowing.count];
    }];

}

- (void)getUserProperties {

    // Get username
    self.usernameLabel.text = self.user.username;

    // Get full name
    self.fullNameLabel.text = self.user.fullName;

    // Get profile pic
    UIImage *profilePicture =[UIImage imageWithImage:[ImageProcessing getImageFromData:self.user.profilePicture] scaledToSize:CGSizeMake(self.profileImageView.frame.size.width, self.profileImageView.frame.size.height)] ;

    self.profileImageView.image = profilePicture;
}

- (IBAction)onFollowButtonPressed:(UIButton *)sender {

    if ([self.followButton.titleLabel.text isEqualToString:@"Follow"]){
        [self.followButton setTitle:@"Following" forState:UIControlStateNormal];
        [self.followButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];

        Activity *activity = [Activity new];
        activity.toUser = self.user;
        activity.fromUser = [User currentUser];
        activity.activityType = @2;
        [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self populateView];

        }];


    } else {
        [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
        [self.followButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.followActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self populateView];
        }];

    }


}



@end
