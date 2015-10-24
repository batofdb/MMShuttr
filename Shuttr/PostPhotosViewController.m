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
#import "User.h"
#import "Post.h"

@interface PostPhotosViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;


@end

@implementation PostPhotosViewController

#pragma mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];


/************Option One: Hard code images for testing Parse download**************/

    /*

    self.images = @[[UIImage imageNamed:@"Arya_Stark"],
                    [UIImage imageNamed:@"Cersei_Lannister"],
                    [UIImage imageNamed:@"Daenerys_Targaryen"],
                    [UIImage imageNamed:@"Eddard_Stark"],
                    [UIImage imageNamed:@"GOT_default"],
                    [UIImage imageNamed:@"Joffrey_Baratheon"],
                    [UIImage imageNamed:@"Jon_Snow"],
                    [UIImage imageNamed:@"Sansa_Stark"],
                    [UIImage imageNamed:@"Tyrion_Lannister"]];
*/

    /*
    self.images = @[[UIImage imageNamed:@"goofy"],
                    [UIImage imageNamed:@"olaf"],
                    [UIImage imageNamed:@"rapunzel"]];
     */

    /*
    self.images = @[[UIImage imageNamed:@"cookie"],
                    [UIImage imageNamed:@"cupcake"],
                    [UIImage imageNamed:@"strudel"]];
     */

    
    
    
/*************Option Two: Query the current user to test Parse upload***************/

    /*
    PFQuery *query = [Post query];
    [query whereKey:@"author" equalTo:[User currentUser]];
    Post *post =[[query findObjects] lastObject];

    self.images = [ImageProcessing getImageArrayFromDataArray:post.roll];
     */
    
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

    User *user = [User currentUser];
    Post *post = [Post new];

    post.author = user;
    post.roll = [ImageProcessing getDataArrayFromImageArray:self.images];
    post.textDescription = self.descriptionTextField.text;

    // TODO: maybe add a check to see if the user posted something similar before to catch for duplicate posts
//    PFQuery *query = [Post query];
//    [query whereKey:@"user" equalTo:user];

//    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//
//        if (objects.count >0){
//            NSLog(@"similar post found");
//        } else {
//            NSLog(@"unique post");
//        }
//
//    }];


    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"post saved");
        } else {
            NSLog(@"unable to save post");
        }
    }];

}

@end










