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
#import "MainFeedViewController.h"
#import "PostPhotosViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface ProfileViewController () <EditProfileDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PostDetailDelegate, MainFeedDelegate>
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

    // Set the delegate so can update when main feed is updated
    MainFeedViewController *vc = [self.tabBarController.viewControllers objectAtIndex:0];
    vc.delegate = self;

    //[self queryAndPopulateView];
    //[self.collectionView reloadData];
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.clipsToBounds = YES;
    [self queryAndPopulateView];

}



- (void) viewWillAppear:(BOOL)animated {
    // TODO: optimise navigation so this doesn't have to get called every time the view appears
    //[self.collectionView reloadData];

    //[self postsChanged];
}

//- (void)postsChanged {
//
//    PFQuery *queryPosts = [Post query];
//    [queryPosts whereKey:@"author" equalTo:[User currentUser]];
//    [queryPosts findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//        if (objects){
//            if (!(self.userPosts.count == objects.count)){
//                [self queryAndPopulateView];
//            } else {
//                NSSet *set1=[NSSet setWithArray:objects];
//                NSSet *set2=[NSSet setWithArray:self.userPosts];
//                    if (![set1 isEqualToSet:set2]) {
//                        [self queryAndPopulateView];
//                    }
//            }
//        }
//    }];
//
//}

#pragma mark - Main Feed Delegate Methods
-(void)postWasChanged:(id)sender {
    [self queryAndPopulateView];
}

#pragma mark - Helper Methods
- (void) queryAndPopulateView {
    [self.view setUserInteractionEnabled:NO];
    User *user = [User currentUser];
    
    [self getUserProperties];
    self.rollCoverImages = [NSMutableArray new];
    self.userPosts = [NSMutableArray new];

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
                [SVProgressHUD dismiss];
        self.likesCountLabel.text = [NSString stringWithFormat:@"%lu", userLikes.count];
        self.followersCountLabel.text = [NSString stringWithFormat:@"%lu Followers", userFollowers.count];
        self.followingCountLabel.text = [NSString stringWithFormat:@"%lu Following", userFollowing.count];
            [self.view setUserInteractionEnabled:YES];
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
    //[self performSelectorOnMainThread:@selector(getUserProperties) withObject:nil waitUntilDone:YES];
    [self getUserProperties];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)editCancelled:(id)view {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Post Detail Delegate Methods
- (void)postWasDeleted:(id)view {
    [self queryAndPopulateView];
}

- (void)postWasChangedOnDetail:(id)sender {
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
