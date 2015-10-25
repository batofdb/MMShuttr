//
//  FeedTableViewCell.m
//  Shuttr
//
//  Created by Francis Bato on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "FeedTableViewCell.h"
#import "FeedContainerCellView.h"

@interface FeedTableViewCell ()
@property (strong, nonatomic) FeedContainerCellView *collectionView;
@end

@implementation FeedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _collectionView = [[NSBundle mainBundle] loadNibNamed:@"FeedContainerCellView" owner:self options:nil][0];
        _collectionView.frame = self.bounds;
        [self.contentView addSubview:_collectionView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setCollectionData:(NSArray *)collectionData {
    [_collectionView setCollectionData:collectionData];
}


@end
