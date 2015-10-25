//
//  SearchDetailViewController.m
//  Shuttr
//
//  Created by Philip Henson on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "SearchDetailViewController.h"
#import "PostCollectionViewCell.h"
#import "ImageProcessing.h"
#import "UIImage+ImageResizing.h"
#import "PostDetailViewController.h"
#import "Activity.h"
#import "Post.h"

@interface SearchDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *postsCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (nonatomic) Activity *followActivity;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSMutableArray *rollCoverImages;
@property (nonatomic) NSArray *userPosts;

@end

@implementation SearchDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self populateView];
    [self.collectionView reloadData];

}

- (void)viewWillAppear:(BOOL)animated {
    [self checkSender];
}

- (void)populateView {
    [self getUserProperties];
    self.rollCoverImages = [NSMutableArray new];
    self.userPosts = [NSMutableArray new];

    self.followActivity = [Activity object];
    [self.followButton setTitle:@"Follow" forState:UIControlStateNormal];
    [self.followButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

    // Get user posts
    PFQuery *queryPosts = [Post query];
    [queryPosts whereKey:@"author" equalTo:self.user];
    [queryPosts findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        NSArray *userPosts = [NSArray arrayWithArray:objects];
        self.userPosts = [NSArray arrayWithArray:objects];
        self.postsCountLabel.text = [NSString stringWithFormat:@"Posts: %lu", userPosts.count];

        for (Post *post in self.userPosts) {
            [self.rollCoverImages addObject:[ImageProcessing getImageFromData:[post.roll firstObject]]];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });


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

- (void)checkSender {
    if (self.sourceVC){
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        navBar.backgroundColor = [UIColor whiteColor];

        UINavigationItem *navItem = [[UINavigationItem alloc] init];
        navItem.title = @"User Profile";

        UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(onDoneButtonPressed:)];
        navItem.rightBarButtonItem = rightButton;
        
        navBar.items = @[ navItem ];
        
        [self.view addSubview:navBar];
    }
}

- (void)onDoneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma mark - UICollectionView Delegate Methods
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];

    cell.imageView.image = [self.rollCoverImages objectAtIndex:indexPath.row];

    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.rollCoverImages.count;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    [self performSegueWithIdentifier:@"ToPostDetailSegue" sender:indexPath];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToPostDetailSegue"]) {
        PostDetailViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = sender;
        vc.post = [self.userPosts objectAtIndex:indexPath.row];
    }
}



@end
