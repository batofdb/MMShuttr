//
//  SignUpViewController.m
//  Shuttr
//
//  Created by Philip Henson on 10/25/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "SignUpViewController.h"
#import "User.h"

@interface SignUpViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onXButtonPressed:(UIButton *)sender {
    [self.delegate cancelButtonPressedFromSignUp:self];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onSignUpButtonPressed:(UIButton *)sender {

    PFQuery *query = [User query];
    [query whereKey:@"email" equalTo:self.emailTextField.text];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {

        if (objects.count > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Email Taken" message:@"Email is already registered with a Shuttr account." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

            self.emailTextField.text = @"";
        }];
        [alert addAction:okay];
        [self presentViewController:alert animated:YES completion:nil];

        } else {


            PFQuery *query =[User query];
            [query whereKey:@"username" equalTo:self.usernameTextField.text];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (objects.count > 0) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Username Taken" message:@"Username is already registered with a Shuttr account." preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                        self.usernameTextField.text = @"";
                    }];
                    [alert addAction:okay];
                    [self presentViewController:alert animated:YES completion:nil];
                } else {

                    if ([self.passwordTextField.text length] < 4){
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid Password" message:@"Password must be at least 4 characters." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

                            self.passwordTextField.text = @"";

                        }];
                        [alert addAction:dismiss];
                        [self presentViewController:alert animated:YES completion:nil];
                        
                    } else if ([self.fullNameTextField.text length] == 0) {

                        UIAlertController *secondAlert = [UIAlertController alertControllerWithTitle:@"Invalid name" message:@"Please enter a full name." preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
                        [secondAlert addAction:okay];
                        [self presentViewController:secondAlert animated:YES completion:nil];

                    } else {
                        User *newUser = [User user];
                        newUser.username = self.usernameTextField.text;
                        newUser.password = self.passwordTextField.text;
                        newUser.email = self.emailTextField.text;
                        newUser.fullName = self.fullNameTextField.text;
                        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {

                            if (succeeded) {
                                [User logInWithUsernameInBackground:newUser.username password:newUser.username block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                                    [self performSegueWithIdentifier:@"ToMainFeedSegue" sender:self];

                                }];

                            } else {
                                NSLog(@"sign up unsuccessful");
                                UIAlertController *thirdAlert = [UIAlertController alertControllerWithTitle:@"Sign up unsuccessful" message:@"Please try again." preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
                                [thirdAlert addAction:okay];
                                [self presentViewController:thirdAlert animated:YES completion:nil];

                            }

                        }];
                    }
                }

            }];
        }
    }];
}

@end
