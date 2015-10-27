//
//  SignInViewController.m
//  Shuttr
//
//  Created by Philip Henson on 10/25/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "SignInViewController.h"
#import "User.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import <ParseUI/ParseUI.h>

@interface SignInViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // Add a custom login button to your app
    UIButton *myLoginButton=[UIButton buttonWithType:UIButtonTypeCustom];
    myLoginButton.backgroundColor=[UIColor darkGrayColor];
    myLoginButton.frame=CGRectMake(0,0,180,60);
    myLoginButton.center = CGPointMake(self.view.frame.size.width/2, (self.view.frame.size.height/2)+40);
    [myLoginButton setTitle: @"Facebook" forState: UIControlStateNormal];

    // Handle clicks on the button
    [myLoginButton
     addTarget:self
     action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    // Add the button to the view
    [self.view addSubview:myLoginButton];

}

- (void)loginButtonClicked {

    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"email", @"user_relationships", @"user_birthday", @"user_location"];

    // Login PFUser using Facebook
    if ([FBSDKAccessToken currentAccessToken]){
         [PFFacebookUtils logInInBackgroundWithAccessToken:[FBSDKAccessToken currentAccessToken] block:^(PFUser * _Nullable user, NSError * _Nullable error) {

             [self performSegueWithIdentifier:@"ToMainFeedSegue" sender:self];

         }];
    } else {

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

            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];

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

}

- (IBAction)onXButtonPressed:(UIButton *)sender {

    [self.delegate cancelButtonPressedFromSignIn:self];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onSignInButtonPressed:(UIButton *)sender {

    [User logInWithUsernameInBackground:self.usernameTextField.text password:self.passwordTextField.text block:^(PFUser * _Nullable user, NSError * _Nullable error) {

        if (!error) {
            [self performSegueWithIdentifier:@"ToMainFeedSegue" sender:self];
        } else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Incorrect username/password." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:tryAgain];
            [self presentViewController:alert animated:YES completion:nil];
        }

    }];
}

@end
