//
//  FeedTableHeaderView.h
//  Shuttr
//
//  Created by Philip Henson on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FeedTableHeaderDelegate <NSObject>

- (void)headerAuthorButtonTapped:(id)sender;

@end

@interface FeedTableHeaderView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UIButton *authorButton;
@property (weak,nonatomic) id<FeedTableHeaderDelegate>delegate;

@end
