//
//  EditProfileViewController.m
//  Shuttr
//
//  Created by Philip Henson on 10/24/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "EditProfileViewController.h"
#import "ImageProcessing.h"

@interface EditProfileViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fullNameTextField.text = self.user.fullName;
    self.usernameTextField.text = self.user.username;
    self.emailTextField.text = self.user.email;
    self.profilePictureImageView.image = [ImageProcessing getImageFromData:self.user.profilePicture];
}

- (IBAction)onCancelButtonPressed:(UIBarButtonItem *)sender {
    [self.delegate editCancelled:self];
}

- (IBAction)onDoneButtonPressed:(UIBarButtonItem *)sender {

    // TODO: need to query database here to make sure name/email isn't already taken

    [self.user setObject:self.fullNameTextField.text forKey:@"fullName"];
    [self.user setObject:self.usernameTextField.text forKey:@"username"];
    [self.user setObject:self.emailTextField.text forKey:@"email"];
    [self.user setObject:[ImageProcessing getDataFromImage:self.profilePictureImageView.image] forKey:@"profilePicture"];

    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self.delegate profileWasChanged:self];
        } else {
            NSLog(@"Unable to make changes to profile");
        }
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.profilePictureImageView.image = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
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

    [alert addAction:takePhotoAction];
    [alert addAction:selectPhotoAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
