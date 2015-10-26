//
//  FeedContainerCellView.m
//  Shuttr
//
//  Created by Francis Bato on 10/23/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "FeedContainerCellView.h"
#import "FeedPhotoCollectionViewCell.h"

@interface FeedContainerCellView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSArray *collectionData;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end


@implementation FeedContainerCellView

- (void)setCollectionData:(NSArray *)collectionData {
    _collectionData = collectionData;
    //[_collectionView setContentOffset:CGPointZero animated:NO];
    [_collectionView reloadData];
}
- (void)awakeFromNib {

    self.collectionData = [NSArray new];
    self.collectionView.backgroundColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
#warning adjust the photosizes here
    flowLayout.itemSize = CGSizeMake(400.0, 400.0);
    [self.collectionView setCollectionViewLayout:flowLayout];

#warning update this to the custom collection view cell
    // Register the collection cell
    [_collectionView registerNib:[UINib nibWithNibName:@"FeedPhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"FeedPhotoCollectionViewCell"];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FeedPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FeedPhotoCollectionViewCell" forIndexPath:indexPath];
    //NSDictionary *cellData = [self.collectionData objectAtIndex:[indexPath row]];
    cell.feedPhoto.image = [self.collectionData objectAtIndex:[indexPath row]];
       return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collectionData.count;
}

@end
