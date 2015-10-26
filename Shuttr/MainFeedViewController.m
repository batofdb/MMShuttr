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

@interface MainFeedViewController () <UITableViewDataSource, UITableViewDelegate, FeedTableHeaderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property NSArray *objects;
@property NSArray *feedPosts;
@end

@implementation MainFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.feedPosts = [NSArray new];

    [self.feedTableView registerClass:[FeedTableViewCell class] forCellReuseIdentifier:@"FeedTableViewCell"];
/*
    PFQuery *authorQuery = [User query];
    [authorQuery whereKey:@"username" equalTo:@"philly"];
    [authorQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        User *user = objects.firstObject;
        PFQuery *postQuery = [Post query];
        [postQuery whereKey:@"author" equalTo:user];
        [postQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            self.feedPosts = objects;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.feedTableView reloadData];
            });
        }];
    }];
*/

    PFQuery *allPosts = [PFQuery queryWithClassName:@"Post"];
    [allPosts includeKey:@"author"];
    [allPosts findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects.count > 0) {
            self.feedPosts = objects;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.feedTableView reloadData];
            });
        }
    }];

}

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

        footerView.descriptionLabel.text = post.textDescription;
        NSLog(@"%@ by description>>>>>>>>: %@",post.author.username, post.textDescription);

        [footerView setUserInteractionEnabled:NO];

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
    SearchDetailViewController *vc = segue.destinationViewController;

    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.feedTableView];
    NSIndexPath *indexPath = [self.feedTableView indexPathForRowAtPoint:touchPoint];
    User *selectedUser = [self.feedPosts[indexPath.section] author];

    // TODO: change current user to user name in header
    vc.user = selectedUser;
    vc.sourceVC = self;
}


@end
