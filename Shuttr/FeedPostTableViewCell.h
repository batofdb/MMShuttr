//
//  PostTableViewCell.h
//  Shuttr
//
//  Created by Francis Bato on 10/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedPostCollectionView : UICollectionView

@property (nonatomic) NSIndexPath *indexPath;

@end


static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface FeedPostTableViewCell : UITableViewCell

@property (nonatomic) FeedPostCollectionView *collectionView;

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath;
@end

