//
//  SignInViewController.h
//  Shuttr
//
//  Created by Philip Henson on 10/25/15.
//  Copyright © 2015 MMInstaGroup. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignInDelegate <NSObject>

- (void)cancelButtonPressedFromSignIn:(id)sender;

@end

@interface SignInViewController : UIViewController

@property (weak, nonatomic) id <SignInDelegate> delegate;

@end
