//
//  PostPhotosViewController.m
//  Shuttr
//
//  Created by Lin Wei on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "PostPhotosViewController.h"
#import "PostCollectionViewCell.h"

@interface PostPhotosViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation PostPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Hard coding images for now
    self.images = @[[UIImage imageNamed:@"Arya_Stark"],
                    [UIImage imageNamed:@"Cersei_Lannister"],
                    [UIImage imageNamed:@"Daenerys_Targaryen"],
                    [UIImage imageNamed:@"Eddard_Stark"],
                    [UIImage imageNamed:@"GOT_default"],
                    [UIImage imageNamed:@"Joffrey_Baratheon"],
                    [UIImage imageNamed:@"Jon_Snow"],
                    [UIImage imageNamed:@"Sansa_Stark"],
                    [UIImage imageNamed:@"Tyrion_Lannister"]];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.imageView.image = [self.images objectAtIndex:indexPath.row];

    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (IBAction)onPostButtonPressed:(UIButton *)sender {

    //TODO: save parse data and perform unwind segue - maybe handle this all with delegation
}

@end
