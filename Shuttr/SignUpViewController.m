//
//  SignUpViewController.m
//  Shuttr
//
//  Created by Philip Henson on 10/25/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "SignUpViewController.h"
#import "User.h"
#import "ImageProcessing.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import <ParseUI/ParseUI.h>

@interface SignUpViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Add a custom login button to your app
    UIButton *myLoginButton=[UIButton buttonWithType:UIButtonTypeCustom];
    myLoginButton.frame=CGRectMake(0,0,159,40);
    myLoginButton.layer.cornerRadius = 4;
    myLoginButton.backgroundColor=UIColorFromRGB(0xD9A39A);
    [myLoginButton setTitleColor:UIColorFromRGB(0x423C45) forState:UIControlStateNormal];
    myLoginButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    myLoginButton.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height/2)+140);
    [myLoginButton setTitle: @"Facebook" forState: UIControlStateNormal];

    // Handle clicks on the button
    [myLoginButton
     addTarget:self
     action:@selector(facebookButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    // Add the button to the view
    [self.view addSubview:myLoginButton];

    
}

- (IBAction)onXButtonPressed:(UIButton *)sender {
    [self.delegate cancelButtonPressedFromSignUp:self];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)facebookButtonClicked {

    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"email", @"user_relationships", @"user_birthday", @"user_location"];

    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            NSLog(@"new user - username: %@", user.username);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New User" message:@"Create a username for your new Shuttr account." preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                textField.placeholder = @"username";
            }];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"Go" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UITextField *usernameTextField = [[alert textFields] firstObject];
                NSString *enteredUsername = usernameTextField.text;
                [user setObject:enteredUsername forKey:@"username"];
                [self performSegueWithIdentifier:@"ToMainFeedSegue" sender:self];
            }];

            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

            [alert addAction:action];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];

        } else {
            NSLog(@"User logged in through Facebook!");
            NSLog(@"existing user - username: %@", user.username);
            [self performSegueWithIdentifier:@"ToMainFeedSegue" sender:self];
        }
    }];
    
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
                        newUser.profilePicture = [ImageProcessing getDataFromImage:[UIImage imageNamed:@"profile_default"]];
                        [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if (succeeded) {
                                [User logInWithUsernameInBackground:newUser.username password:newUser.password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                                    [self performSegueWithIdentifier:@"ToMainFeedSegue" sender:self];
                                }];

                            } else if(![self NSStringIsValidEmail:self.emailTextField.text]){
                                
                                
                                NSLog(@"Email is invalid");
                                UIAlertController *thirdAlert = [UIAlertController alertControllerWithTitle:@"Invalid Email" message:@"Please enter a valid email" preferredStyle:UIAlertControllerStyleAlert];
                                UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
                                [thirdAlert addAction:okay];
                                [self presentViewController:thirdAlert animated:YES completion:nil];

                                
                            }  else
                            
                            {
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



#pragma mark EmailValidation
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

@end
