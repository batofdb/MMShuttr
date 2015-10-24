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

    // TODO: refactor this
    // Get user posts
    PFQuery *queryPosts = [Post query];
    [queryPosts whereKey:@"user" equalTo:user];
    NSArray *userPosts = [queryPosts findObjects];
    self.postsCountLabel.text = [NSString stringWithFormat:@"Posts: %lu", userPosts.count];

    // Get likes to users content
    PFQuery *queryLikes = [Activity query];
    [queryLikes whereKey:@"toUser" equalTo:user];
    NSArray *userLikes = [queryLikes findObjects];
    self.likesCountLabel.text = [NSString stringWithFormat:@"Likes: %lu", userLikes.count];

    // Get followers
    PFQuery *queryFollowers = [Activity query];
    [queryFollowers whereKey:@"toUser" equalTo:user];
    NSArray *userFollowers = [queryLikes findObjects];
    self.followersCountLabel.text = [NSString stringWithFormat:@"%lu Followers", (unsigned long)userFollowers.count];

    // Get following
    PFQuery *queryFollowing = [Activity query];
    [queryFollowing whereKey:@"fromUser" equalTo:user];
    NSArray *userFollowing = [queryLikes findObjects];
    self.followingCountLabel.text = [NSString stringWithFormat:@"%lu Following", (unsigned long)userFollowing.count];

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
