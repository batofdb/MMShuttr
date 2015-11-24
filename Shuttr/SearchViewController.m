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
#import "PostDetailViewController.h"
#import "SVProgressHUD.h"
#import "Activity.h"


@interface SearchViewController () <UISearchBarDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *filteredSearchResults;
@property (nonatomic) NSArray *users;
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
        //self.tableView.tableHeaderView = self.searchController.searchBar;
        [self friendsQuery];

    if (self.activityUserSegmentedControl.selectedSegmentIndex == 1)
        //self.tableView.tableHeaderView = self.searchController.searchBar;
        [self userQueryAndSave];
}


- (void) initializeSearchController {
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.definesPresentationContext = YES;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.searchController.searchBar.placeholder = @"Search for people";
    self.searchController.searchBar.tintColor = UIColorFromRGB(0xFBF5AF);
    //self.searchController.searchBar.barTintColor = UIColorFromRGB(0x4C374C);
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
        self.activityUserSegmentedControl.userInteractionEnabled = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
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

            if (self.friends.count == objects.count) {
                [SVProgressHUD dismiss];
                self.exploreItems = self.friends;
                self.activityUserSegmentedControl.userInteractionEnabled = YES;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }



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
    self.activityUserSegmentedControl.userInteractionEnabled = NO;
    [self updateSearchWithQuery];
}



- (NSArray *)currentArray {
    if (self.searchController.isActive) {
        return self.filteredSearchResults;
    } else {
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
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];

        User *user = [target objectAtIndex:indexPath.row];

    [user fetchIfNeededInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        cell.textLabel.text = user.username;
        cell.detailTextLabel.text = user.fullName;
        // cell.imageView.image =[UIImage imageWithImage:[ImageProcessing getImageFromData:user.profilePicture] scaledToSize:CGSizeMake(50, 50)] ;
        UIImageView *imageView = [[UIImageView alloc]initWithImage:[ImageProcessing getImageFromData:user.profilePicture]];
        imageView.layer.cornerRadius = imageView.frame.size.height/2;
        imageView.clipsToBounds = YES;

        cell.imageView.image =imageView.image;

    }];

        return cell;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self currentArray] count];
}

- (IBAction)onFromUserButtonPressed:(UIButton *)sender {
    CGPoint touchPoint = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:touchPoint];

    if (self.searchController.isActive) {
        if ([[self.filteredSearchResults objectAtIndex:indexPath.row] isEqual:[User currentUser]]) {
            [self.tabBarController setSelectedIndex:2];
        } else {
            [self performSegueWithIdentifier:@"ToSearchDetailSegue" sender:sender];

        }
    } else {
        Activity *activity = [self.exploreItems objectAtIndex:indexPath.row];
        if ([activity.fromUser isEqual:[User currentUser]]) {
            [self.tabBarController setSelectedIndex:2];
        } else {
            [self performSegueWithIdentifier:@"ToSearchDetailSegue" sender:sender];
        }
    }

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
