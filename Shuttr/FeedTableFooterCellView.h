//
//  FeedTableFooterView.h
//  Shuttr
//
//  Created by Francis Bato on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedTableFooterCellDelegate <NSObject>

- (void)likeButtonWasPressed:(id)sender;
- (void)commentsButtonWasPressed:(id)sender;
- (void)moreButtonWasPressed:(id)sender;

@end

@interface FeedTableFooterCellView : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property (weak, nonatomic) id <FeedTableFooterCellDelegate> delegate;
@end
