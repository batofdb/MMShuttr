//
//  MainFeedViewController.m
//  Shuttr
//
//  Created by Lin Wei on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "MainFeedViewController.h"
#import "User.h"
#import "FeedTableViewCell.h"
#import "ImageProcessing.h"
#import "Activity.h"
#import "FeedTableFooterCellView.h"
#import "FeedTableHeaderView.h"
#import "SearchDetailViewController.h"
#import "ImageProcessing.h"
#import "SVProgressHUD.h"
#import "PostDetailViewController.h"
#import "CameraViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "RefreshControlView.h"

@interface MainFeedViewController () <UITableViewDataSource, UITableViewDelegate, FeedTableHeaderDelegate, FeedTableFooterCellDelegate, CameraViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property (nonatomic) NSArray *objects;
@property (nonatomic) NSArray *feedPosts;
@property (nonatomic) NSArray *likesArray;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) UIImageView *logoSpinner;
@property (nonatomic) NSMutableArray *imageB;
@end

@implementation MainFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.somethingChanged = NO;

    [self.tabBarItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self setNeedsStatusBarAppearanceUpdate];
    self.imageB = [NSMutableArray new];

    for (int i = 1; i <37; i++) {
        NSString *imageName = [NSString stringWithFormat:@"LogoLoginStart%d",i];
        [self.imageB addObject:[UIImage imageNamed:imageName]];
    }

    // Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor clearColor];
    self.refreshControl.tintColor = [UIColor clearColor];
    [self.refreshControl addTarget:self
                            action:@selector(pullToRefreshAction)
                  forControlEvents:UIControlEventValueChanged];
    [self.feedTableView addSubview:self.refreshControl];
    [self loadCustomRefreshContents];

    [self.feedTableView registerClass:[FeedTableViewCell class] forCellReuseIdentifier:@"FeedTableViewCell"];

    CameraViewController *vc = [self.tabBarController.viewControllers objectAtIndex:1];
    vc.delegate = self;
    self.view.backgroundColor = UIColorFromRGB(0x533E54);
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(0x533E54);

    //[self getAllPosts];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // TODO: add code here to requery under cetrain conditions
    [SVProgressHUD show];
    [self getAllPosts];

//    if (self.somethingChanged){
//        self.somethingChanged = NO;
//        [self getAllPosts];
//    }
}


-(void)updateFeedForNewPost:(id)sender {
  //  [self getAllPosts];
    [self.delegate postWasChanged:self];
}

- (void)pullToRefreshAction {
    [self startAnimatingLogo];
    [self getAllPosts];

}

- (void)getAllPosts {
    [self.view setUserInteractionEnabled:NO];
    PFQuery *query = [self queryForPosts];
    PFQuery *likesActivityQuery = [self queryForUserLikeActivity];
    self.feedPosts = [NSArray new];
    self.likesArray = [NSArray new];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {


        self.feedPosts = [[NSArray alloc] initWithArray:objects];

        [likesActivityQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

            NSArray *allUserLikesActivity= [[NSArray alloc] initWithArray:objects];
            NSMutableArray *allUserLikedPosts = [NSMutableArray new];
            for (Activity *activity in allUserLikesActivity){
                [allUserLikedPosts addObject:activity.post];
            }
            NSMutableArray *resultLikes = [[NSMutableArray alloc]initWithCapacity:[self.feedPosts count]];

            for (Post *post in self.feedPosts){
                if ([allUserLikedPosts containsObject:post]) {
                    [resultLikes addObject:@1];
                } else {
                    [resultLikes addObject:@0];
                }
            }
            self.likesArray = [[NSArray alloc] initWithArray:resultLikes];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.feedTableView reloadData];
                [self.logoSpinner stopAnimating];
                [self.view setUserInteractionEnabled:YES];
                [self.refreshControl endRefreshing];
                [SVProgressHUD dismiss];
            });
            
        }];

    }];


}

- (void)startAnimatingLogo{
    self.logoSpinner.animationImages = self.imageB;
    self.logoSpinner.animationDuration = 1;
    self.logoSpinner.animationRepeatCount = 0;
    [self.logoSpinner startAnimating];
}


- (void)loadCustomRefreshContents {
    RefreshControlView *refreshView = [[NSBundle mainBundle] loadNibNamed:@"RefreshControlView" owner:self options:nil].firstObject;
    self.logoSpinner = refreshView.logoSpinner;
    refreshView.frame = self.refreshControl.bounds;
    //self.logoSpinner.image = (UIImage *)[refreshView viewWithTag:0];
    [self.refreshControl addSubview:refreshView];
}

- (PFQuery *)queryForPosts {

//    // Get activity from followers
    PFQuery *followingActivityQuery = [Activity query];
    [followingActivityQuery whereKey:@"activityType" equalTo:@2];
    [followingActivityQuery whereKey:@"fromUser" equalTo:[User currentUser]];

    // Get posts from those activities
    PFQuery *photosFromFollowedUsersQuery = [Post query];
    [photosFromFollowedUsersQuery whereKey:@"author" matchesKey:@"toUser" inQuery:followingActivityQuery];
    [photosFromFollowedUsersQuery whereKeyExists:@"roll"];

    // Also want user's photos
    PFQuery *photosFromCurrentUserQuery = [Post query];
    [photosFromCurrentUserQuery whereKey:@"author" equalTo:[User currentUser]];
    [photosFromCurrentUserQuery whereKeyExists:@"roll"];

    // Combine queries
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[photosFromFollowedUsersQuery, photosFromCurrentUserQuery]];
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];

    return query;

}

- (PFQuery *)queryForUserLikeActivity {
    // Get user likes
    PFQuery *userLikesQuery = [Activity query];
    [userLikesQuery whereKey:@"activityType" equalTo:@0];
    [userLikesQuery whereKey:@"fromUser" equalTo:[User currentUser]];
    [userLikesQuery whereKeyExists:@"post"];
    [userLikesQuery whereKeyExists:@"toUser"];

    return userLikesQuery;
}



// ORIGINAL getAllPosts
//- (void)getAllPosts {
//    PFQuery *allPosts = [PFQuery queryWithClassName:@"Post"];
//    [allPosts includeKey:@"author"];
//    // Change the following for different feed results
//    allPosts.limit = 10;
//    [allPosts includeKey:@"updatedAt"];
//    [allPosts orderByDescending:@"updatedAt"];
//
//    [SVProgressHUD show];
//    [allPosts findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//        if (objects.count > 0) {
//            self.feedPosts = objects;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss];
//                [self.feedTableView reloadData];
//
//            });
//        }
//    }];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.feedPosts.count; // Total number of rows in the sample data.
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    Post *post = self.feedPosts[indexPath.section];

    if (indexPath.row == 1) {

        FeedTableFooterCellView *footerView = [[[NSBundle mainBundle] loadNibNamed:@"FeedTableFooterCellView" owner:self options:nil] firstObject];
        footerView.delegate = self;
        footerView.descriptionLabel.text = post.textDescription;
        NSLog(@"%@ by description>>>>>>>>: %@",post.author.username, post.textDescription);
        [footerView.contentView setUserInteractionEnabled:NO];


        if ([self.likesArray[indexPath.section] isEqual:@1]) {
            [footerView.likeButton setBackgroundImage:[UIImage imageNamed:@"heart-on"] forState:UIControlStateNormal];
        } else if ([self.likesArray[indexPath.section] isEqual:@0]){
            [footerView.likeButton setBackgroundImage:[UIImage imageNamed:@"semi-heart-on"] forState:UIControlStateNormal];
        }

        return footerView;

    } else {
        FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedTableViewCell"];
        // NSDictionary *cellData = [_objects objectAtIndex:[indexPath section]];  // Note we're using section, not row here
        //NSArray *articleData = [cellData objectForKey:@"articles"];
        // [cell setCollectionData:articleData];

        NSArray *images = [ImageProcessing getImageArrayFromDataArray:post.roll];
        [cell setCollectionData:images];

        return cell;
    }

}

#pragma mark UITableViewDelegate methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FeedTableHeaderView *headerView = [[[NSBundle mainBundle] loadNibNamed:@"FeedTableHeaderView" owner:self options:nil] firstObject];

    Post *post = self.feedPosts[section];

    [self.feedTableView beginUpdates];
    [headerView.authorButton setTitle:post.author.username forState:UIControlStateNormal];

    if (post.author.profilePicture) {
        UIImage *authorImage = [ImageProcessing getImageFromData:post.author.profilePicture];
        headerView.authorProfilePicture.image = authorImage;
    }


    NSString *timeStamp;
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDate *d1 = [NSDate date];
    NSDate *d2 = post.createdAt;

    NSDateComponents *components = [c components:NSCalendarUnitHour fromDate:d2 toDate:d1 options:0];
    NSInteger diff = components.hour;

    if (diff < 1) {
        NSDateComponents *components = [c components:NSCalendarUnitMinute fromDate:d2 toDate:d1 options:0];
        NSInteger diff = components.minute;
        timeStamp = [NSString stringWithFormat:@"%lum", diff];
    } else {
        timeStamp = [NSString stringWithFormat:@"%luh", diff];
    }

    headerView.timeStampLabel.text = timeStamp;

    [self.feedTableView endUpdates];
    headerView.delegate = self;
    [headerView setNeedsDisplay];
    [headerView setNeedsLayout];

    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1)
#warning match this height with feedtablefootercellview
        return 90;
    else
        return 400.0;
}

#pragma mark - Feed Table Header Delegate Methods

-(void)headerAuthorButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ToUserProfileSegue" sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {

    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.feedTableView];
    NSIndexPath *indexPath = [self.feedTableView indexPathForRowAtPoint:touchPoint];

    if ([segue.identifier isEqualToString:@"toPostDetailSegue"]){
        PostDetailViewController *vc = segue.destinationViewController;
        Post *post = self.feedPosts[indexPath.section];
        vc.post = post;

    } else {
        SearchDetailViewController *vc = segue.destinationViewController;
        // TODO: change current user to user name in header
        User *selectedUser = [self.feedPosts[indexPath.section] author];
        vc.user = selectedUser;
        vc.sourceVC = self;
    }

}


#pragma mark - Feed Table Footer Cell View delegate methods

- (void)likeButtonWasPressed:(UIButton *)sender {
    sender.adjustsImageWhenDisabled = NO;
    [sender setEnabled:NO];
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.feedTableView];
    NSIndexPath *indexPath = [self.feedTableView indexPathForRowAtPoint:touchPoint];
    Post *selectedPost = self.feedPosts[indexPath.section];

    NSMutableArray *tempLikesArray = [[NSMutableArray alloc] initWithArray:self.likesArray];

    dispatch_async(dispatch_get_main_queue(), ^{

        if ([[self.likesArray objectAtIndex:indexPath.section] isEqual:@1]){
            [tempLikesArray setObject:@0 atIndexedSubscript:indexPath.section];
            self.likesArray = [NSArray arrayWithArray:tempLikesArray];
            [sender setBackgroundImage:[UIImage imageNamed:@"semi-heart-on"] forState:UIControlStateNormal];

        } else {
            [tempLikesArray setObject:@1 atIndexedSubscript:indexPath.section];
            self.likesArray = [NSArray arrayWithArray:tempLikesArray];
            [sender setBackgroundImage:[UIImage imageNamed:@"heart-on"] forState:UIControlStateNormal];

        }
    });

    PFQuery *dislikeQuery = [Activity query];
    [dislikeQuery whereKey:@"post" equalTo:selectedPost];
    [dislikeQuery whereKey:@"fromUser" equalTo:[User currentUser]];
    [dislikeQuery whereKey:@"activityType" equalTo:@0];

    [dislikeQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error){
        if (objects.count>0) {
            Activity *deleteActivity = objects.firstObject;
            if ([deleteActivity.toUser isEqual:[User currentUser]]){
                [self.delegate postWasChanged:self];
            }
            [deleteActivity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [sender setEnabled:YES];
            }];
        } else {
            Activity *addActivity = [Activity object];
            addActivity.activityType = @0;
            addActivity.fromUser = [User currentUser];
            addActivity.toUser = selectedPost.author;
            if ([addActivity.toUser isEqual:[User currentUser]]){
                [self.delegate postWasChanged:self];
            }
            addActivity.post = selectedPost;
            [addActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [sender setEnabled:YES];
            }];
        }
        } else {
            [sender setEnabled:YES];

        }
    }];
}

- (void)moreButtonWasPressed:(id)sender {

    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.feedTableView];
    NSIndexPath *indexPath = [self.feedTableView indexPathForRowAtPoint:touchPoint];
    Post *selectedPost = self.feedPosts[indexPath.section];

    if ([selectedPost.author isEqual:[User currentUser]]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Post" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

            UIAlertController *secondAlert = [UIAlertController alertControllerWithTitle:@"Delete Post" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                // Remove all activity associated with the post as well

                [self.delegate postWasChanged:self];
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.feedPosts];
                    [tempArray removeObjectAtIndex:indexPath.section];
                    self.feedPosts = [NSArray arrayWithArray:tempArray];
                    [self.feedTableView reloadData];
//                    [self dismissViewControllerAnimated:YES completion:nil];
                   // [self getAllPosts];
                });

                PFQuery *query = [Activity query];
                [query whereKey:@"post" equalTo:selectedPost];
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    NSArray *activitiesToDelete = objects;
                    [Activity deleteAllInBackground:activitiesToDelete];
                    [selectedPost deleteInBackground];
                }];
            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];

            [secondAlert addAction:yes];
            [secondAlert addAction:cancel];
            [self presentViewController:secondAlert animated:YES completion:nil];

        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:deleteAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];

    } else  {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Post" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *reportAction = [UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

            //TODO: Do something with report here

            UIAlertController *secondAlert = [UIAlertController alertControllerWithTitle:@"Post Reported" message:@"We have received you report and will take necessary action." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
            [secondAlert addAction:okay];
            [self presentViewController:secondAlert animated:YES completion:nil];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:reportAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)commentsButtonWasPressed:(id)sender {
    [self performSegueWithIdentifier:@"toPostDetailSegue" sender:sender];
}

@end
