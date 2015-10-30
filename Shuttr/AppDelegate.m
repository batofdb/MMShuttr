//
//  AppDelegate.m
//  Shuttr
//
//  Created by Francis Bato on 10/22/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "User.h"
#import "MainLoginViewController.h"
#import "MainFeedViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import <ParseTwitterUtils/ParseTwitterUtils.h>


@interface AppDelegate ()

@end

@implementation AppDelegate




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {


    [[UITabBar appearance] setTintColor:UIColorFromRGB(0xe7e4e5)];
    [[UITabBar appearance] setBarTintColor:UIColorFromRGB(0x5F495F)];

    //[[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];

    [Parse enableLocalDatastore];
    [Parse setApplicationId:@"PgbbVPSwOXHvaz7Q72D2ffJN6QcEfQj8I2nfCSe3"
                  clientKey:@"nexLXsxJJmHF3d5BDttdKYCktNOzKZrRJKqowsiM"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    [PFTwitterUtils initializeWithConsumerKey:@"WKyiOLgjYPuymsknt9hHzfgDA" consumerSecret:@"d7HD65T6zMAL34yUUiiQJUxEZmoICyzhJ1c7jDlCY7thf1dXcF"];

   // [PFUser enableRevocableSessionInBackground];


    if (![User currentUser]) { // Check if user is linked to Facebook

        UIStoryboard *loginStoryboard = [UIStoryboard storyboardWithName:@"SignupSignin" bundle:[NSBundle mainBundle]];
        MainLoginViewController *vc = [loginStoryboard instantiateInitialViewController];

        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = vc;
        [self.window makeKeyAndVisible];
    } else {

        // log in user
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        MainFeedViewController *vc = [mainStoryboard instantiateInitialViewController];

        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        self.window.rootViewController = vc;
        [self.window makeKeyAndVisible];

    }

    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
