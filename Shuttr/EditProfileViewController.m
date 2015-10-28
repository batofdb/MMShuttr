//
//  EditProfileViewController.m
//  Shuttr
//
//  Created by Philip Henson on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "EditProfileViewController.h"
#import "ImageProcessing.h"
#import "SVProgressHUD.h"
#import "User.h"
#import "UIImage+ImageResizing.h"

@interface EditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic) User *user;
@property BOOL imageChanged;
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.user = [User currentUser];

    self.fullNameTextField.text = self.user.fullName;
    self.usernameTextField.text = self.user.username;
    self.emailTextField.text = self.user.email;
    self.passwordTextField.text = self.user.password;
    self.imageChanged = NO;
    self.profilePictureImageView.image = [ImageProcessing getImageFromData:self.user.profilePicture];
}

- (IBAction)onCancelButtonPressed:(UIBarButtonItem *)sender {
    [self.delegate editCancelled:self];
}

- (IBAction)onDoneButtonPressed:(UIBarButtonItem *)sender {

    // TODO: need to query database here to make sure name/email isn't already taken


    // Only make changes if fields have changed.
    if (![self.fullNameTextField.text isEqualToString:self.user.fullName]){
        [self.user setObject:self.fullNameTextField.text forKey:@"fullName"];
    }

    if (![self.usernameTextField.text isEqualToString:self.user.username]){
        [self.user setObject:self.usernameTextField.text forKey:@"username"];
    }

    if (![self.emailTextField.text isEqualToString:self.user.email]){
        [self.user setObject:self.emailTextField.text forKey:@"email"];
    }

    if (![self.passwordTextField.text isEqualToString:self.user.password]){
        [self.user setObject:self.passwordTextField.text forKey:@"password"];
    }

    if (self.imageChanged){
        [self.user setObject:[ImageProcessing getDataFromImage:self.profilePictureImageView.image] forKey:@"profilePicture"];
    }

    [SVProgressHUD show];

    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [SVProgressHUD dismiss];
            self.imageChanged = NO;
            [self.delegate profileWasChanged:self];
        } else {
            NSLog(@"Unable to make changes to profile");
        }
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.profilePictureImageView setImage:image];
    self.imageChanged = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - IBActions
- (IBAction)onLogoutButtonPressed:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Logging Out" message:@"Are you sure you want to log out?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        [User logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            [self performSegueWithIdentifier:@"ToSignupSegue" sender:self];
        }];

    }];
    UIAlertAction *cancelAction= [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:yesAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)onEditProfilePictureButtonPressed:(UIButton *)sender {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select image source" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];

    }];
    UIAlertAction *selectPhotoAction = [UIAlertAction actionWithTitle:@"Select From Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

        [self presentViewController:picker animated:YES completion:nil];
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:takePhotoAction];
    [alert addAction:selectPhotoAction];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
