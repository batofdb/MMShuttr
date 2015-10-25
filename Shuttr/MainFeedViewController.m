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

@interface MainFeedViewController () <UITableViewDataSource, UITableViewDelegate, FeedTableHeaderDelegate>
@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property NSArray *objects;
@end

@implementation MainFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    User *user = [User currentUser];

    if (!user){
        [User logInWithUsernameInBackground:@"francis" password:@"pizza" block:^(PFUser * _Nullable user, NSError * _Nullable error) {}];
    }


    [self.feedTableView registerClass:[FeedTableViewCell class] forCellReuseIdentifier:@"FeedTableViewCell"];

    //[self.feedTableView registerClass:[FeedTableFooterView class] forHeaderFooterViewReuseIdentifier:@"FeedFooter"];

    [self.feedTableView registerClass:[FeedTableHeaderView class] forHeaderFooterViewReuseIdentifier:@"FeedHeader"];

    self.objects = @[ @{ @"description": @"Section A",
                     @"articles": @[ @{ @"title": @"Article A1" },
                                     @{ @"title": @"Article A2" },
                                     @{ @"title": @"Article A3" },
                                     @{ @"title": @"Article A4" },
                                     @{ @"title": @"Article A5" }
                                     ]
                     },
                  @{ @"description": @"Section B",
                     @"articles": @[ @{ @"title": @"Article B1" },
                                     @{ @"title": @"Article B2" },
                                     @{ @"title": @"Article B3" },
                                     @{ @"title": @"Article B4" },
                                     @{ @"title": @"Article B5" }
                                     ]
                     },
                  @{ @"description": @"Section C",
                     @"articles": @[ @{ @"title": @"Article C1" },
                                     @{ @"title": @"Article C2" },
                                     @{ @"title": @"Article C3" },
                                     @{ @"title": @"Article C4" },
                                     @{ @"title": @"Article C5" }
                                     ]
                     },
                  @{ @"description": @"Section D",
                     @"articles": @[ @{ @"title": @"Article D1" },
                                     @{ @"title": @"Article D2" },
                                     @{ @"title": @"Article D3" },
                                     @{ @"title": @"Article D4" },
                                     @{ @"title": @"Article D5" }
                                     ]
                     }
                  ];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_objects count]; // Total number of rows in the sample data.
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedTableViewCell"];

    if (indexPath.row == 1) {
        [self.feedTableView registerNib:[UINib nibWithNibName:@"FeedTableFooterCellView" bundle:nil] forCellReuseIdentifier:@"FooterCellView"];
        cell = [self.feedTableView dequeueReusableCellWithIdentifier:@"FooterCellView"];
    } else {

        NSDictionary *cellData = [_objects objectAtIndex:[indexPath section]];  // Note we're using section, not row here
        NSArray *articleData = [cellData objectForKey:@"articles"];
        [cell setCollectionData:articleData];
    }
    return cell;
}


#pragma mark UITableViewDelegate methods
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    FeedTableHeaderView *headerView = [self.feedTableView dequeueReusableHeaderFooterViewWithIdentifier:@"FeedHeader"];

    headerView.authorButton.titleLabel.text = @"authors";
    headerView.delegate = self;
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

-(void)headerAuthorButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"ToUserProfileSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    SearchDetailViewController *vc = segue.destinationViewController;

    // TODO: change current user to user name in header
    vc.user = [User currentUser];
}


@end
