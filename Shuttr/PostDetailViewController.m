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
#import "SVProgressHUD.h"

@interface PostDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSArray *postImages;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;
//@property (weak, nonatomic) IBOutlet UITextField *addCommentTextField;

@end

@implementation PostDetailViewController

#pragma mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self extractImages];
    [self updateComments];
    self.navigationController.navigationItem.title =[NSString stringWithFormat:@"%@'s Post", self.post.author.username];

    if ([self.post.author isEqual:[User currentUser]]){
        [self.descriptionTextView setUserInteractionEnabled:YES];
        self.descriptionTextView.editable = YES;
    }
}


#pragma mark - Helper methods
- (void)updateComments {
    PFQuery *commentsQuery = [Activity query];
    [commentsQuery whereKey:@"activityType" equalTo:@1];
    [commentsQuery whereKey:@"post" equalTo:self.post];
    [SVProgressHUD show];
    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *results = [[NSArray alloc] initWithArray:objects];
            NSMutableString *commentsString = [NSMutableString new];
            for (Activity *comment in results) {
                [commentsString appendFormat:@"%@: %@\n", comment.fromUser.username, comment.content];
            }
            self.commentsTextView.text = commentsString;
            [SVProgressHUD dismiss];
        });
    }];
}

- (void)extractImages {
    self.postImages = [[NSArray alloc] initWithArray:[ImageProcessing getImageArrayFromDataArray:self.post.roll]];
    self.descriptionTextView.text = self.post.textDescription;
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
- (IBAction)onDetailButtonPressed:(UIButton *)sender {

    if ([self.post.author isEqual:[User currentUser]]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Options" message:@"Delete post" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

            UIAlertController *secondAlert = [UIAlertController alertControllerWithTitle:@"Delete Post" message:@"Are you sure you want to delete this post?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                // Remove all activity associated with the post as well

                PFQuery *query = [Activity query];
                [query whereKey:@"post" equalTo:self.post];
                [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                    NSArray *activitiesToDelete = objects;
                    [Activity deleteAllInBackground:activitiesToDelete block:^(BOOL succeeded, NSError * _Nullable error) {
                        [self.post deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

                            // Make sure profile view is updated to no longer show deleted post
                            [self.delegate postWasDeleted:self];
                            [self dismissViewControllerAnimated:YES completion:nil];

                        }];

                    }];

                }];


            }];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];

            [secondAlert addAction:yes];
            [secondAlert addAction:cancel];
            [self presentViewController:secondAlert animated:YES completion:nil];

        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:deleteAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];

    } else  {

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Options" message:@"Report post" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *reportAction = [UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

            //TODO: Do something with report here

            UIAlertController *secondAlert = [UIAlertController alertControllerWithTitle:@"Post Reported" message:@"We have received you report and will take necessary action." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
            [secondAlert addAction:okay];
            [self presentViewController:secondAlert animated:YES completion:nil];

        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:reportAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}


- (IBAction)onDoneButtonPressed:(UIBarButtonItem *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


// Might add back later if we want to handle "add comment" differently
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



@end
