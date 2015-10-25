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

@interface SearchViewController () <UISearchBarDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *filteredSearchResults;
@property (nonatomic) NSArray *users;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeSearchController];
    self.filteredSearchResults = [NSArray new];
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

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {

    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"username contains [c] %@ AND fullName contains [c] %@", searchController.searchBar.text, searchController.searchBar.text];
    self.filteredSearchResults = [self.users filteredArrayUsingPredicate:resultPredicate];
    [self.tableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchCell"];
    User *user = [self.filteredSearchResults objectAtIndex:indexPath.row];
    cell.textLabel.text = user.fullName;
    cell.imageView.image = [UIImage imageWithImage:[ImageProcessing getImageFromData:user.profilePicture] scaledToSize:CGSizeMake(cell.imageView.frame.size.width, cell.imageView.frame.size.height)];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredSearchResults.count;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToSearchDetailSegue"]) {
        SearchDetailViewController *vc = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        vc.user = [self.filteredSearchResults objectAtIndex:indexPath.row];

    }
}


@end
