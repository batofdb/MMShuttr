//
//  SearchViewController.m
//  Shuttr
//
//  Created by Philip Henson on 10/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "SearchViewController.h"
#import "SearchDetailViewController.h"
#import "User.h"
#import "UIImage+ImageResizing.h"
#import "ImageProcessing.h"
#import "Activity.h"
#import "ActivityFeedTableViewCell.h"
#import "PostDetailViewController.h"
#import "SVProgressHUD.h"


@interface SearchViewController () <UISearchBarDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *filteredSearchResults;
@property (nonatomic) NSArray *users;
@property (nonatomic) NSArray *activityItems;
@property (nonatomic) NSArray *userItems;
@property (nonatomic) NSMutableArray *friends;
@property (nonatomic) NSArray *exploreItems;
@property (weak, nonatomic) IBOutlet UISegmentedControl *activityUserSegmentedControl;

@end


@implementation SearchViewController

#pragma mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeSearchController];
}

-(void)viewWillAppear:(BOOL)animated {
    // Need to keep activity up to date
    // TODO: implement pulldown to refresh
    [self updateSearchWithQuery];



}



-(void)updateSearchWithQuery {

    if (self.activityUserSegmentedControl.selectedSegmentIndex == 0)
        [self activityItemsQuery];

    if (self.activityUserSegmentedControl.selectedSegmentIndex == 1)
        [self friendsQuery];

    if (self.activityUserSegmentedControl.selectedSegmentIndex == 2)
        [self userQueryAndSave];
}


- (void) initializeSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.definesPresentationContext = YES;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.placeholder = @"Search for people";
    self.searchController.searchBar.tintColor = UIColorFromRGB(0x4C374C);
    self.searchController.searchBar.barTintColor = UIColorFromRGB(0x4C374C);
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
}

- (void)userQueryAndSave {
    PFQuery *query = [User query];
    self.filteredSearchResults = [NSArray new];
    query.limit = 20;
    [SVProgressHUD show];
    [query orderByDescending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.users = [[NSArray alloc] initWithArray:objects];
        [SVProgressHUD dismiss];
        self.exploreItems = self.users;
        [self.tableView reloadData];
    }];
}

- (void)friendsQuery {
    PFQuery *fromUserQuery = [PFQuery queryWithClassName:@"Activity"];
    [fromUserQuery whereKey:@"activityType" equalTo:@2];
    [fromUserQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];

    PFQuery *toUserQuery = [PFQuery queryWithClassName:@"Activity"];
    [toUserQuery whereKey:@"activityType" equalTo:@2];
    [toUserQuery whereKey:@"toUser" equalTo:[PFUser currentUser]];

    PFQuery *friendQuery = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:fromUserQuery, toUserQuery,nil]];



    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.friends = [NSMutableArray new];

        for (Activity *activity in objects) {
            if ([activity.fromUser isEqual:[PFUser currentUser]]) {
                [self.friends addObject:activity.toUser];
            } else {
                [self.friends addObject:activity.fromUser];
            }
        }

        [SVProgressHUD dismiss];
        self.exploreItems = self.friends;

        [self.tableView reloadData];
    }];
}

- (void)queryAdditionalUsers {
    /* Added for scalability. Want to only search for 20 people at first, and the following can be executed in either condition:

     1) the results array is empty so we will need to keep querying people until something is found for the search
     2) the person the user is searching for isn't in the list, and the user clicks "more" to continue searching

     */

    PFQuery *query = [User query];
    NSMutableArray *objectIdArray = [NSMutableArray new];
    for (User *user in self.filteredSearchResults) {
        [objectIdArray addObject:user.objectId];
    }
    query.limit = 20;
    [SVProgressHUD show];

    [query whereKey:@"objectId" notContainedIn:objectIdArray];
    [query orderByDescending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.users arrayByAddingObjectsFromArray:objects];
        [SVProgressHUD dismiss];

        [self.tableView reloadData];

    }];

}
- (IBAction)onActivityUserSelected:(UISegmentedControl *)sender {
    [self updateSearchWithQuery];
}

- (void) activityItemsQuery {
    self.activityItems = [NSArray new];

    PFQuery *queryToUser = [Activity query];
    //One week ago = 7 (days) * 24 (hours) * 60 (minutes) * 60 (seconds)
    //int oneWeekAgo = 7*24*60*60;
    //NSDate *threeDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-oneWeekAgo];
    //[query whereKey:@"updatedAt" greaterThanOrEqualTo:threeDaysAgo];

    [queryToUser whereKey:@"toUser" equalTo:[User currentUser]];


    // Can comment this out again later, but for now it causes more problems than it solves, since we have to check each activity and edit if it's the user who creates the activity. Also, have to check in prepareForSegue and change the destination view controller if the user clicks on their own profile picture.

    PFQuery *queryFromUser = [Activity query];
    [queryFromUser whereKey:@"fromUser" equalTo:[User currentUser]];
    [SVProgressHUD show];

    PFQuery *queryAllRelatedActivities = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:queryFromUser, queryToUser, nil]];

    [queryAllRelatedActivities findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.activityItems = objects;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.exploreItems = self.activityItems;
            [self.tableView reloadData];

            [SVProgressHUD dismiss];
        });
    }];
}

- (NSArray *)currentArray {
    if (self.searchController.isActive) {
        //self.tableView.allowsSelection = YES;
        return self.filteredSearchResults;
    } else {
        //self.tableView.allowsSelection = NO;
        //return self.activityItems;
        return self.exploreItems;
    }
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {

    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"username contains [c] %@ OR fullName contains [c] %@", searchController.searchBar.text, searchController.searchBar.text];
    self.filteredSearchResults = [self.exploreItems filteredArrayUsingPredicate:resultPredicate];
    [self.tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *target = [self currentArray];
    if (self.activityUserSegmentedControl.selectedSegmentIndex != 0) {

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];

        User *user = [target objectAtIndex:indexPath.row];

        cell.textLabel.text = user.username;
        cell.detailTextLabel.text = user.fullName;
       // cell.imageView.image =[UIImage imageWithImage:[ImageProcessing getImageFromData:user.profilePicture] scaledToSize:CGSizeMake(50, 50)] ;
        cell.imageView.image =[ImageProcessing getImageFromData:user.profilePicture];
        return cell;

    } else {
        Activity *activity = [target objectAtIndex:indexPath.row];
        ActivityFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
        cell.activityItemTextLabel.textColor = UIColorFromRGB(0xD9A39A);
        if ([activity.activityType isEqual:@0]){

            if ([activity.fromUser isEqual:[User currentUser]]){
                cell.activityItemTextLabel.text = [NSString stringWithFormat:@"You've liked on one of your rolls"];
            } else {

                cell.activityItemTextLabel.text = [NSString stringWithFormat:@"%@ likes one of your rolls", activity.fromUser.username];
            }
            [cell.fromUserButton setBackgroundImage:[UIImage imageWithImage:[ImageProcessing getImageFromData:activity.fromUser.profilePicture] scaledToSize:CGSizeMake(cell.fromUserButton.frame.size.width, cell.fromUserButton.frame.size.width)] forState:UIControlStateNormal];

            UIImage *postRollCoverImage = [ImageProcessing getImageFromData:[activity.post.roll firstObject]];
            [cell.toPostButton setBackgroundImage:[UIImage imageWithImage:postRollCoverImage scaledToSize:CGSizeMake(cell.toPostButton.frame.size.width, cell.toPostButton.frame.size.width)] forState:UIControlStateNormal];

            [cell.toPostButton setEnabled:YES];
            cell.fromUserButton.tag = indexPath.row;
            cell.toPostButton.tag = indexPath.row;

        } else if ([activity.activityType isEqual:@1]){
            if ([activity.fromUser isEqual:[User currentUser]]){
                cell.activityItemTextLabel.text = [NSString stringWithFormat:@"You've commented on one of your rolls"];
            } else {
                cell.activityItemTextLabel.text = [NSString stringWithFormat:@"%@ commented on one of your rolls", activity.fromUser.username];
            }
           [cell.fromUserButton setBackgroundImage:[UIImage imageWithImage:[ImageProcessing getImageFromData:activity.fromUser.profilePicture] scaledToSize:CGSizeMake(cell.fromUserButton.frame.size.width, cell.fromUserButton.frame.size.width)] forState:UIControlStateNormal];
            UIImage *postRollCoverImage = [ImageProcessing getImageFromData:[activity.post.roll firstObject]];
            [cell.toPostButton setBackgroundImage:[UIImage imageWithImage:postRollCoverImage scaledToSize:CGSizeMake(cell.toPostButton.frame.size.width, cell.toPostButton.frame.size.width)] forState:UIControlStateNormal];
            [cell.toPostButton setEnabled:YES];
            cell.fromUserButton.tag = indexPath.row;
            cell.toPostButton.tag = indexPath.row;

        } else if ([activity.activityType isEqual:@2] ){
            cell.activityItemTextLabel.text = [NSString stringWithFormat:@"%@ is following you", activity.fromUser.username];

            UIImageView* image = [UIImageView new];
            image.image = [UIImage imageWithImage:[ImageProcessing getImageFromData:activity.fromUser.profilePicture] scaledToSize:CGSizeMake(cell.fromUserButton.frame.size.width, cell.fromUserButton.frame.size.width)];

            image.layer.cornerRadius = image.frame.size.height/2;
            image.clipsToBounds = YES;

            [cell.fromUserButton setBackgroundImage:image.image forState:UIControlStateNormal];
            [cell.toPostButton setEnabled:NO];
            cell.fromUserButton.tag = indexPath.row;
        }
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self currentArray] count];
}

- (IBAction)onFromUserButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ToSearchDetailSegue" sender:sender];
}

- (IBAction)onPostButtonPressed:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ToPostDetailSegue" sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToSearchDetailSegue"]) {

        SearchDetailViewController *vc = segue.destinationViewController;

        CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];

        if (self.searchController.isActive) {
            vc.user = [self.filteredSearchResults objectAtIndex:indexPath.row] ;
       } else {
           if (self.activityUserSegmentedControl.selectedSegmentIndex == 0) {
                Activity *activity = [self.exploreItems objectAtIndex:indexPath.row] ;
                vc.user = activity.fromUser;
           } else {
               User *user = [self.exploreItems objectAtIndex:indexPath.row] ;
               vc.user = user;
           }
        }

    } else if ([segue.identifier isEqualToString:@"ToPostDetailSegue"]) {
        PostDetailViewController *vc = segue.destinationViewController;
        CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];
        Activity *activity = [self.exploreItems objectAtIndex:indexPath.row];
        vc.post = activity.post;
    }
}


@end
