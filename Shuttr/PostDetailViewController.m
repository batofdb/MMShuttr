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
#import "CommentTableViewCell.h"
@interface PostDetailViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSArray *postImages;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UITextView *commentsTextView;
//@property (weak, nonatomic) IBOutlet UITextField *addCommentTextField;

@property (nonatomic)NSMutableArray *commentAddArray;
@property (weak, nonatomic) IBOutlet UITableView *commentTableView;



@end

@implementation PostDetailViewController

#pragma mark - View Life Cycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self extractImages];
    [self updateComments];
    self.navigationController.navigationItem.title =[NSString stringWithFormat:@"%@'s Post", self.post.author.username];
    self.commentTableView.tableFooterView = [UIView new];
    [self.commentTableView setSeparatorColor:UIColorFromRGB(0x332E35)];
    self.descriptionTextView.textColor = UIColorFromRGB(0xD9A39A);

    if ([self.post.author isEqual:[User currentUser]]){
        [self.descriptionTextView setUserInteractionEnabled:YES];
        self.descriptionTextView.editable = YES;
    } else {
        [self.descriptionTextView setUserInteractionEnabled:NO];
        self.descriptionTextView.editable = NO;
    }
    self.commentAddArray = [NSMutableArray new];
    self.commentTableView.allowsMultipleSelectionDuringEditing = NO;
    
    self.commentTableView.estimatedRowHeight = 112;
    self.commentTableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - TextView Delegate Methods
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        [self.post setObject:textView.text forKey:@"textDescription"];
        [self.post saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [textView resignFirstResponder];
        }];
        return NO;
    }
    return YES;
}


#pragma mark - Helper methods
- (void)updateComments {
    PFQuery *commentsQuery = [Activity query];
    [commentsQuery whereKey:@"activityType" equalTo:@1];
    [commentsQuery whereKey:@"post" equalTo:self.post];
    [commentsQuery orderByDescending:@"createdAt"];
    [SVProgressHUD show];
    [commentsQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSArray *results = [[NSArray alloc] initWithArray:objects];
                NSMutableString *commentsString = [NSMutableString new];
                for (Activity *comment in results) {
                    [commentsString appendFormat:@"%@: %@\n", comment.fromUser.username, comment.content];
                    
                }
                self.commentsTextView.text = commentsString;
            
                self.commentAddArray =(NSMutableArray*) results;
                NSLog(@"%@", self.commentAddArray);
                [self.commentTableView reloadData];
                [SVProgressHUD dismiss];
            });

        }else{
        
        
        [SVProgressHUD dismiss];
        
        
        }
        
        
        
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
//add comment
        UITextField *commentTextField = [[alertController textFields] firstObject];
        Activity *newComment = [Activity new];
        newComment.content = commentTextField.text;
        newComment.fromUser = [User currentUser];
        newComment.toUser = self.post.author;
        newComment.activityType = @1;
        newComment.post = self.post;
        [newComment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self updateComments];
            [self.commentTableView reloadData];
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Post" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

            UIAlertController *secondAlert = [UIAlertController alertControllerWithTitle:@"Delete Post" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
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

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Report Post" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
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


#pragma mark - IBActions
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
//-(NSMutableArray *)commentAddArray{
//    if (!_commentAddArray) {
//        _commentAddArray =[NSMutableArray new];
//    }
//    
//    return _commentAddArray;
//}
#pragma mark table Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.commentAddArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CommentTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    Activity * active =self.commentAddArray[indexPath.row];
//    NSString *content = [NSString stringWithFormat:@"%@: %@",active.fromUser.username,active.content];
    cell.commentLabel.text =active.content;
    cell.nameLabel.text = active.fromUser.username;
    
    
    NSString *timeStamp;
    NSCalendar *c = [NSCalendar currentCalendar];
    NSDate *d1 = [NSDate date];
    NSDate *d2 = active.createdAt;
    NSDateComponents *components = [c components:NSCalendarUnitHour fromDate:d2 toDate:d1 options:0];
    NSInteger diff = components.hour;
    if (diff < 1) {
        NSDateComponents *components = [c components:NSCalendarUnitMinute fromDate:d2 toDate:d1 options:0];
        NSInteger diff = components.minute;
        timeStamp = [NSString stringWithFormat:@"%lum", diff];
    } else {
        timeStamp = [NSString stringWithFormat:@"%luh", diff];
    }
    
    cell.timeLabel.text = timeStamp;
    
    
    
    return cell;
    
    
}

#pragma mark delete Comments from table cells





// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    
    if ([[self.commentAddArray[indexPath.row] fromUser] isEqual:[User currentUser]]) {
        return YES;
    }
    
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Activity* activity =  [self.commentAddArray objectAtIndex:indexPath.row];
        //add code here for when you hit delete
  
        [activity deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [self updateComments];
        }];
    }
}


@end
