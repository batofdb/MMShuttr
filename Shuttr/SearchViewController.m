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

@interface SearchViewController () <UISearchBarDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *filteredSearchResults;
@property (nonatomic) NSArray *users;
@property (nonatomic) NSArray *activityItems;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeSearchController];
    [self activityItemsQuery];
    [self userQueryAndSave];

}

-(void)viewDidAppear:(BOOL)animated {
    [self activityItemsQuery];
}

- (void) initializeSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.definesPresentationContext = YES;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.placeholder = @"Search for people.";
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;

}

- (void)userQueryAndSave {
    PFQuery *query = [User query];
    self.filteredSearchResults = [NSArray new];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.users = [[NSArray alloc] initWithArray:objects];
    }];
}

- (void) activityItemsQuery {
    self.activityItems = [NSArray new];

    PFQuery *query = [Activity query];
    // Three days ago = 3 (days) * 24 (hours) * 60 (minutes) * 60 (seconds)
    //NSDate *threeDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-259200];
    //[query whereKey:@"updatedAt" greaterThanOrEqualTo:threeDaysAgo];
    [query whereKey:@"toUser" equalTo:[User currentUser]];
    //[query whereKey:@"fromUser" notEqualTo:[User currentUser]];
    [query includeKey:@"fromUser"]; // for some reason I need this in order to access properties on activity.fromUser
    [query includeKey:@"post"];

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        self.activityItems = objects;

        dispatch_async(dispatch_get_main_queue(), ^{

            [self.tableView reloadData];
        });
    }];
}

- (NSArray *)currentArray {
    if (self.searchController.isActive) {
        self.tableView.allowsSelection = YES;
        return self.filteredSearchResults;
    } else {
        self.tableView.allowsSelection = NO;
        return self.activityItems;
    }
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {

    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"username contains [c] %@ AND fullName contains [c] %@", searchController.searchBar.text, searchController.searchBar.text];
    self.filteredSearchResults = [self.users filteredArrayUsingPredicate:resultPredicate];
    [self.tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSArray *target = [self currentArray];
    if ([[self currentArray] isEqualToArray:self.filteredSearchResults]) {

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

        if ([activity.activityType isEqual:@0]){

            cell.activityItemTextLabel.text = [NSString stringWithFormat:@"%@ likes one of your rolls", activity.fromUser.username];

            [cell.fromUserButton setBackgroundImage:[UIImage imageWithImage:[ImageProcessing getImageFromData:activity.fromUser.profilePicture] scaledToSize:CGSizeMake(cell.fromUserButton.frame.size.width, cell.fromUserButton.frame.size.width)] forState:UIControlStateNormal];

            UIImage *postRollCoverImage = [ImageProcessing getImageFromData:[activity.post.roll firstObject]];
            [cell.toPostButton setBackgroundImage:[UIImage imageWithImage:postRollCoverImage scaledToSize:CGSizeMake(cell.toPostButton.frame.size.width, cell.toPostButton.frame.size.width)] forState:UIControlStateNormal];

            [cell.toPostButton setEnabled:YES];
            cell.fromUserButton.tag = indexPath.row;
            cell.toPostButton.tag = indexPath.row;

        } else if ([activity.activityType isEqual:@1]){
            cell.activityItemTextLabel.text = [NSString stringWithFormat:@"%@ commented on one of your rolls", activity.fromUser.username];
           [cell.fromUserButton setBackgroundImage:[UIImage imageWithImage:[ImageProcessing getImageFromData:activity.fromUser.profilePicture] scaledToSize:CGSizeMake(cell.fromUserButton.frame.size.width, cell.fromUserButton.frame.size.width)] forState:UIControlStateNormal];
            UIImage *postRollCoverImage = [ImageProcessing getImageFromData:[activity.post.roll firstObject]];
            [cell.toPostButton setBackgroundImage:[UIImage imageWithImage:postRollCoverImage scaledToSize:CGSizeMake(cell.toPostButton.frame.size.width, cell.toPostButton.frame.size.width)] forState:UIControlStateNormal];
            [cell.toPostButton setEnabled:YES];
            cell.fromUserButton.tag = indexPath.row;
            cell.toPostButton.tag = indexPath.row;

        } else if ([activity.activityType isEqual:@2] ){
            cell.activityItemTextLabel.text = [NSString stringWithFormat:@"%@ is following you", activity.fromUser.username];
            [cell.fromUserButton setBackgroundImage:[UIImage imageWithImage:[ImageProcessing getImageFromData:activity.fromUser.profilePicture] scaledToSize:CGSizeMake(cell.fromUserButton.frame.size.width, cell.fromUserButton.frame.size.width)] forState:UIControlStateNormal];
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
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if (self.searchController.isActive) {
            vc.user = [self.filteredSearchResults objectAtIndex:indexPath.row];
       } else {
            UIButton *button = sender;
            Activity *activity = [self.activityItems objectAtIndex:button.tag];
            vc.user = activity.fromUser;
        }

    } else if ([segue.identifier isEqualToString:@"ToPostDetailSegue"]) {
        PostDetailViewController *vc = segue.destinationViewController;
        UIButton *button = sender;
        Activity *activity = [self.activityItems objectAtIndex:button.tag];
        vc.post = activity.post;
    }
}


@end
