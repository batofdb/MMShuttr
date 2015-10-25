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

@interface MainFeedViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
@property NSArray *objects;
@end

@implementation MainFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.feedTableView registerClass:[FeedTableViewCell class] forCellReuseIdentifier:@"FeedTableViewCell"];

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
    return 1;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_objects count]; // Total number of rows in the sample data.
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedTableViewCell"];
    NSDictionary *cellData = [_objects objectAtIndex:[indexPath section]];  // Note we're using section, not row here
    NSArray *articleData = [cellData objectForKey:@"articles"];
    [cell setCollectionData:articleData];
    return cell;
}

#pragma mark UITableViewDelegate methods
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *sectionData = [_objects objectAtIndex:section];
    NSString *header = [sectionData objectForKey:@"description"];
    return header;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 400.0;
}

@end
