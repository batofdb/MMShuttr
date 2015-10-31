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
#import <ParseTwitterUtils/ParseTwitterUtils.h>
#import <ParseUI/ParseUI.h>

@interface SignInViewController () <UITextFieldDelegate, PFSignUpViewControllerDelegate, PFLogInViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (nonatomic) UIImage *profilePicture;
@property (nonatomic) NSMutableArray * imageA;
@property (nonatomic) NSMutableArray * imageB;

@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;


@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
  
    
    self.imageA = [NSMutableArray new];
    for (int i = 1; i <30; i++) {
        
        NSString *imageName = [NSString stringWithFormat:@"logoLoginEnded%d",i];
        
        [self.imageA addObject:[UIImage imageNamed:imageName]];
        
    }
    
    
    self.imageB = [NSMutableArray new];
    for (int i = 1; i <37; i++) {
        
        NSString *imageName = [NSString stringWithFormat:@"LogoLoginStart%d",i];
        
        [self.imageB addObject:[UIImage imageNamed:imageName]];
        
    }
    
    // Add a custom login button to your app
    UIButton *myLoginButton=[UIButton buttonWithType:UIButtonTypeCustom];
    myLoginButton.backgroundColor= UIColorFromRGB(0xD9A39A);
    myLoginButton.frame=CGRectMake(0,0,159,40);
    [myLoginButton setTitleColor:UIColorFromRGB(0x423C45) forState:UIControlStateNormal];
    myLoginButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    myLoginButton.layer.cornerRadius = 4;
    myLoginButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-100);
    [myLoginButton setTitle: @"Facebook" forState: UIControlStateNormal];

    UIButton *twitterLoginButton=[UIButton buttonWithType:UIButtonTypeCustom];
    twitterLoginButton.layer.cornerRadius = 4;
    twitterLoginButton.backgroundColor=UIColorFromRGB(0xD9A39A);
    [twitterLoginButton setTitleColor:UIColorFromRGB(0x423C45) forState:UIControlStateNormal];
    twitterLoginButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    twitterLoginButton.frame=CGRectMake(0,0,159,40);
    twitterLoginButton.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height-40);
    [twitterLoginButton setTitle: @"Twitter" forState: UIControlStateNormal];
    // Handle clicks on the button
    [myLoginButton
     addTarget:self
     action:@selector(loginButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    [twitterLoginButton
     addTarget:self
     action:@selector(twitterLoginButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    // Add the button to the view
    [self.view addSubview:myLoginButton];
    [self.view addSubview:twitterLoginButton];
}


- (void)twitterLoginButtonClicked {
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Twitter login.");
            return;
        } else if (user.isNew) {
            [self getUserNameFromLogin:user];
            [self getTwitterProfilePicture];
            NSLog(@"User signed up and logged in with Twitter!");
            [self performSegueWithIdentifier:@"ToMainFeedSegue" sender:self];

        } else {
            NSLog(@"User logged in with Twitter!");
            [self getTwitterProfilePicture];
            [self performSegueWithIdentifier:@"ToMainFeedSegue" sender:self];

        }
    }];
}

#pragma  mark textfield animation
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    self.logoImageView.animationImages = self.imageB;
    self.logoImageView.animationDuration = 1.5;
    self.logoImageView.animationRepeatCount = 0;
    [self.logoImageView startAnimating];
    [self.usernameTextField endEditing:NO];
    [self.passwordTextField endEditing:NO];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
  
    [self signInAction];
    
  
    return YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.usernameTextField endEditing:NO];
    [self.passwordTextField endEditing:NO];
    [self.logoImageView stopAnimating];
}

#warning does not work - must authenticate json request
- (void)getTwitterProfilePicture {
if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]]) {
    // If user is linked to Twitter, we'll use their Twitter screen name

    NSString * requestString = [NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json?screen_name=%@", [PFTwitterUtils twitter].userId];

    NSURL *verify = [NSURL URLWithString:requestString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:verify];
    [[PFTwitterUtils twitter] signRequest:request];

    [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data)
             {

                 NSDictionary* result = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: nil];

                 NSString * imageURL = [result objectForKey:@"profile_image_url"];

                 NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageURL]];
                 UIImage *image = [[UIImage alloc] initWithData:imageData];
                 
                 self.profilePicture = image;
             }
    }];
}
}
- (void)loginButtonClicked {
 
  
    
    // Set permissions required from the facebook user account
    NSArray *permissionsArray = @[ @"user_about_me", @"email", @"user_relationships", @"user_birthday", @"user_location"];

    // Login PFUser using Facebook
    if ([FBSDKAccessToken currentAccessToken]){
        [self performSegueWithIdentifier:@"ToMainFeedSegue" sender:self];
//
//         [PFFacebookUtils logInInBackgroundWithAccessToken:[FBSDKAccessToken currentAccessToken] block:^(PFUser * _Nullable user, NSError * _Nullable error) {
//             [self performSegueWithIdentifier:@"ToMainFeedSegue" sender:self];
//         }];
    } else {

    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            [self getUserNameFromLogin:user];
        } else {
            NSLog(@"User logged in through Facebook!");
            NSLog(@"existing user - username: %@", user.username);
            [self loadFacebookData];
        }
    }];

    }

}


- (void)getUserNameFromLogin:(PFUser *)user {
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
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!error){
            [self loadFacebookData];
            } else {
                NSLog(@"error getting user namefrom login");
            }
        }];


    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [alert addAction:action];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loadFacebookData {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            /* Unused Facebook Parameters
             NSString *location = userData[@"location"][@"name"];
             NSString *gender = userData[@"gender"];
             NSString *birthday = userData[@"birthday"];
             NSString *relationship = userData[@"relationship_status"];
             NSString *email = userData[@"email"];
             */
            NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            // setUserData
            User *user = [User currentUser];
            [user setObject:name forKey:@"fullName"];
            NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:pictureURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {

                if (!error) {
                [user setObject:data forKey:@"profilePicture"];
                [self performSegueWithIdentifier:@"ToMainFeedSegue" sender:self];
                } else {
                    NSLog(@"error loading facebook data");
                }
            }];
            [task resume];
        }
    }];
}

- (IBAction)onXButtonPressed:(UIButton *)sender {

    [self.delegate cancelButtonPressedFromSignIn:self];
}



- (void)signInAction {
    if (![self.passwordTextField.text isEqualToString:@"Password"]) {
        self.logoImageView.animationImages = self.imageA;
        self.logoImageView.animationDuration = 1.5;
        self.logoImageView.animationRepeatCount = 1;
        [self.logoImageView startAnimating];
        [self.usernameTextField endEditing:YES];
        [self.passwordTextField endEditing:YES];
        
    }
    //set delayValue 1.5 sec
    double delayInSeconds = 1.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
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
    });
    
}

- (IBAction)onSignInButtonPressed:(UIButton *)sender {
 
  
    
    [self signInAction];
}

@end
