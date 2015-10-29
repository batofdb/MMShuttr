//
//  PostPhotosViewController.m
//  Shuttr
//
//  Created by Lin Wei on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "PostPhotosViewController.h"
#import "PostCollectionViewCell.h"
#import "ImageProcessing.h"
#import "SVProgressHUD.h"
#import "User.h"
#import "Post.h"
#import "ProfileViewController.h"

@interface PostPhotosViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@end


@implementation PostPhotosViewController

#pragma mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView reloadData];
}

#pragma mark - Collection View Delegate Methods
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.imageView.image = [self.images objectAtIndex:indexPath.row];

    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

#pragma mark - Text Field Delegate Methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.descriptionTextField resignFirstResponder];

    return YES;
}

#pragma mark - IBActions
- (IBAction)onPostButtonPressed:(UIButton *)sender {

    // Uncomment to save photos to user's photo library
//    for (UIImage *image in self.images) {
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
//    }

    User *user = [User currentUser];
    Post *post = [Post object];

    post.author = user;
    post.textDescription = self.descriptionTextField.text;

    post.roll = [NSArray arrayWithObject: [ImageProcessing getDataFromImage:[self.images firstObject]]];

    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

        if (succeeded) {
            for (int i=1; i<[self.images count]; i++){
                [post.roll arrayByAddingObject:[ImageProcessing getDataFromImage:self.images[i]]];
                [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

                    if (succeeded) {
                        NSLog(@"additional photo saved");
                    } else {
                        NSLog(@"error saving additional photo");
                    }
                }];
            }

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Post Uploaded!" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                [self.delegate postButtonWasPressed:self];
            }];
            [alert addAction:okay];
            [self presentViewController:alert animated:YES completion:nil];


        } else {
            NSLog(@"unable to save post");
            NSLog(@"unable to save post");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to save post." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:dismiss];
            [self presentViewController:alert animated:YES completion:nil];

        }

    }];


/*

    post.roll = [ImageProcessing getDataArrayFromImageArray:self.images];

    [SVProgressHUD show];
    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"post saved");
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Post Uploaded!" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                [self dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:okay];
            [self presentViewController:alert animated:YES completion:nil];


        } else {
            NSLog(@"unable to save post");
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Unable to save post." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:dismiss];
            [self presentViewController:alert animated:YES completion:nil];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }];

    */

}

- (IBAction)onCancelButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end










