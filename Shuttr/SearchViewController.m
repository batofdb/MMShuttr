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
    self.filteredSearchResults = [NSArray new];
    self.activityItems = [NSArray new];
    [self activityItemsQuery];
    [self userQueryAndSave];

}

- (void) initializeSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.definesPresentationContext = YES;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.placeholder = @"Search for users.";
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;

}

- (void)userQueryAndSave {
    PFQuery *query = [User query];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.users = [[NSArray alloc] initWithArray:objects];
    }];
}

- (void) activityItemsQuery {

    PFQuery *query = [Activity query];
    // Three days ago = 3 (days) * 24 (hours) * 60 (minutes) * 60 (seconds)
    NSDate *threeDaysAgo = [NSDate dateWithTimeIntervalSinceNow:-259200];
    [query whereKey:@"toUser" equalTo:[User currentUser]];
    [query whereKey:@"fromUser" notEqualTo:[User currentUser]];
    [query includeKey:@"fromUser"]; // for some reason I need this in order to access properties on activity.fromUser
    [query whereKey:@"updatedAt" greaterThanOrEqualTo:threeDaysAgo];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.activityItems = objects;

        dispatch_async(dispatch_get_main_queue(), ^{

            [self.tableView reloadData];
        });
    }];
}

- (NSArray *)currentArray {
    if (self.searchController.isActive) {
        return self.filteredSearchResults;
    } else {
        return self.activityItems;
    }
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {

    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"username contains [c] %@ AND fullName contains [c] %@", searchController.searchBar.text, searchController.searchBar.text];
    self.filteredSearchResults = [self.users filteredArrayUsingPredicate:resultPredicate];
    [self.tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];

    NSArray *target = [self currentArray];
    if ([[self currentArray] isEqualToArray:self.filteredSearchResults]) {
        User *user = [target objectAtIndex:indexPath.row];

        cell.textLabel.text = user.username;
        cell.detailTextLabel.text = user.fullName;
        cell.imageView.image = [UIImage imageWithImage:[ImageProcessing getImageFromData:user.profilePicture] scaledToSize:CGSizeMake(cell.imageView.frame.size.width, cell.imageView.frame.size.height)];

    } else {
        Activity *activity = [target objectAtIndex:indexPath.row];
        if ([activity.activityType isEqual:@0]){
            cell.textLabel.text = [NSString stringWithFormat:@"%@ likes one of your rolls", activity.fromUser.username];
            cell.imageView.image = [UIImage imageWithImage:[ImageProcessing getImageFromData:activity.fromUser.profilePicture] scaledToSize:CGSizeMake(cell.imageView.frame.size.width, cell.imageView.frame.size.width)];

        } else if ([activity.activityType isEqual:@1]){
            cell.textLabel.text = [NSString stringWithFormat:@"%@ commented on one of your rolls", activity.fromUser.username];
            cell.imageView.image = [UIImage imageWithImage:[ImageProcessing getImageFromData:activity.fromUser.profilePicture] scaledToSize:CGSizeMake(cell.imageView.frame.size.width, cell.imageView.frame.size.width)];

        } else if ([activity.activityType isEqual:@2] ){
            cell.textLabel.text = [NSString stringWithFormat:@"%@ is following you", activity.fromUser.username];
            cell.imageView.image = [UIImage imageWithImage:[ImageProcessing getImageFromData:activity.fromUser.profilePicture] scaledToSize:CGSizeMake(cell.imageView.frame.size.width, cell.imageView.frame.size.width)];

        }
    }

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self currentArray] count];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToSearchDetailSegue"]) {
        SearchDetailViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        if ([[self currentArray] isEqualToArray:self.filteredSearchResults]) {
            vc.user = [self.filteredSearchResults objectAtIndex:indexPath.row];
        } else {
            Activity *activity = [self.activityItems objectAtIndex:indexPath.row];
            vc.user = activity.fromUser;
        }

    }
}


@end
