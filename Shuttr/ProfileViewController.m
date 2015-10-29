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
#import "PostCollectionViewCell.h"
#import "PostDetailViewController.h"
#import "SVProgressHUD.h"
#import "PostPhotosViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ProfileViewController () <EditProfileDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PostDetailDelegate>
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *postsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSMutableArray *rollCoverImages;
@property (nonatomic) NSArray *userPosts;


@end

@implementation ProfileViewController


#pragma mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];

    [self queryAndPopulateView];
    [self.collectionView reloadData];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.clipsToBounds = YES;

}

- (void) viewWillAppear:(BOOL)animated {

    // TODO: optimise navigation so this doesn't have to get called every time the view appears
    [self queryAndPopulateView];
    [self.collectionView reloadData];
}

#pragma mark - Helper Methods
- (void) queryAndPopulateView {

    User *user = [User currentUser];
    self.rollCoverImages = [NSMutableArray new];
    self.userPosts = [NSMutableArray new];

    [self getUserProperties];

    // TODO: possible refactor opportunities here
    // Get user posts
    [SVProgressHUD show];
    PFQuery *queryPosts = [Post query];
    [queryPosts whereKey:@"author" equalTo:user];
    [queryPosts findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.userPosts = [NSArray arrayWithArray:objects];
        self.postsCountLabel.text = [NSString stringWithFormat:@"%lu", self.userPosts.count];

        for (Post *post in self.userPosts) {
            [self.rollCoverImages addObject:[ImageProcessing getImageFromData:[post.roll firstObject]]];
        }

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
            dispatch_async(dispatch_get_main_queue(), ^{

                self.likesCountLabel.text = [NSString stringWithFormat:@"%lu", userLikes.count];
                self.followersCountLabel.text = [NSString stringWithFormat:@"%lu Followers", userFollowers.count];
                self.followingCountLabel.text = [NSString stringWithFormat:@"%lu Following", userFollowing.count];
                [SVProgressHUD dismiss];

                [self.collectionView reloadData];
            });
        }];

    }];


}

- (void)getUserProperties {

    User *user = [User currentUser];
    // Get username
    self.usernameLabel.text = user.username;

    // Get full name
    self.fullNameLabel.text = user.fullName;

    // Get profile pic
    UIImage *profilePicture =[ImageProcessing getImageFromData:user.profilePicture] ;
    [self.profileImageView setImage:profilePicture];

}

#pragma mark - UICollectionView Delegate Methods
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    UIImage *cellImage = [self.rollCoverImages objectAtIndex:indexPath.row];

    cell.imageView.image = cellImage;

    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.rollCoverImages.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"ToPostDetailSegue" sender:indexPath];
}

#pragma mark - Edit Profile Delegate Method Implementation
- (void)profileWasChanged:(id)view {
    [self performSelectorOnMainThread:@selector(getUserProperties) withObject:nil waitUntilDone:YES];
   // [self getUserProperties];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)editCancelled:(id)view {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postWasDeleted:(id)view {
    [self queryAndPopulateView];
}



#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ToEditProfileSegue"]) {
    EditProfileViewController *vc = segue.destinationViewController;
    vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"ToPostDetailSegue"]) {
        PostDetailViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        vc.post = [self.userPosts objectAtIndex:indexPath.row];
        vc.delegate = self;
    }
}



@end
