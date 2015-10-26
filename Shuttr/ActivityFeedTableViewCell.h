//
//  ActivityFeedTableViewCell.h
//  Shuttr
//
//  Created by Philip Henson on 10/25/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityFeedTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *fromUserButton;
@property (weak, nonatomic) IBOutlet UIButton *toPostButton;
@property (weak, nonatomic) IBOutlet UILabel *activityItemTextLabel;

@end
