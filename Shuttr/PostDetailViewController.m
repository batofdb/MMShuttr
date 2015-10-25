//
//  PostDetailViewController.m
//  Shuttr
//
//  Created by Philip Henson on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "PostDetailViewController.h"
#import "PostCollectionViewCell.h"
#import "ImageProcessing.h"
#import "Activity.h"

@interface PostDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSArray *postImages;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;
//@property (weak, nonatomic) IBOutlet UITextField *addCommentTextField;





@end

@implementation PostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self extractImages];
    [self updateComments];
    self.navigationController.navigationItem.title =[NSString stringWithFormat:@"%@'s Post", self.post.author.username];
}

- (void)updateComments {
    PFQuery *commentsQuery = [Activity query];
    [commentsQuery whereKey:@"activityType" equalTo:@1];
    [commentsQuery whereKey:@"post" equalTo:self.post];
    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *results = [[NSArray alloc] initWithArray:objects];
        NSMutableString *commentsString = [NSMutableString new];
        for (Activity *comment in results) {
            [commentsString appendFormat:@"%@: %@\n", comment.fromUser.username, comment.content];
        }
            self.commentsTextView.text = commentsString;
        });
    }];
}

- (void)extractImages {
    self.postImages = [[NSArray alloc] initWithArray:[ImageProcessing getImageArrayFromDataArray:self.post.roll]];
    self.descriptionTextView.text = self.post.textDescription;
}

//#pragma mark - UITextField Delegate Methods
//
//
//-(BOOL)textFieldShouldReturn:(UITextField *)textField {
//    [self.addCommentTextField resignFirstResponder];
//
//    Activity *newComment = [Activity new];
//    newComment.content = self.addCommentTextField.text;
//    newComment.fromUser = [User currentUser];
//    newComment.toUser = self.post.author;
//    newComment.activityType = @1;
//    newComment.post = self.post;
//    [newComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
//        [self.addCommentTextField setText:@""];
//        [self updateComments];
//    }];
//
//    return YES;
//}
- (IBAction)onAddCommentButtonPressed:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"New Comment" message:nil preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Add comment here.";
    }];


    UIAlertAction *addAction = [UIAlertAction actionWithTitle:@"Add" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){

        UITextField *commentTextField = [[alertController textFields] firstObject];
        Activity *newComment = [Activity new];
            newComment.content = commentTextField.text;
            newComment.fromUser = [User currentUser];
            newComment.toUser = self.post.author;
            newComment.activityType = @1;
            newComment.post = self.post;
            [newComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                [self updateComments];
            }];

    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:addAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UICollectionView Delegate Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.postImages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.imageView.image = [self.postImages objectAtIndex:indexPath.row];

    return cell;
}

#pragma mark - IBActions

- (IBAction)onDoneButtonPressed:(UIBarButtonItem *)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
