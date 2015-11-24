//
//  ActivityViewController.m
//  Shuttr
//
//  Created by Philip Henson on 11/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "ActivityViewController.h"
#import "Activity.h"
#import "ActivityFeedTableViewCell.h"
#import "SVProgressHUD.h"
#import "ImageProcessing.h"
#import "UIImage+ImageResizing.h"


@interface ActivityViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSArray *activityItems;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation ActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self activityItemsQuery];

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
    [queryAllRelatedActivities includeKey:@"fromUser"];
    [queryAllRelatedActivities includeKey:@"toUser"];

    [queryAllRelatedActivities findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        self.activityItems = objects;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
        });
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Activity *activity = [self.activityItems objectAtIndex:indexPath.row];
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

        if (![activity.fromUser isEqual:[User currentUser]]) {
            cell.activityItemTextLabel.text = [NSString stringWithFormat:@"%@ is following you", activity.fromUser.username];
        } else {
            cell.activityItemTextLabel.text = [NSString stringWithFormat:@"You are following %@", activity.toUser.username];
        }


        UIImageView* image = [UIImageView new];
        image.image = [UIImage imageWithImage:[ImageProcessing getImageFromData:activity.fromUser.profilePicture] scaledToSize:CGSizeMake(cell.fromUserButton.frame.size.width, cell.fromUserButton.frame.size.width)];

        //            if (!image) {
        //                image.image = image.image;
        //            } else {
        //                image.image = [UIImage imageNamed:@"defaultProfilePicture"];
        //            }


        image.layer.cornerRadius = image.frame.size.height/2;
        image.clipsToBounds = YES;

        [cell.fromUserButton setBackgroundImage:image.image forState:UIControlStateNormal];
        [cell.toPostButton setEnabled:NO];
        cell.fromUserButton.tag = indexPath.row;
    }

    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.activityItems.count;
}


@end
