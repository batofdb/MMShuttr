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

    //TODO: save changes to profile here
    [self.delegate profileWasChanged:self];
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
