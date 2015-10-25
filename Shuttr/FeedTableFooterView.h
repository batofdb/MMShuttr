//
//  FeedTableFooterView.h
//  Shuttr
//
//  Created by Francis Bato on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedTableFooterView : UITableViewHeaderFooterView
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *likeImage;

@property (weak, nonatomic) IBOutlet UIButton *commentButton;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;
@end
